//
//  CategoryDictionaryViewController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 28.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Reusable
import RxCocoa
import RxDataSources
import RxSwift
//import SwipeCellKit
import UIKit

final class CategoryDictionaryViewController: UIViewController {
    lazy var tableView = UITableView()
    
    let viewModel: CategoryDictionaryViewModelImpl
    
    lazy var animConfig: AnimationConfiguration = {
        let config = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .automatic, deleteAnimation: .fade)
        return config
    }()
    
    lazy var animatedDataSource = RxTableViewSectionedAnimatedDataSource<SectionOfProducts>(animationConfiguration:
        self.animConfig,
                                                                                            
        configureCell: { [weak self] dataSource, tableView, indexPath, item in
            
            guard let self = self else { return UITableViewCell() }
            
            switch dataSource.sectionModels[indexPath.section].type {
            case .addNewProductChooseCategoryHeader:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductHeader", for: indexPath) as? NewProductHeader {
                    cell.titleLabel.text = "Категории"
                    cell.setUp()
                    cell.selectionStyle = .none
                    
                    return cell
                }
                return UITableViewCell()
            case .addNewProductChooseCategoryContent:
                return self.factoryProductCellSelectCategory(for: item, indexPath: indexPath, dataSource: dataSource)
                
            default:
                return UITableViewCell()
            }
    })
    
    private func factoryProductCellSelectCategory(for item: Product, indexPath: IndexPath, dataSource: TableViewSectionedDataSource<SectionOfProducts>) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductCell", for: indexPath) as? NewProductCell else { return UITableViewCell() }
        
        cell.nameLabel.text = item.name
        cell.hidePrice()
        let options: ProductCellOptions = [.single, .withoutFluidTouch]
        
        cell.setUp(with: options, product: item)
        cell.set(checked: false)
        cell.checkMarkIsAvailable = false
        
        if self.viewModel.dataSource.isCustomCategory(for: indexPath.row) {
            cell.setCkeckForCustomCategory()
        }
//        cell.delegate = self
        return cell
    }
    
    public private(set) var disposeBag = DisposeBag()
    
    init(viewModel: CategoryDictionaryViewModelImpl) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var addCategoryButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add) {
        let iconDS = IconsDataSource()
        
        
        let iconVM = IconCollectionViewModelImpl(iconsWrap: iconDS.items, dataSource: iconDS, dataSourceColors: Settings.Store.colorsDS)
        
        let vc = IconCollectionViewController(viewModel: iconVM)
        
        let nvc = UINavigationController(rootViewController: vc)
        
        self.present(nvc, animated: true, completion: nil)
    }
    
    lazy var closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.closeButton
        self.navigationItem.rightBarButtonItem = self.addCategoryButton
        self.navigationItem.title = "Категории"
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        tableView.register(cellType: NewProductCell.self)
        tableView.register(cellType: NewProductHeader.self)
        
        view.subviews(tableView)
        
        if self.view.traitCollection.userInterfaceStyle == .dark {
            Settings.Colors.themeService.switch(.dark)
        } else {
            Settings.Colors.themeService.switch(.light)
        }
        
        configure(tableView) {
            $0.tableFooterView = UIView()
            $0.backgroundColor = UIColor.clear
            
            var insets = UIEdgeInsets()
            insets.top = 8
            $0.contentInset = insets
            $0.showsVerticalScrollIndicator = false
            $0.separatorStyle = .none
            
            $0.fillContainer()
        }
        
        view.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor.systemBackground : .secondarySystemBackground
        
        Settings.Colors.themeService.rx
            .bind({ $0.backgroundColor }, to: self.view.rx.backgroundColor, self.tableView.rx.backgroundColor)
            .disposed(by: self.disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.output.resultProductSections.asObservable()
            .bind(to: tableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
//        tableView.rx.willDisplayCell.asDriver()
//            .drive(onNext: { [weak self] cell, indexPath in
//                guard let self = self else { return }
//                let animation = TableViewAppearAnimationFactory.makeMoveUpWithFadeSpring(rowHeight: 50, response: 0.35, delayFactor: 0.04)
//                let animator = TableViewAppearAnimator(animation: animation)
//                animator.animate(cell: cell, at: indexPath, in: self.tableView)
//            }).disposed(by: disposeBag)
    }
}

extension CategoryDictionaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.animatedDataSource.sectionModels[indexPath.section].type {
        case .addNewProductChooseCategoryHeader:
            return CGFloat(50)
            
        default:
            return CGFloat(56)
        }
    }
}

// MARK: - SwipeTableViewCellDelegate

//extension CategoryDictionaryViewController: SwipeTableViewCellDelegate {
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//
//        guard !self.viewModel.dataSource.allItems.isEmpty, self.viewModel.dataSource.isCustomCategory(for: indexPath.row) else {
//            return nil
//        }
//
//        let deleteAction = SwipeAction(style: .destructive, title: "Удалить") { [weak self] _, indexPath in
//
//            self?.viewModel.dataSource.removeItem(with: indexPath.row)
//        }
//
//        let trans = ScaleTransition(duration: 0.217, initialScale: 0.6, threshold: 0.85)
//
//        deleteAction.transitionDelegate = trans
//
//        return [deleteAction]
//    }
//
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//
//        options.transitionStyle = .border
//
//        return options
//    }
//}

extension CategoryDictionaryViewController {
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
