//
//  CategorySelectViewModelInputImpl.swift
//  Shlist
//
//  Created by Pavel Lyskov on 23.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt

final class CategorySelectViewModelImpl: CategorySelectViewModel, CategorySelectViewModelInput, CategorySelectViewModelOutput {
    
    // MARK: Input
    var categories: BehaviorRelay<[Product]>
    var selectedCategory: BehaviorRelay<Category>
    // MARK: Output
    var selectedCategoryDriver: Driver<Category> {
        return selectedCategory.asDriver()
    }
    
    var resultProductSections: Driver<[SectionOfProducts]> {
        
        return categories.asDriver().flatMapLatest {items -> Driver<[SectionOfProducts]> in
            var result: [SectionOfProducts] = []
            let headProductCategory = Product(id: "Category Заголовок", name: "Category Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
            let sectionNewHeaderCategory = SectionOfProducts(header: "Category Заголовок", items: [headProductCategory], type: .addNewProductChooseCategoryHeader)
            result.append(sectionNewHeaderCategory)
            
            let sectionNewCategories = SectionOfProducts(header: "Category", items: items, type: .addNewProductChooseCategoryContent)
            result.append(sectionNewCategories)
            return BehaviorRelay<[SectionOfProducts]>.init(value: result).asDriver()
        }
    }
    
    // MARK: Init
    
    let disposeBag = DisposeBag()
    
    init(categoriesRelay: BehaviorRelay<[Product]>, selectedCategoryRelay: BehaviorRelay<Category>, for item: Product) {
        self.categories = categoriesRelay
        self.selectedCategory = selectedCategoryRelay
        
        selectedCategoryDriver.asObservable()
            .pairwise()
            .observe(on: MainScheduler.instance)
            .share(replay: 1, scope: .whileConnected)
            .asDriver(onErrorJustReturn: (Category.empty, Category.empty))
            .drive(onNext: {value in
                let (old, new) = value
                guard old.name != new.name else {return}
                
                var newItem = item
                newItem.setCategory(new)
                
                Settings.Store.productsRepo.set(item: newItem)
                
                
            }).disposed(by: disposeBag)
        
    }
    
}
