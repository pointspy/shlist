//
//  CategorySelectViewController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 23.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//
import Reusable
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class CategorySelectViewController: UIViewController {
    lazy var tableView = UITableView()
    
    lazy var animatedDataSource = RxTableViewSectionedAnimatedDataSource<SectionOfProducts>(animationConfiguration:
        self.animConfig,
                                                                                            
        configureCell: { [weak self] dataSource, tableView, indexPath, item in
            
            guard let self = self else { return UITableViewCell() }
            
            switch dataSource.sectionModels[indexPath.section].type {
            case .addNewProductChooseCategoryHeader:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductHeader", for: indexPath) as? NewProductHeader {
                    cell.titleLabel.text = "Укажите категорию"
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
        let options: ProductCellOptions = [.single]
        
        cell.setUp(with: options, product: item)
        cell.set(checked: item.checked)
        cell.checkMarkIsAvailable = true
        cell.setCheckMark(visible: !item.checked, animated: false)
        
        let tapRx = cell.backView.rx.tapGesture(configuration: { _, delegate in
            delegate.simultaneousRecognitionPolicy = .always // (default value)
            
        }).asDriver()
        
        tapRx.asObservable().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    cell.backView.fh.touchDown()
                    Settings.Store.selectedCategoryDataSource.setSelected(item: item) { _ in
                        cell.set(checked: false)
                        cell.setCheckMark(visible: true, animated: true)
                    }
                    self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
            .disposed(by: cell.disposeBag)
        
        tapRx.asObservable().when(.ended, .cancelled, .failed)
            .subscribe(onNext: { _ in
                cell.backView.fh.touchUp()
            }).disposed(by: cell.disposeBag)
        
        return cell
    }
    
    public private(set) var disposeBag = DisposeBag()
    
    lazy var doneBarButton: UIBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, handler: {
        self.dismiss(animated: true, completion: nil)
    })
    
    let viewModel: CategorySelectViewModelImpl
    
    lazy var animConfig: AnimationConfiguration = {
        let config = AnimationConfiguration(
            insertAnimation: .fade, reloadAnimation: .automatic, deleteAnimation: .fade)
        return config
    }()
    
    init(viewModel: CategorySelectViewModelImpl) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = doneBarButton
        navigationController?.navigationBar.prefersLargeTitles = false
        
        view.addSubview(tableView)
        tableView.register(cellType: NewProductCell.self)
        tableView.register(cellType: NewProductHeader.self)
        
        if self.view.traitCollection.userInterfaceStyle == .dark {
            Settings.Colors.themeService.switch(.dark)
        } else {
            Settings.Colors.themeService.switch(.light)
        }
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor.systemBackground : .secondarySystemBackground
        
        Settings.Colors.themeService.rx
            .bind({ $0.backgroundColor }, to: self.view.rx.backgroundColor, self.tableView.rx.backgroundColor)
            .disposed(by: self.disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        var insets = UIEdgeInsets()
        insets.top = 8
        tableView.contentInset = insets
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        
        viewModel.output.resultProductSections.asObservable()
            .bind(to: tableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension CategorySelectViewController {
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

extension CategorySelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.animatedDataSource.sectionModels[indexPath.section].type {
        case .lastSearchHeader, .currentSearchHeader:
            
            return 50.0
            
        case .lastSearchContent, .currentSearchContent:
            return CGFloat(56)
            
        default:
            return CGFloat(56)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? NewProductCell else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
