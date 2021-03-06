//
//  ChromaPickerServiceViewController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 30.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import PanModal
import RxCocoa
import RxKeyboard
import RxSwift
import RxSwiftExt
import UIKit

final class NumberInputViewController: UIViewController, PanModalPresentable {
    lazy var headerView = ModalHeaderView()
    
    var isShortFormEnabled = true
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight = .contentHeight(320) {
        didSet {
            guard longFormHeight != oldValue else {
                return
            }
            shortFormHeight = longFormHeight
            panModalSetNeedsLayoutUpdate()
        }
    }

    var shortFormHeight: PanModalHeight = .contentHeight(320) {
        didSet {
            guard longFormHeight != oldValue else {
                return
            }
            longFormHeight = shortFormHeight
            panModalSetNeedsLayoutUpdate()
        }
    }

    var anchorModalToLongForm: Bool {
        return false
    }
    
    var showDragIndicator: Bool {
        return false
    }

    private let injectedView: NumberInputView
    public private(set) var disposeBag = DisposeBag()
    
    var keyboardDuration: Double = 0.3
    var keyboardAnimOptions: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut]
    
    init(with view: NumberInputView) {
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
    
    var viewModel: NumberInputViewControllerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(injectedView.backView) {
            $0?.clipsToBounds = true
            $0?.layer.cornerRadius = 12
            $0?.layer.cornerCurve = .continuous
        }
         
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        injectedView.sumField.becomeFirstResponder()
        injectedView.backgroundColor = .clear
        view.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func bindViewModel() {
        injectedView.sumField.numberValue = viewModel.input.product.price.asInt
        injectedView.quantityField.numberValue = viewModel.input.product.count.asInt
        
        let combine = Driver.combineLatest(injectedView.sumField.intDriver, injectedView.quantityField.intDriver)
            .asDriver()

        injectedView.doneButton.rx.tap.withLatestFrom(combine)
            .bind(to: viewModel.input.okTrigger)
            .disposed(by: disposeBag)
        
        injectedView.doneButton.rx.tap.asDriver()
            .withUnretained(self)
            .drive(onNext: { owner, _ in
                owner.dismiss(animated: true, completion: nil)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        injectedView.closeButton.rx.tap.asDriver()
            .withUnretained(self)
            .drive(onNext: { owner, _ in
                owner.dismiss(animated: true, completion: nil)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        let titleHeight: CGFloat = min(viewModel.input.product.name.heightFor(font: .boldSystemFont(ofSize: 24), width: UIScreen.main.bounds.width - 40), 58.0)
        
        let sheetHeight: CGFloat = 296 + titleHeight
        
        longFormHeight = .contentHeight(sheetHeight)
        
        injectedView.titleLabel.text = viewModel.input.product.name
        
        injectedView.closeButton.rx.tap
            .bind(to: viewModel.input.cancelTrigger)
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] newHeight in
                guard let self = self else { return }
                guard let presentedVC = self.presentationController as? PanModalPresentationController, let containerView = presentedVC.containerView
                else { return }
                UIView.animate(withDuration: self.keyboardDuration, delay: 0, options: self.keyboardAnimOptions, animations: {
                    containerView.transform = CGAffineTransform(translationX: 0, y: -newHeight)
                }, completion: nil)
            }).disposed(by: disposeBag)

        RxKeyboard.instance.isHidden
            .throttle(.milliseconds(300))
            .drive(onNext: { [weak self] hidden in
                guard let self = self, hidden else { return }
                guard let presentedVC = self.presentationController as? PanModalPresentationController, let containerView = presentedVC.containerView
                else { return }
                UIView.animate(withDuration: self.keyboardDuration, delay: 0, options: self.keyboardAnimOptions, animations: {
                    containerView.transform = .identity
                }, completion: nil)
            }).disposed(by: disposeBag)
    }
}

extension NumberInputViewController {
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
