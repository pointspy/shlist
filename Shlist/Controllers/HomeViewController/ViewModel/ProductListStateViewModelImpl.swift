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

final class ProductListStateViewModelImpl: ProductListStateViewModel, ProductListStateViewModelInput, ProductListStateViewModelOutput {
    // MARK: Inputs
    
    var products: Observable<[Product]>
    var searchActive: BehaviorRelay<Bool> = .init(value: false)
    
    // MARK: Otputs
    
    let repository: ProductRepository
    
    var searchActiveDriver: Driver<Bool> {
        return searchActive.asDriver()
    }
    
    var newProducts: Observable<[Product]> {
        return repository.newItems
    }
    
    var completeProducts: Observable<[Product]> {
        return repository.completeItems
    }
    
    var productSections: Observable<[SectionOfProducts]> {
        products.flatMap { items -> Observable<[SectionOfProducts]> in
            
            var result: [SectionOfProducts] = []
            
            let newItems = items.filter { !$0.checked }
            
            if !newItems.isEmpty {
                let headProduct = Product(id: "Новые Заголовок", name: "Новые Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
                
                let sectionNewHeader = SectionOfProducts(header: "Новые Заголовок", items: [headProduct], type: .newHeader)
                
                result.append(sectionNewHeader)
                
                let sectionNew = SectionOfProducts(header: "Новые", items: newItems, type: .newContent)
                result.append(sectionNew)
                
                let footProduct = Product(id: "Новые Сумма", name: "Новые Сумма", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))

                let sectionNewSum = SectionOfProducts(header: "Новые Сумма", items: [footProduct], type: .newFooter)
                
                result.append(sectionNewSum)
            }
            
            let completeItems = items.filter { $0.checked }
            
            if !completeItems.isEmpty {
                let headProductComp = Product(id: "Comp Заголовок", name: "Comp Заголовок", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))

                let sectionCompHeader = SectionOfProducts(header: "Comp Заголовок", items: [headProductComp], type: .completeHeader)

                result.append(sectionCompHeader)
                
                let sectionComplete = SectionOfProducts(header: "В корзине", items: completeItems, type: .completeContent)
                result.append(sectionComplete)
                
                let footProductComp = Product(id: "Comp Сумма", name: "Comp Сумма", category: Category(name: "Служебные", colorHex: 0x000000, iconName: ""))
                
                let sectionCompSum = SectionOfProducts(header: "Comp Сумма", items: [footProductComp], type: .completeFooter)
                
                result.append(sectionCompSum)
            }
            
            return Observable<[SectionOfProducts]>.just(result)
        }
    }
    
    var bag = DisposeBag()
    
    init(repository: ProductRepository) {
        self.repository = repository
        self.products = repository.items.asObservable()
    }
}
