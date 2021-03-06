//
//  ResultsCollectionController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Reusable
import RxCocoa
import RxDataSources
import RxSwift
import UIKit
import RxKeyboard
import SwiftEntryKit

final class ResultsTableViewController: UIViewController {
    lazy var tableView = UITableView()
    
    let viewModel: FilterListStateViewModelImpl
    var searchController: UISearchController?
    
    lazy var animConfig: AnimationConfiguration = {
        let config = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .automatic, deleteAnimation: .fade)
        return config
    }()
    
    lazy var animatedDataSource = RxTableViewSectionedAnimatedDataSource<SectionOfProducts>(animationConfiguration:
        self.animConfig,
                                                                                            
        configureCell: { [weak self] dataSource, tableView, indexPath, item in
            
            guard let self = self else { return UITableViewCell() }
            
            switch dataSource.sectionModels[indexPath.section].type {
            case .currentSearchHeader:
                
                // NewProductHeader
                if let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductHeader", for: indexPath) as? NewProductHeader {
                    cell.titleLabel.text = "Найдено"
                    cell.setUp()
                    cell.selectionStyle = .none
                    
                    return cell
                }
                return UITableViewCell()
                
            case .currentSearchContent:
                
                return self.factoryProductCell(for: item, indexPath: indexPath, dataSource: dataSource)
                
            case .lastSearchHeader:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductHeader", for: indexPath) as? NewProductHeader {
                    cell.titleLabel.text = "Последние"
                    cell.setUp()
                    cell.selectionStyle = .none
                    
                    return cell
                }
                return UITableViewCell()
            case .lastSearchContent:
                return self.factoryProductCell(for: item, indexPath: indexPath, dataSource: dataSource)
            case .addNewProductHeader:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductHeader", for: indexPath) as? NewProductHeader {
                    cell.titleLabel.text = "Добавить"
                    cell.setUp()
                    cell.selectionStyle = .none
                    
                    return cell
                }
                return UITableViewCell()
            case .addNewProductCell:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "AddProductCell", for: indexPath) as? AddProductCell {
                    cell.setUp(with: .single, product: item)
                    let searchCap = self.viewModel.input.searchPhrase
                        .flatMap { str -> BehaviorRelay<String> in
                            var newStr = str
                            return BehaviorRelay<String>.init(value: newStr.capitalizingFirstLetter())
                        }.asDriver(onErrorJustReturn: "")
                        .asObservable()
                    
                    searchCap.bind(to: cell.nameLabel.rx.text)
                        .disposed(by: cell.disposeBag)
                    
                    let driveProduct = Observable.combineLatest(searchCap, self.viewModel.output.selectedCategoryResult.asObservable())
                        .flatMap { value -> Driver<Product?> in
                            
                            guard !value.0.isEmpty else {
                                return BehaviorRelay<Product?>.init(value: nil).asDriver()
                            }
                            
                            let prod = Product(id: UUID().uuidString, name: value.0, category: value.1, checked: false)
                            
                            return BehaviorRelay<Product?>.init(value: prod).asDriver()
                        }.asDriver(onErrorJustReturn: nil)
                    
                    driveProduct.drive(self.viewModel.output.addingProduct).disposed(by: cell.disposeBag)
                    
                    let tapRx = cell.backView.rx.tapGesture(configuration: { _, delegate in
                        delegate.simultaneousRecognitionPolicy = .always // (default value)
                        
                    }).asDriver()
                    
                    tapRx.drive(self.viewModel.input.tapAddProductInput)
                        .disposed(by: cell.disposeBag)
                    
                    tapRx.drive(onNext: { [weak self] rec in
                        
                        guard let self = self, let svc = self.searchController, rec.state == .recognized else { return }
                        svc.searchBar.text = ""
//                        svc.searchBar.becomeFirstResponder()
                    }).disposed(by: cell.disposeBag)
                    
                    return cell
                }
                return UITableViewCell()
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
                
            case .addNewProductSettingsHeader:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductHeader", for: indexPath) as? NewProductHeader {
                    cell.titleLabel.text = "Настройки"
                    cell.setUp()
                    cell.selectionStyle = .none
                    
                    return cell
                }
                return UITableViewCell()
            case .addNewProductSettingsContent:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as? SwitchCell {
                    cell.setUp(with: .single, product: item)
                    
                    cell.switchControl.rx.value.asDriver()
                        .drive(self.viewModel.input.saveToDictionary)
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                }
                return UITableViewCell()
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
    
    private func factoryProductCell(for item: Product, indexPath: IndexPath, dataSource: TableViewSectionedDataSource<SectionOfProducts>) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductCell", for: indexPath) as? NewProductCell else { return UITableViewCell() }
        
        cell.nameLabel.text = item.name
        
        self.viewModel.input.searchPhrase.asDriver()
            .drive(cell.searchRelay)
            .disposed(by: cell.disposeBag)
        
        
        let options: ProductCellOptions = [.single]
        
        cell.setUp(with: options, product: item)
        cell.set(checked: item.checked, whithoutChangeTextColor: true)
        cell.hidePrice()
        
        let tapRx = cell.backView.rx.tapGesture(configuration: { _, delegate in
            delegate.simultaneousRecognitionPolicy = .always // (default value)
            
        }).asDriver()
        
        tapRx.asObservable().when(.recognized)
            .withLatestFrom(RxKeyboard.instance.visibleHeight)
            .subscribe(onNext: { [weak self] keyboardHeight in
                guard let self = self, let svc = self.searchController else { return }
                cell.backView.fh.touchDown()
                
                let newP = Product(id: UUID().uuidString, name: item.name, category: item.category)
                DispatchQueue.main.async {
                    self.repository.add(item: newP)
                    
                    self.viewModel.input.lastSearchDataSource.setNew(item: item)
                    
                    let attrMessage = "\(item.name)".at.attributed {
                        $0.font(.boldSystemFont(ofSize: 15)).lineSpacing(5).alignment(.center)
                    } + "\nТовар добавлен".at.attributed {
                        $0.font(.systemFont(ofSize: 13)).foreground(color: UIColor.secondaryLabel).lineSpacing(5).alignment(.center)
                    }
                    let toast = ToastView(attrMessage: attrMessage)
                    SwiftEntryKit.display(entry: toast, using: ToastView.bottomFloatAttributes(keyboardHeight: keyboardHeight))
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                        toast.play()
                    })
                    
                    if let text = svc.searchBar.text, !text.isEmpty {
                        svc.searchBar.text = ""
//                        svc.searchBar.becomeFirstResponder()
                    } else {
//                        svc.dismiss(animated: true, completion: { [weak self] in
//                            self?.viewModel.input.searchActive.accept(false)
//                        })
                    }
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
    
    let repository: ProductRepository
    
    init(viewModel: FilterListStateViewModelImpl, repository: ProductRepository) {
        self.viewModel = viewModel
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var filteredProducts = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(cellType: NewProductCell.self)
        tableView.register(cellType: NewProductHeader.self)
        tableView.register(cellType: AddProductCell.self)
        tableView.register(cellType: SwitchCell.self)
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
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
        
//        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        guard let svc = self.searchController, let searchText = svc.searchBar.text, !searchText.isEmpty else { return }
        
        svc.searchBar.resignFirstResponder()
    }
}

extension ResultsTableViewController {
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

extension ResultsTableViewController: UITableViewDelegate {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let svc = self.searchController/*, let searchText = svc.searchBar.text, !searchText.isEmpty*/ else { return }
        
        svc.searchBar.resignFirstResponder()
    }
}
