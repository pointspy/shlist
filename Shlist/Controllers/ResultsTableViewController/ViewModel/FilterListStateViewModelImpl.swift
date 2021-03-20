//
//  ProductListStateViewModelImpl.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Action
import RxCocoa
import RxDataSources
import RxSwift
import SwiftEntryKit
import RxKeyboard

final class FilterListStateViewModelImpl: FilterListStateViewModel, FilterListStateViewModelInput, FilterListStateViewModelOutput {
    
    // MARK: Inputs
    
    let lastSearchDataSource: LastSearchDataSource
    let selectedCategory: BehaviorRelay<Category> = BehaviorRelay<Category>.init(value: Category.empty)
    var productsDictionary: BehaviorRelay<[Product]>
    var searchPhrase: BehaviorRelay<String> = BehaviorRelay<String>.init(value: "")
    var saveToDictionary: BehaviorRelay<Bool> = .init(value: false)
    var tapAddProductInput: BehaviorRelay<UITapGestureRecognizer> = .init(value: UITapGestureRecognizer())
    var searchVCRelay: BehaviorRelay<UISearchController?> = .init(value: nil)
    let searchActive: BehaviorRelay<Bool>
    
    // MARK: Otputs
    
    var tapAddProductOutput: Driver<UITapGestureRecognizer> {
        return tapAddProductInput.asObservable().when(.recognized).asDriver(onErrorJustReturn: UITapGestureRecognizer())
    }
    
    var searchVCDriver: Driver<UISearchController?> {
        return searchVCRelay.asDriver()
    }
    
    var saveToDictionaryResult: Driver<Bool> {
        saveToDictionary.asDriver()
    }
    var selectedCategoryResult: Driver<Category> {
        return selectedCategory.asDriver()
    }
    var needToDismiss: BehaviorRelay<Bool> = BehaviorRelay<Bool>.init(value: false)
    var addingProduct: BehaviorRelay<Product?> = BehaviorRelay<Product?>.init(value: nil)
    var lastSearchProducts: Driver<[Product]>
    var filteredProducts: Driver<[Product]>
    var resultProductSections: Driver<[SectionOfProducts]> {

        return Driver.combineLatest(filteredProducts, lastSearchProducts, searchPhrase.asDriver(), Settings.Store.selectedCategoryDataSource.items.asDriver())
            .flatMap { value -> Driver<[SectionOfProducts]> in
                var result: [SectionOfProducts] = []
                
                if value.2.count > 1, value.0.isEmpty {
                    let headProduct = Product(id: "Новая Заголовок", name: "Новая Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
                    let sectionNewHeader = SectionOfProducts(header: "Новая Заголовок", items: [headProduct], type: .addNewProductHeader)
                    result.append(sectionNewHeader)
                    let newP = Product(id: "Новая", name: "Новая", category: Category(name: Settings.Store.Category.other.name, colorHex: 0x000000, iconName: "\(Settings.Store.Category.other.rawValue)_checked"))
                    let sectionNew = SectionOfProducts(header: "Новый", items: [newP], type: .addNewProductCell)
                    result.append(sectionNew)
                    let headProductSettings = Product(id: "Настройки Заголовок", name: "Настройки Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
                    let sectionNewHeaderSettings = SectionOfProducts(header: "Настройки Заголовок", items: [headProductSettings], type: .addNewProductSettingsHeader)
                    result.append(sectionNewHeaderSettings)
                    let newPSettings = Product(id: "Настройки", name: "Настройки", category: Category(name: Settings.Store.Category.other.name, colorHex: 0x000000, iconName: "\(Settings.Store.Category.other.rawValue)_checked"))
                    let sectionNewSettings = SectionOfProducts(header: "Настройки", items: [newPSettings], type: .addNewProductSettingsContent)
                    result.append(sectionNewSettings)
                    let headProductCategory = Product(id: "Category Заголовок", name: "Category Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
                    let sectionNewHeaderCategory = SectionOfProducts(header: "Category Заголовок", items: [headProductCategory], type: .addNewProductChooseCategoryHeader)
                    result.append(sectionNewHeaderCategory)
                    
                    let sectionNewCategories = SectionOfProducts(header: "Category", items: value.3, type: .addNewProductChooseCategoryContent)
                    result.append(sectionNewCategories)
                    return BehaviorRelay<[SectionOfProducts]>.init(value: result).asDriver()
                }
                
                if !value.2.isEmpty {
                    let headProduct = Product(id: "Найденные Заголовок", name: "Найденные Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
                    let sectionNewHeader = SectionOfProducts(header: "Найденные Заголовок", items: [headProduct], type: .currentSearchHeader)
                    result.append(sectionNewHeader)
                    let sectionNew = SectionOfProducts(header: "Найдено", items: value.0, type: .currentSearchContent)
                    result.append(sectionNew)
                    
                } else if !value.1.isEmpty {
                    let headProduct = Product(id: "Последние Заголовок", name: "Последние Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
                    let sectionNewHeader = SectionOfProducts(header: "Последние Заголовок", items: [headProduct], type: .lastSearchHeader)
                    result.append(sectionNewHeader)
                    let sectionNew = SectionOfProducts(header: "Последние", items: value.1, type: .lastSearchContent)
                    result.append(sectionNew)
                    
                } else {
                    let headProduct = Product(id: "Введите Заголовок", name: "Введите Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
                    let sectionNewHeader = SectionOfProducts(header: "Введите Заголовок", items: [headProduct], type: .lastSearchHeader)
                    result.append(sectionNewHeader)
                }
                
                return BehaviorRelay<[SectionOfProducts]>.init(value: result).asDriver()
            }
    }
    
    var bag = DisposeBag()
    
    var keyboardHeight: CGFloat = 0
    
//    var customProductWasAdded: Bool = false
    
    init(dictionaryRelay: BehaviorRelay<[Product]>, lastSearchDataSource: LastSearchDataSource, searchActive: BehaviorRelay<Bool>) {
        self.lastSearchDataSource = lastSearchDataSource
        self.productsDictionary = dictionaryRelay
        self.searchActive = searchActive
        
        self.lastSearchProducts = lastSearchDataSource.items.asDriver()
        Settings.Store.selectedCategoryDataSource.selectedCategory.asDriver()
            .drive(self.selectedCategory)
            .disposed(by: bag)
        
        let filtered = Driver.combineLatest(productsDictionary.asDriver(), searchPhrase.asDriver())
            .throttle(RxTimeInterval.milliseconds(50))
           .flatMap { value -> Driver<[Product]> in
                var filteredArray: [Product] = []
                let (items, phrase) = value
                if !phrase.isEmpty {
                    filteredArray = items.filter { product in
                        product.name.lowercased().contains(phrase.lowercased())
                    }
                }
            return BehaviorRelay<[Product]>.init(value: filteredArray).asDriver()
        }
        
        filteredProducts = filtered
        
//        RxKeyboard.instance.willShowVisibleHeight
//            .withUnretained(self)
//            .drive(onNext: {owner, height in
//                owner.keyboardHeight = height
//            }, onCompleted: nil, onDisposed: nil)
//            .disposed(by: bag)
//
//
//
//        RxKeyboard.instance.isHidden
//            .throttle(.milliseconds(500))
//            .withUnretained(self)
//            .drive(onNext: {owner, flag in
//                if flag {
//                    owner.keyboardHeight = 0
//                }
//            }, onCompleted: nil, onDisposed: nil)
//            .disposed(by: bag)
        
        Driver.combineLatest(tapAddProductOutput, addingProduct.asDriver(), saveToDictionaryResult, RxKeyboard.instance.visibleHeight)
            .flatMapLatest { [weak self] value -> Driver<Bool> in
                let (recognizer, product, saveToDictionary, keboardHeight): (UITapGestureRecognizer, Product?, Bool, CGFloat) = value
                guard let self = self, let item = product, recognizer.state == .recognized /* , !self.customProductWasAdded */ else {
                    return BehaviorRelay<Bool>.init(value: false).asDriver()
                }
                
                if saveToDictionary {
                    Settings.Store.productDictionaryRepository.add(item: item) {_ in }
                }
                Settings.Store.productsRepo.add(item: item)
                self.lastSearchDataSource.setNew(item: item)
                
                let attrMessage = "\(item.name)".at.attributed {
                    $0.font(.boldSystemFont(ofSize: 15)).lineSpacing(5).alignment(.center)
                } + "\nТовар добавлен".at.attributed {
                    $0.font(.systemFont(ofSize: 13)).foreground(color: UIColor.secondaryLabel).lineSpacing(5).alignment(.center)
                }
                let toast = ToastView(attrMessage: attrMessage)
                
                SwiftEntryKit.display(entry: toast, using: ToastView.bottomFloatAttributes(keyboardHeight: keboardHeight))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    toast.play()
                })
                
                // self.customProductWasAdded = true
                return BehaviorRelay<Bool>.init(value: false).asDriver()
            }.drive(onNext: { [weak self] value in
                if value {
                    self?.needToDismiss.accept(value)
                }
            }).disposed(by: bag)
        
    }
}
