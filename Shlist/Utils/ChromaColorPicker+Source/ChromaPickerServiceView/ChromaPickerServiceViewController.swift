//
//  ChromaPickerServiceViewController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 30.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxKeyboard
import RxSwift
import RxSwiftExt
import UIKit

final class ChromaPickerServiceViewController: UIViewController {
    private let injectedView: ChromaPickerServiceView
    public private(set) var disposeBag = DisposeBag()
    let timing = UISpringTimingParameters(damping: 1, response: 0.5)
    lazy var animatorEnter = UIViewPropertyAnimator(duration: 0, timingParameters: self.timing)
    lazy var animatorExit = UIViewPropertyAnimator(duration: 0, timingParameters: self.timing)
    
    init(with view: ChromaPickerServiceView) {
        injectedView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = injectedView
    }
    
    var viewModel: ChromaPickerServiceViewModelImpl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(view) {
            $0?.clipsToBounds = true
            $0?.layer.cornerRadius = 10
        }
        
        bindViewModel()
    }
    
    func bindViewModel() {
        let animEnter = { [unowned self] in
            self.injectedView.hexTextField.backgroundColor = Settings.Colors.themeService.attrs.textFieldCategoryNameHighlight
        }
        
        let animExit = { [unowned self] in
            self.injectedView.hexTextField.backgroundColor = Settings.Colors.themeService.attrs.iconBackColor
        }
          
        Settings.Colors.themeService.rx
            .bind({ $0.backgroundColor }, to: injectedView.rx.backgroundColor)
            .bind({ $0.iconBackColor }, to: injectedView.hexTextField.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        injectedView.hexTextField.rx.controlEvent(.editingDidBegin)
            .asObservable()
            .flatMap { [unowned self] _ -> Completable in
                self.animatorEnter.addAnimations(animEnter)
                return self.animatorEnter.rx.animate()
            }.asObservable()
            .subscribe(onNext: { _ in
                
            }).disposed(by: disposeBag)
        
        injectedView.hexTextField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .flatMap { [unowned self] _ -> Completable in
                self.animatorExit.addAnimations(animExit)
                return self.animatorExit.rx.animate()
            }.asObservable()
            .subscribe(onNext: { _ in
                
            }).disposed(by: disposeBag)
        
        injectedView.hexTextField.rx.controlEvent(.editingDidEnd)
            .flatMapLatest {
                self.animatorExit.rx.animate()
            }.asObservable()
            .subscribe(onNext: { _ in
                
            }).disposed(by: disposeBag)
        
        injectedView.doneButton.rx.tap
            .withLatestFrom(injectedView.colorPicker.rx.color)
            .bind(to: viewModel.input.colorDoneTrigger)
            .disposed(by: disposeBag)
        
        injectedView.cancelButton.rx.tap
            .bind(to: viewModel.cancelAction.inputs)
            .disposed(by: disposeBag)
        
        let editChange = injectedView.hexTextField.rx.controlEvent(.editingDidEnd)
            .withLatestFrom(injectedView.hexTextField.rx.text).asDriver(onErrorJustReturn: nil)
        
        editChange
            .drive(onNext: { [unowned self] hexStr in
                
                guard let hexString = hexStr else {
                    return
                }
                
                let newColor = UIColor(hexString: hexString)
                
                self.injectedView.colorPicker.mainColor = newColor
                
            }).disposed(by: disposeBag)
        
        injectedView.colorPicker.rx.color
            .flatMapLatest {
                Observable<String>.just($0.toHexString())
            }.bind(to: injectedView.hexTextField.rx.text)
            .disposed(by: disposeBag)
    }
}

extension ChromaPickerServiceViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                Settings.Colors.themeService.switch(Settings.Colors.ThemeType.dark)
                
            } else {
                Settings.Colors.themeService.switch(Settings.Colors.ThemeType.light)
            }
            view.backgroundColor = .systemBackground
        }
    }
}
