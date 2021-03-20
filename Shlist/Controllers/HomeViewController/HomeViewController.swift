//
//  ViewController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Action
import Closures
import DataCompression
import Ink
import Localize_Swift
import Lottie
import ObjectMapper
import Overture
import RxCocoa
import RxDataSources
import RxGesture
import RxKeyboard
import RxSwift
import RxSwiftExt
import SwiftEntryKit
import SwiftIcons
import UIKit

final class HomeViewController: UIViewController {
    lazy var markdownFile: MarkdownFile = {
        let file = MarkdownFile(fileUrl: Settings.Store.tasksMarkDownURL, content: [])
        return file
    }()
    
    lazy var emptyStateView = AnimationView(name: "newSadBag")
    lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor.label
        label.text = NSLocalizedString("HomeViewcontroller.emptyList", comment: "")
        return label
    }()
    
    lazy var emptyStateHideTransform: () -> () = {
        self.emptyStateView.alpha = 0
        self.emptyStateView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.emptyStateLabel.alpha = 0
    }
    
    lazy var emptyStateShowTransform: () -> () = {
        self.emptyStateView.alpha = 1
        self.emptyStateLabel.alpha = 1
        self.emptyStateView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    func showEmptyState() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: emptyStateShowTransform, completion: { [weak self] _ in
            self?.emptyStateView.play()
        })
    }
    
    func hideEmptyState() {
        emptyStateView.stop()
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: emptyStateHideTransform, completion: nil)
    }
    
    private func setupEmptyView() {
        tableView.addSubview(emptyStateView)
        tableView.addSubview(emptyStateLabel)
        
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            emptyStateView.widthAnchor.constraint(equalToConstant: 160),
            emptyStateView.heightAnchor.constraint(equalToConstant: 160),
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -160),
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateView.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
        emptyStateView.contentMode = .scaleAspectFit
        emptyStateHideTransform()
//        emptyStateView.animation = Lottie.Animation.named("sadEmptyBox")
        emptyStateView.loopMode = .loop
    }
    
    // MARK: - Constants
    
    private func factoryAccessoryButton() -> UIButton {
        let title = "Готово".at.attributed { t in
            t.font(.boldSystemFont(ofSize: 16)).foreground(color: .white)
        }
        let button = configure(UIButton()) {
            $0.setAttributedTitle(title, for: .normal)
            $0.backgroundColor = Settings.Colors.blue
            $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
            $0.onTap { [weak self] in
                self?.view.endEditing(true)
            }
            $0.fh.controlEnable(normalColor: Settings.Colors.blue, highlightedColor: Settings.Colors.blue.lighter())
        }
        
        return button
    }
    
    lazy var moreBarButton = UIBarButtonItem(image: UIImage(named: "moreButton"), style: .plain, handler: {})
    
    lazy var animConfig: AnimationConfiguration = {
        let config = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .automatic, deleteAnimation: .fade)
        return config
    }()
    
    lazy var animatedDataSource = RxTableViewSectionedAnimatedDataSource<SectionOfProducts>(animationConfiguration: self.animConfig,
                                                                                            configureCell: { [weak self] dataSource, tableView, indexPath, item in

                                                                                                guard let self = self else { return UITableViewCell() }

                                                                                                switch dataSource.sectionModels[indexPath.section].type {
                                                                                                case .newHeader:

                                                                                                    // NewProductHeader
                                                                                                    if let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductHeader", for: indexPath) as? NewProductHeader {
                                                                                                        cell.titleLabel.text = NSLocalizedString("HomeViewcontroller.table.new", comment: "")
                                                                                                        cell.setUp()
                                                                                                        cell.selectionStyle = .none

                                                                                                        return cell
                                                                                                    }
                                                                                                    return UITableViewCell()

                                                                                                case .newContent:

                                                                                                    return self.factoryProductCell(for: item, indexPath: indexPath, dataSource: dataSource)

                                                                                                case .newFooter:
                                                                                                    // FooterCell
                                                                                                    if let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell", for: indexPath) as? FooterCell {
                                                                                                        cell.setUp()
                                                                                                        cell.selectionStyle = .none

                                                                                                        let driverNewProduct: Driver<[Product]> = self.viewModel.output.newProducts
                                                                                                            .observe(on: MainScheduler.instance)
                                                                                                            .share(replay: 1, scope: .whileConnected)
                                                                                                            .asDriver(onErrorJustReturn: [])

                                                                                                        let totalDriver: Driver<Double> = driverNewProduct.flatMap { products -> Driver<Double> in

                                                                                                            let total: Double = products.reduce(0) { value, product in
                                                                                                                value + product.sum
                                                                                                            }

                                                                                                            return BehaviorRelay<Double>.init(value: total).asDriver()
                                                                                                        }

                                                                                                        totalDriver.drive(onNext: { total in
                                                                                                            cell.set(sum: total)
                                                                                                        }).disposed(by: cell.disposeBag)

//                    driverNewProduct.drive(onNext: {
//                        print("NEW products: \($0)")
//                    }).disposed(by: cell.disposeBag)

                                                                                                        return cell
                                                                                                    }
                                                                                                    return UITableViewCell()
                                                                                                case .completeHeader:
                                                                                                    if let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductHeader", for: indexPath) as? NewProductHeader {
                                                                                                        cell.titleLabel.text = NSLocalizedString("HomeViewcontroller.table.done", comment: "")
                                                                                                        cell.setUp()
                                                                                                        cell.selectionStyle = .none

                                                                                                        return cell
                                                                                                    }
                                                                                                    return UITableViewCell()
                                                                                                case .completeContent:
                                                                                                    return self.factoryProductCell(for: item, indexPath: indexPath, dataSource: dataSource)
                                                                                                case .completeFooter:
                                                                                                    if let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell", for: indexPath) as? FooterCell {
                                                                                                        cell.setUp()
                                                                                                        cell.selectionStyle = .none

                                                                                                        let driverCompleteProduct: Driver<[Product]> = self.viewModel.output.completeProducts
                                                                                                            .observe(on: MainScheduler.instance)
                                                                                                            .share(replay: 1, scope: .whileConnected)
                                                                                                            .asDriver(onErrorJustReturn: [])

                                                                                                        let totalDriver: Driver<Double> = driverCompleteProduct.flatMap { products -> Driver<Double> in

                                                                                                            let total: Double = products.reduce(0) { value, product in
                                                                                                                value + product.sum
                                                                                                            }

                                                                                                            return BehaviorRelay<Double>.init(value: total).asDriver()
                                                                                                        }

                                                                                                        totalDriver.drive(onNext: { total in
                                                                                                            cell.set(sum: total)
                                                                                                        }).disposed(by: cell.disposeBag)

//                    driverCompleteProduct.drive(onNext: {
//                        print("NEW products: \($0)")
//                    }).disposed(by: cell.disposeBag)

                                                                                                        return cell
                                                                                                    }
                                                                                                    return UITableViewCell()
                                                                                                default:
                                                                                                    return UITableViewCell()
                                                                                                }
                                                                                            })
    
    func getTextFrom(value: Double) -> String {
        let formatter = NumberFormatter()
//        formatter.maximumFractionDigits = 2
//        formatter.minimumFractionDigits = 2
//        formatter.decimalSeparator = "."
        formatter.allowsFloats = false
        
        return formatter.string(from: NSNumber(floatLiteral: value)) ?? ""
    }
    
    private func factoryProductCell(for item: Product, indexPath: IndexPath, dataSource: TableViewSectionedDataSource<SectionOfProducts>) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCellNew", for: indexPath) as? ProductCellNew else { return UITableViewCell() }
        
        var attrText = item.name.at.attributed {
            $0.font(.systemFont(ofSize: 16, weight: .medium))
        }
        
        if item.price > 0, item.count == 1 {
            attrText = attrText + "\n\(NSLocalizedString("common.price", comment: "")): ".at.attributed {
                $0.font(.systemFont(ofSize: 13)).foreground(color: UIColor.lightGray)
            } + "\(item.price.asPretty)\(NSLocalizedString("common.currency", comment: ""))".at.attributed {
                $0.font(.systemFont(ofSize: 13))
            }
        } else if item.price > 0, item.count > 0, item.count != 1.0 {
            attrText = attrText + "\n\(NSLocalizedString("common.price", comment: "")): ".at.attributed {
                $0.font(.systemFont(ofSize: 13)).foreground(color: UIColor.lightGray)
            } + "\(item.price.asPretty)\(NSLocalizedString("common.currency", comment: ""))".at.attributed {
                $0.font(.systemFont(ofSize: 13))
            } + " \(NSLocalizedString("common.quantity", comment: "")): ".at.attributed {
                $0.font(.systemFont(ofSize: 13)).foreground(color: UIColor.lightGray)
            } + "\(item.count.asPretty)".at.attributed {
                $0.font(.systemFont(ofSize: 13))
            } + " \(NSLocalizedString("common.sum", comment: "")): ".at.attributed {
                $0.font(.systemFont(ofSize: 13)).foreground(color: UIColor.lightGray)
            } + "\(item.sum.asPretty)\(NSLocalizedString("common.currency", comment: ""))".at.attributed {
                $0.font(.systemFont(ofSize: 13))
            }
        } else if item.price == 0, item.count != 1.0 {
            attrText = attrText + "\n\(NSLocalizedString("common.quantity", comment: "")): ".at.attributed {
                $0.font(.systemFont(ofSize: 13)).foreground(color: UIColor.lightGray)
            } + "\(item.count.asPretty)".at.attributed {
                $0.font(.systemFont(ofSize: 13))
            }
        }
        
        cell.nameLabel.attributedText = attrText
        
        let options: ProductCellOptions = [.single]
        
        cell.setUp(with: options, product: item)
        cell.set(checked: item.checked)
        
        cell.checkBoxView.valueChanged = { [weak self] value in
            cell.set(checked: value)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
                self?.repository.setChecked(value: value, for: item.id)
            }
        }
        
        return cell
    }
    
    // MARK: - Properties
    
    public private(set) var disposeBag = DisposeBag()
    
    lazy var repository = Settings.Store.productsRepo
    
    var viewModel: ProductListStateViewModel!
    
    @IBOutlet var tableView: UITableView!
    /// Search controller to help us with filtering.
    var searchController: UISearchController!
    
    /// The search results table view.
    var resultsTableViewController: ResultsTableViewController!
    
    /// Restoration state for UISearchController
//    var restoredState = SearchControllerRestorableState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEmptyView()
        
        tableView.register(cellType: ProductCellNew.self)
        tableView.register(cellType: NewProductHeader.self)
        tableView.register(cellType: FooterCell.self)
        
        if view.traitCollection.userInterfaceStyle == .dark {
            Settings.Colors.themeService.switch(.dark)
        } else {
            Settings.Colors.themeService.switch(.light)
        }
        
        navigationItem.title = NSLocalizedString("HomeViewcontroller.title", comment: "")
        navigationItem.rightBarButtonItem = moreBarButton
        
        let barButtonDriver: Driver<OutputAction> = moreBarButton.rx.tap.asDriver()
            .flatMap { _ -> Driver<OutputAction> in
                
                self.alert(title: NSLocalizedString("HomeViewcontroller.action_sheet", comment: ""),
                           message: "",
                           actions: [
                               AlertAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.export", comment: ""), type: 0, style: .default),
                               AlertAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.import", comment: ""), type: 3, style: .default),
                               AlertAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.markdown", comment: ""), type: 4, style: .default),
                               AlertAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.clear", comment: ""), type: 1, style: .destructive),
                               AlertAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.cancel", comment: ""), type: 2, style: .cancel)
                           ],
                           preferredStyle: .actionSheet, barButtonItem: self.moreBarButton)
                    .observe(on: MainScheduler.instance)
                    .share(replay: 1, scope: .whileConnected)
                    .asDriver(onErrorJustReturn: OutputAction.empty)
            }
        
        barButtonDriver.drive(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action.index {
            case 0:
                
                self.exportList()
            case 1:
                
                self.repository.removeAll()

            case 3:
                  
                self.importList()
            
            case 4:
                
                self.createMarkdownText()
                
            default:
                break
            }
        }).disposed(by: disposeBag)
        
        view.addTapGesture { [weak self] _ in
            self?.view.endEditing(true)
        }
        
        viewModel = ProductListStateViewModelImpl(repository: repository)
        
        let searchViewModel = FilterListStateViewModelImpl(dictionaryRelay: Settings.Store.productDictionaryRepository.items, lastSearchDataSource: Settings.Store.lastSearchDataSource, searchActive: viewModel.input.searchActive)
        resultsTableViewController = ResultsTableViewController(viewModel: searchViewModel, repository: repository)
        
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        
        let driveSearchVC: Driver<UISearchController?> = BehaviorRelay<UISearchController?>.init(value: searchController).asDriver()
        driveSearchVC.drive(searchViewModel.input.searchVCRelay)
            .disposed(by: disposeBag)
        
        resultsTableViewController.searchController = searchController
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.searchTextField.placeholder = NSLocalizedString("HomeViewcontroller.searchBar.placeholder", comment: "")
         
        searchController.searchBar.searchTextField.leftView = UIImageView(image: UIImage(named: "add_icon"))
        searchController.searchBar.setValue(NSLocalizedString("HomeViewcontroller.searchBar.close", comment: ""), forKey: "cancelButtonText")
        
        searchController.searchBar.returnKeyType = .done
        
        let searchPhraseDriver = searchController.rx.searchPhrase.observe(on: MainScheduler.instance)
            .share(replay: 1, scope: .whileConnected)
            .asDriver(onErrorJustReturn: "")
        
        searchPhraseDriver.drive(searchViewModel.input.searchPhrase)
            .disposed(by: disposeBag)
        
//        let phraseHistoryDriver = searchPhraseDriver.asObservable().pairwise()
//            .observe(on: MainScheduler.instance)
//            .share(replay: 1, scope: .whileConnected)
//            .asDriver(onErrorJustReturn: ("", ""))
        
//        Driver.combineLatest(phraseHistoryDriver, viewModel.output.searchActiveDriver)
//            .withUnretained(self)
//            .drive(onNext: { _, value in
//
//                let ((oldStr, newStr), isActive) = value
//
        ////                if newStr.isEmpty, oldStr.count > 1, isActive {
        ////                    DispatchQueue.main.async {
        ////                        self.searchController.dismiss(animated: true, completion: { [weak self] in
        ////                            guard let self = self else { return }
        ////                            self.viewModel.input.searchActive.accept(false)
        ////                        })
        ////                    }
        ////                }
//
//            }).disposed(by: disposeBag)
        
        searchController.rx.present.asDriver(onErrorJustReturn: ())
            .withUnretained(self)
            .drive(onNext: { owner, _ in
                 
                owner.searchController.showsSearchResultsController = true
                
            }).disposed(by: disposeBag)
        
        searchController.rx.didPresent
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.input.searchActive.accept(true)
            })
            .disposed(by: disposeBag)
        
        searchController.rx.didDismiss
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.input.searchActive.accept(false)
            })
            .disposed(by: disposeBag)
        
        searchController.rx.willDismiss
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                SwiftEntryKit.dismiss()
            })
            .disposed(by: disposeBag)
        
        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBackground : .secondarySystemBackground
        
        animatedDataSource.canEditRowAtIndexPath = { _, _ in
            true
        }

        viewModel.output.productSections
            .bind(to: tableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.productSections.asObservable()
            .asDriver(onErrorJustReturn: [])
            .throttle(.milliseconds(300))
            .drive(onNext: { [weak self] sections in
                if sections.isEmpty {
                    self?.showEmptyState()
                } else {
                    self?.hideEmptyState()
                }
            }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            
        Settings.Colors.themeService.rx
            .bind({ $0.backgroundColor }, to: view.rx.backgroundColor, tableView.rx.backgroundColor)
            .bind({ $0.menuButtonColor }, to: moreBarButton.rx.tintColor)
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        var insets = UIEdgeInsets()
        insets.top = 0
        tableView.contentInset = insets
        tableView.showsVerticalScrollIndicator = false
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else { return }
                
                self.tableView.contentInset.bottom = keyboardVisibleHeight + 20
                
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emptyStateView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 14.0, *) {
            configureActionItemMenu()
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func exportList() {
        if !Settings.Store.productsRepo.allItems.isEmpty {
            Settings.Store.saveItems(Settings.Store.productsRepo.allItems)
            let items: [Any] = [Settings.Store.tasksDocURL]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            ac.popoverPresentationController?.sourceView = view
            present(ac, animated: true)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("HomeViewcontroller.emptyList", comment: ""), message: NSLocalizedString("HomeViewcontroller.searchBar.emptyListMessage", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func importList() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["point.Shlist.exp.ShlistData"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    private func createMarkdownText() {
        let markDown = createMarkDown()
        
        var parser = MarkdownParser()
        let modifier = Modifier(target: .lists) { html, _ in
            
            let newHtml = html.replacingOccurrences(of: "[ ]", with: "⚪️").replacingOccurrences(of: "[x]", with: "🔵")
            
            return newHtml
        }
        parser.addModifier(modifier)
        let html = parser.html(from: markDown.markdown)
                  
        markdownFile.content = markDown
        do {
            try markdownFile.write()
        } catch {
            print("error")
        }
        let storyb = UIStoryboard(name: "Main", bundle: nil)
        
        if let vc = storyb.instantiateViewController(withIdentifier: "MarkDownViewController") as? MarkDownViewController {
            vc.loadViewIfNeeded()
            vc.contentMd = html
            vc.originalMarkDown = markDown.markdown
            let panNVC = PanNavigationController(contentVC: [vc])
            panNVC.setNavigationBarHidden(false, animated: false)
            panNVC.navigationBar.prefersLargeTitles = false
            presentPanModal(panNVC)
        }
    }
}

@available(iOS 14.0, *)
extension HomeViewController {
    func configureActionItemMenu() {
        let exportAction = UIAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.export", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
            guard let self = self else { return }
            self.exportList()
        }
        let importListAction = UIAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.import", comment: ""), image: UIImage(systemName: "square.and.arrow.down")) { [weak self] _ in
            guard let self = self else { return }
            self.importList()
        }
        
        let markdownAction = UIAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.markdown", comment: ""), image: UIImage(systemName: "doc.richtext")) { [weak self] _ in
            guard let self = self else { return }
            self.createMarkdownText()
        }
        
        let clearListAction = UIAction(title: NSLocalizedString("HomeViewcontroller.actionSheet.clear", comment: ""), image: UIImage(systemName: "xmark.square"), attributes: .destructive) { _ in
            self.repository.removeAll()
        }
        
        let menu = UIMenu(title: "", children: [markdownAction, exportAction, importListAction, clearListAction])
        
        moreBarButton.menu = menu
    }
}

// MARK: - UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        updateSearchResults(for: searchController)
    }
}

// MARK: - UISearchControllerDelegate

// Use these delegate functions for additional control over the search controller.

extension HomeViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        // Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        // Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        // Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        // Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        // Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch animatedDataSource.sectionModels[indexPath.section].type {
        case .newHeader:
            
            return UITableView.automaticDimension
            
        case .newContent:
            return UITableView.automaticDimension
        case .newFooter:
            return CGFloat(40)
        case .completeHeader:
            return UITableView.automaticDimension
        case .completeContent:
            return UITableView.automaticDimension
        case .completeFooter:
            return CGFloat(50)
        default:
            return CGFloat(40)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("dcsd")
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 || indexPath.section == 4 else { return nil }
        let sumAction = UIContextualAction(style: .normal, title: "\(NSLocalizedString("common.sum", comment: "")) \(NSLocalizedString("common.and", comment: "")) \(NSLocalizedString("common.quantity", comment: "").lowercased())") { _, _, completionHandler in
            // YOUR_CODE_HERE
            guard let cell = tableView.cellForRow(at: indexPath) as? ProductCellNew, let item = cell.product else { return }
        
            let relay: BehaviorRelay<(Double, Double)> = .init(value: (item.price, item.count))
            
            let inputView = NumberInputView()
            
            let inputVC = NumberInputViewController(with: inputView)
            
            let vm = NumberInputViewControllerViewModelImpl(product: item, valuesRelay: relay)
            
            inputVC.viewModel = vm
            
            relay.asDriver()
                .withUnretained(self)
                .drive(onNext: { result in
                
                    let (owner, values) = result
                      
                    var newItem = item
                    
                    newItem.set(price: values.0)
                    newItem.set(count: values.1)
                    owner.repository.set(item: newItem)
                }, onCompleted: nil, onDisposed: nil).disposed(by: self.disposeBag)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.presentPanModal(inputVC)
            }
            
            completionHandler(true)
        }
        sumAction.backgroundColor = .orange
        
        sumAction.backgroundColor = .orange
        
        let configuration = UISwipeActionsConfiguration(actions: [sumAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 || indexPath.section == 4 else { return nil }
        let deleteAction = UIContextualAction(style: .normal, title: "\(NSLocalizedString("common.remove", comment: ""))") { [weak self] _, _, completionHandler in
            // YOUR_CODE_HERE
            guard let self = self, let cell = tableView.cellForRow(at: indexPath) as? ProductCellNew, let item = cell.product else { return }
        
            self.repository.remove(item: item)
            completionHandler(true)
        }
        
        var saveToDictionaryAction: UIContextualAction?
        
        if let cell = tableView.cellForRow(at: indexPath) as? ProductCellNew, let item = cell.product {
            if Settings.Store.productDictionaryRepository.itemExist(item) {
                saveToDictionaryAction = UIContextualAction(style: .normal, title: "\(NSLocalizedString("common.removeFromDictionary", comment: ""))") { _, _, completionHandler in
                    
                    self.showOkCancel(message: "\(NSLocalizedString("common.removeFromDictionary.question", comment: ""))", okButtonTitle: "\(NSLocalizedString("common.continue", comment: ""))", successHandler: {
                        Settings.Store.productDictionaryRepository.remove(item: item)
                        self.showSimpleAlert(with: "", message: "\(NSLocalizedString("alert.removeFromDictionary.done", comment: ""))")
                        self.tableView.reloadData()
                    })
                    
                    completionHandler(true)
                }
            } else {
                saveToDictionaryAction = UIContextualAction(style: .normal, title: "\(NSLocalizedString("cell.addToDictionary", comment: ""))") { [weak self] _, _, completionHandler in
                   
                    self?.showOkCancel(message: "\(NSLocalizedString("alert.addToDictionary", comment: ""))", okButtonTitle: NSLocalizedString("common.continue", comment: ""), successHandler: {
                        Settings.Store.productDictionaryRepository.add(item: item) { [weak self] result in
                            if result {
                                self?.showSimpleAlert(with: "", message: "\(NSLocalizedString("alert.addToDictionary.done", comment: ""))")
                            } else {
                                self?.showSimpleAlert(with: "", message: "\(NSLocalizedString("alert.addToDictionary.fail", comment: ""))")
                            }
                            self?.tableView.reloadData()
                        }
                    })
                    
                    completionHandler(true)
                }
            }
        }
        
        let chooseCategoryAction = UIContextualAction(style: .normal, title: "\(NSLocalizedString("common.category", comment: ""))") { [weak self] _, _, completionHandler in
            guard let cell = tableView.cellForRow(at: indexPath) as? ProductCellNew, let item = cell.product else { return }
        
            let viewModel = CategorySelectViewModelImpl(categoriesRelay: Settings.Store.selectedCategoryDataSource.items, selectedCategoryRelay: Settings.Store.selectedCategoryDataSource.selectedCategory, for: item)
        
            Settings.Store.selectedCategoryDataSource.setDefaultSelected(for: item) { flag in
                print("flag flag: \(flag)")
            }
        
            let vc = CategorySelectViewController(viewModel: viewModel)
            let nvc = UINavigationController(rootViewController: vc)

            self?.present(nvc, animated: true, completion: nil)
        
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = 0xff453a.color
        saveToDictionaryAction?.backgroundColor = 0x787aff.color
        chooseCategoryAction.backgroundColor = 0x3293fc.color
        var actions = [deleteAction, chooseCategoryAction]
        if let saveAction = saveToDictionaryAction {
            actions.insert(saveAction, at: 1)
        }
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func getDoubleValue(from text: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = ","
        
        if let number = formatter.number(from: text) {
            return number.doubleValue
        } else {
            return nil
        }
    }
}

extension HomeViewController {
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

extension HomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let products = Settings.Store.loadItems(from: selectedFileURL)
        
        if !products.isEmpty {
            Settings.Store.productsRepo.set(items: products)
        }
    }
}

extension HomeViewController {
    func createMarkDown() -> [MarkdownConvertible] {
        let categoriesNames: [String] = repository.allItems.map { $0.category.name }
        
        let uniqCategories = categoriesNames.unique()
        
        var markdownData: [MarkdownConvertible] = [
            MarkdownHeader(title: NSLocalizedString("HomeViewcontroller.title", comment: ""), level: .h1),
            "---"
        ]
        
        for categoryName in uniqCategories {
            let categoryTitle = MarkdownHeader(title: "\(categoryName)", level: .h4, style: .atx, close: false)
            
            markdownData.append(categoryTitle)
            
            let items = repository.allItems.filter { item in
                item.category.name == categoryName
            }
            
            let taskList = MarkdownTaskList(items: items)
            
            markdownData.append(taskList)
        }
        
        let sum = repository.allItems.reduce(0) { result, product in
            result + product.sum
        }.asInt
        markdownData.append("---")
        let sumStr = "**\(NSLocalizedString("common.totalSum", comment: "")): `\(sum)\(NSLocalizedString("common.currency", comment: ""))`**".blockquoted
        markdownData.append(sumStr)
        markdownData.append("\n")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        let strDate: String = dateFormatter.string(from: Date())
        
        let remark = "<small>Shlist app iOS. \(strDate)</small>"
        
        markdownData.append(remark)
        
        return markdownData
    }
}
