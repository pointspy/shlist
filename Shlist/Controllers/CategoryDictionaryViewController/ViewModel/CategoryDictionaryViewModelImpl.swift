//
//  CategoryDictionaryViewModelImpl.swift
//  Shlist
//
//  Created by Pavel Lyskov on 28.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Action
import RxCocoa
import RxDataSources
import RxSwift

final class CategoryDictionaryViewModelImpl: CategoryDictionaryViewModel, CategoryDictionaryViewModelInput, CategoryDictionaryViewModelOutput {
    // MARK: Inputs
    
    var categoryRelay: BehaviorRelay<[Product]>
    var dataSource: SelectedCategoryDataSource
    
    // MARK: Otputs
    
    var categoryDriver: Driver<[Product]> {
        self.categoryRelay.asDriver()
    }
    
    var resultProductSections: Driver<[SectionOfProducts]> {
        return self.categoryDriver
            .flatMap { items -> Driver<[SectionOfProducts]> in
                var result: [SectionOfProducts] = []
                
                let sortedItems = items.sorted {
                    $0.name < $1.name
                }
                
                let sectionNewCategories = SectionOfProducts(header: "Category", items: sortedItems, type: .addNewProductChooseCategoryContent)
                result.append(sectionNewCategories)
                return BehaviorRelay<[SectionOfProducts]>.init(value: result).asDriver()
            }
    }
    
    init(dataSource: SelectedCategoryDataSource) {
        self.categoryRelay = dataSource.items
        self.dataSource = dataSource
    }
}
