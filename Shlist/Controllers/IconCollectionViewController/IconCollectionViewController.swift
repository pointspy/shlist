//
//  IconCollectionViewController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 23.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Action
import Reusable
import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt

import SwiftIcons
import UIKit
import SwiftEntryKit

final class IconCollectionViewController: UIViewController {
    static let mainIconSize: CGFloat = 100
    static let textFieldHeight: CGFloat = 56
    static let textFieldMargin: CGFloat = 16
    static let symbolDimension: CGFloat = 64
    
    let timing = UISpringTimingParameters(damping: 1.0, response: 0.35)
    
    lazy var animatorEnter = UIViewPropertyAnimator(duration: 0, timingParameters: self.timing)
    lazy var animatorExit = UIViewPropertyAnimator(duration: 0, timingParameters: self.timing)
    
    var firstTime: Bool = true
    var firstTimeColor: Bool = true
    
    var currentSelectedColorIndex: Int? = 0
    var currentSelectedIconIndex: Int? = 0
    
    var currentColorRelay: BehaviorRelay<UIColor> = .init(value: .white)
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        let layout = BouncyLayout()
        layout.itemSize = CGSize(width: IconCollectionViewCell.cellDimension, height: IconCollectionViewCell.cellDimension)
        
        let collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        return collection
    }()
    
    lazy var mainIcon: UIImageView = configure(UIImageView()) {
        $0.backgroundColor = .clear
        $0.contentMode = .center
    }
    
    lazy var mainIconContainer: UIView = configure(UIView()) {
        $0.backgroundColor = .clear
    }
    
    lazy var textFieldCategoryName: UITextField = configure(UITextField()) {
        $0.backgroundColor = Settings.Colors.themeService.attrs.iconBackColor
        $0.textAlignment = .center
        $0.font = UIFont.boldSystemFont(ofSize: 19)
    }
    
    lazy var animConfig: AnimationConfiguration = {
        let config = AnimationConfiguration(
            insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .fade)
        return config
    }()
    
    lazy var animatedDataSource = RxCollectionViewSectionedAnimatedDataSource<CategoryStyleMultipleSectionModel>(animationConfiguration:
        self.animConfig,
                                                                                                                 configureCell: { [weak self] dataSource, collection, indexPath, _ in
            guard let self = self else {
                return UICollectionViewCell()
            }
            
            switch dataSource[indexPath] {
            case let .ColorsSectionItem(title, color):
                
                let cell: IconCollectionViewCell = collection.dequeueReusableCell(for: indexPath)
                if indexPath.row == self.viewModel.dataSourceColors.allItems.count - 1, indexPath.section == 0 {
                    let iconW = IconTypeWrapper(id: "more.menu.item", type: FASolidType.ellipsisH, checked: false)
                    cell.setType(with: iconW, colorWrap: color)
                } else {
                    cell.setType(with: nil, colorWrap: color)
                }
                cell.setChecked(color.checked)
                return cell
            case let .IconsSectionItem(title, icon):
                let cell: IconCollectionViewCell = collection.dequeueReusableCell(for: indexPath)
                cell.setType(with: icon, colorWrap: nil)
                cell.setChecked(icon.checked)
                return cell
            case let .SpaceSectionItem(title, height):
                let cell: IconCollectionViewCell = collection.dequeueReusableCell(for: indexPath)
                cell.isHidden = true
                return cell
            }
            
        },
                                                                                                                 configureSupplementaryView: suplementary)
    
    let suplementary: CollectionViewSectionedDataSource<CategoryStyleMultipleSectionModel>.ConfigureSupplementaryView = { _, cv, kind, ip in
        
        let header = cv.dequeueReusableSupplementaryView(ofKind: kind, for: ip) as HeaderReusableView
        header.titleLabel.text = ip.section == 0 ? "Цвет".uppercased() : "Иконка".uppercased()
        header.titleLabel.font = Settings.Fonts.smallHeader
        
        return header
    }
    
    public private(set) var disposeBag = DisposeBag()
    
    let viewModel: IconCollectionViewModelImpl
    
    var doneButton = UIBarButtonItem(title: "Готово", style: .plain) {}
    
    init(viewModel: IconCollectionViewModelImpl) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "Новая"
        
        view.subviews(collectionView, mainIconContainer, textFieldCategoryName)
        mainIconContainer.subviews(mainIcon)
        
        mainIcon.fillContainer()
        mainIcon.backgroundColor = .clear
        
        let closeButton = UIBarButtonItem(title: "Отмена", style: .plain) {
            self.dismiss(animated: true, completion: nil)
        }
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
        
        configure(mainIconContainer) {
            $0.bounds.size = CGSize(width: IconCollectionViewController.mainIconSize, height: IconCollectionViewController.mainIconSize)
            $0.Top == 80
            $0.CenterX == view.CenterX
            $0.Height == IconCollectionViewController.mainIconSize
            $0.Width == IconCollectionViewController.mainIconSize
            
            $0.layer.cornerRadius = IconCollectionViewController.mainIconSize / 2
            $0.clipsToBounds = true
            $0.backgroundColor = .clear
            $0.applyGradient(withColours: [Settings.Colors.categoryColors[0], Settings.Colors.categoryColors[0]], gradientOrientation: .vertical)
        }
        
        configure(textFieldCategoryName) {
            $0.Top == self.mainIcon.Bottom + 20
            
            $0.Height == IconCollectionViewController.textFieldHeight
            $0.Left == IconCollectionViewController.textFieldMargin
            $0.Right == IconCollectionViewController.textFieldMargin
            
            $0.layer.cornerRadius = 10.0
            $0.clipsToBounds = true
            $0.font = Settings.Fonts.categoryName
        }
        
        configure(collectionView) {
            $0.Top == self.textFieldCategoryName.Bottom + 20
            $0.Left == view.Left
            $0.Right == view.Right
            $0.Bottom == view.Bottom
        }
        
        collectionView.register(cellType: IconCollectionViewCell.self)
        collectionView.register(supplementaryViewType: HeaderReusableView.self,
                                ofKind: UICollectionView.elementKindSectionHeader)
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.headerReferenceSize = CGSize(width: collectionView.bounds.size.width, height: 40)
        }
        
        if self.view.traitCollection.userInterfaceStyle == .dark {
            Settings.Colors.themeService.switch(.dark)
        } else {
            Settings.Colors.themeService.switch(.light)
        }
        
        collectionView.backgroundColor = UIColor.clear
        view.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor.systemBackground : .secondarySystemBackground
        
        view.rx.tapGesture(configuration: { [unowned self] _, delegate in
            delegate.touchReceptionPolicy = .custom { _, touch in
                if touch.view?.isDescendant(of: self.collectionView) == true {
                    return false
                }
                return true
            }
        }).asDriver()
            .asObservable().when(.recognized)
            .subscribe(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        Settings.Colors.themeService.rx
            .bind({ $0.backgroundColor }, to: self.view.rx.backgroundColor)
            .bind({ $0.iconBackColor }, to: self.textFieldCategoryName.rx.backgroundColor)
            .disposed(by: self.disposeBag)
        
        var insets = UIEdgeInsets()
        insets.top = 0
        insets.left = 16
        insets.right = 16
        collectionView.contentInset = insets
        collectionView.showsVerticalScrollIndicator = false
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.output.resultIconSections.asObservable()
            .bind(to: collectionView.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
        Driver.combineLatest(viewModel.output.selectedIconWrap, viewModel.output.selectedColorWrap)
            .drive(onNext: { [unowned self] value in
                let (icon, color) = value
                guard let type = icon.type else { return }
                self.mainIconContainer.applyGradient(withColours: [color.color.lighter(amount: 0.15), color.color], gradientOrientation: .vertical)
                
                self.mainIcon.setIcon(icon: .fontAwesomeSolid(type), textColor: .white, backgroundColor: .clear, size: CGSize(width: IconCollectionViewController.symbolDimension, height: IconCollectionViewController.symbolDimension))
                
                self.currentSelectedIconIndex = self.viewModel.dataSource.getIndex(for: icon)
                self.currentSelectedColorIndex = self.viewModel.dataSourceColors.getIndex(for: color)
                
            }).disposed(by: disposeBag)
        
        self.textFieldCategoryName.rx.text.asDriver()
            .drive(self.viewModel.input.categoryNameRelay)
            .disposed(by: disposeBag)
        
        let themeDriver = Settings.Colors.themeService.attrsStream
            .observe(on: MainScheduler.instance)
            .share(replay: 1, scope: .whileConnected)
            .asDriver(onErrorJustReturn: Settings.Colors.LightTheme())
        
        let textEnterDriver = self.textFieldCategoryName.rx.controlEvent(.editingDidBegin)
            .asDriver()
        
        let textExitDriver = self.textFieldCategoryName.rx.controlEvent(.editingDidEnd)
            .asDriver()
        
        Driver.combineLatest(themeDriver, textEnterDriver)
            .flatMap { [unowned self] value -> Driver<Void> in
                self.animatorEnter.addAnimations { [unowned self] in
                    self.textFieldCategoryName.backgroundColor = value.0.textFieldCategoryNameHighlight
                }
                
                return BehaviorRelay<Void>.init(value: ()).asDriver()
            }.asObservable()
            .flatMap {[unowned self] in
                self.animatorEnter.rx.animate()
            }.subscribe(onNext: { _ in
                
            }).disposed(by: disposeBag)
        
        Driver.combineLatest(themeDriver, textExitDriver)
        .flatMap { [unowned self] value -> Driver<Void> in
            self.animatorExit.addAnimations { [unowned self] in
                self.textFieldCategoryName.backgroundColor = value.0.iconBackColor
            }
            
            return BehaviorRelay<Void>.init(value: ()).asDriver()
        }.asObservable()
        .flatMap {[unowned self] in
            self.animatorExit.rx.animate()
        }.subscribe(onNext: { _ in
            
        }).disposed(by: disposeBag)
        
        let validObservable = self.viewModel.output.categoryNameDriver
            .flatMapLatest { text -> Driver<Bool> in
                guard let text = text, !text.isEmpty else {
                    return BehaviorRelay<Bool>.init(value: false).asDriver()
                }
                
                if Settings.Store.productDictionaryRepository.getItemWithText(text) == nil {
                    return BehaviorRelay<Bool>.init(value: true).asDriver()
                }
                
                return BehaviorRelay<Bool>.init(value: false).asDriver()
            }.asObservable()
        
        let doneAction = CocoaAction(enabledIf: validObservable) { [weak self] in
            
            guard let self = self, let category = self.viewModel.output.categoryRelay.value else {
                return Observable<Void>.just(())
            }
            
            let prod = Product(id: UUID().uuidString, name: category.name, category: category, checked: true)
            
            Settings.Store.selectedCategoryDataSource.addItem(prod)
            
            self.dismiss(animated: true, completion: nil)
            
            return Observable<Void>.just(())
        }
        
        self.doneButton.rx.action = doneAction
        
        
        viewModel.output.selectedColorWrap
            .flatMapLatest {colorWrap -> Driver<UIColor> in
                return BehaviorRelay<UIColor>.init(value: colorWrap.color).asDriver()
        }.drive(self.currentColorRelay)
        .disposed(by: disposeBag)
    }
}

extension IconCollectionViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                Settings.Colors.themeService.switch(Settings.Colors.ThemeType.dark)
                
            } else {
                Settings.Colors.themeService.switch(Settings.Colors.ThemeType.light)
            }
            self.view.backgroundColor = .systemBackground
        }
    }
}

extension IconCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? IconCollectionViewCell else {
            return
        }
        
        if indexPath.section == 1 {
            if let iconIndex = self.currentSelectedIconIndex, let cellF = collectionView.cellForItem(at: IndexPath(row: iconIndex, section: 1)) as? IconCollectionViewCell {
                cellF.setChecked(false, animated: false)
            }
            
            if let item = self.viewModel.input.dataSource.getItemWithIndex(indexPath.row) {
                self.viewModel.input.dataSource.setSelected(item: item) { _ in
                }
            }
        } else if indexPath.section == 0 {
            if let colorIndex = self.currentSelectedColorIndex, let cellF = collectionView.cellForItem(at: IndexPath(row: colorIndex, section: 0)) as? IconCollectionViewCell {
                cellF.setChecked(false, animated: false)
            }
            if let item = self.viewModel.input.dataSourceColors.getItemWithIndex(indexPath.row) {
                if indexPath.row == self.viewModel.input.dataSourceColors.allItems.count - 1 {
                    
                    let colorView = ChromaPickerServiceView(color: self.currentColorRelay.value)
                    
                    let colorVC = ChromaPickerServiceViewController(with: colorView)
                    
                    let vm = ChromaPickerServiceViewModelImpl(dataSourceColors: self.viewModel.input.dataSourceColors)
                    
                    colorVC.viewModel = vm
                    
                    DispatchQueue.main.async {
                        
                        SwiftEntryKit.display(entry: colorVC, using: Settings.EntryKit.attributes)
                    }
                   
                } else {
                    self.viewModel.input.dataSourceColors.setSelected(item: item) { _ in
                    }
                }
            }
        }
        
        cell.setChecked(true, animated: false)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

#if !swift(>=4.2)
private extension UICollectionView {
    static let elementKindSectionHeader = UICollectionElementKindSectionHeader
}
#endif
