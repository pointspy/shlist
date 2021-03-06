//
//  ProductStateViewModel.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift

protocol CategoryDictionaryViewModelInput {
    var categoryRelay: BehaviorRelay<[Product]> { get }
    
}

protocol CategoryDictionaryViewModelOutput {
    var categoryDriver: Driver<[Product]> { get }
    var resultProductSections: Driver<[SectionOfProducts]> { get }
    
}

protocol CategoryDictionaryViewModel {
    var input: CategoryDictionaryViewModelInput { get }
    var output: CategoryDictionaryViewModelOutput { get }
}

extension CategoryDictionaryViewModel where Self: CategoryDictionaryViewModelInput & CategoryDictionaryViewModelOutput {
    var input: CategoryDictionaryViewModelInput { return self }
    var output: CategoryDictionaryViewModelOutput { return self }
}
