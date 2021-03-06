//
//  ProductStateViewModel.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift

protocol CategorySelectViewModelInput {
    var categories: BehaviorRelay<[Product]> { get }
    var selectedCategory: BehaviorRelay<Category> { get }
}

protocol CategorySelectViewModelOutput {
    var selectedCategoryDriver: Driver<Category> { get }
    var resultProductSections: Driver<[SectionOfProducts]> { get }
}

protocol CategorySelectViewModel {
    var input: CategorySelectViewModelInput { get }
    var output: CategorySelectViewModelOutput { get }
}

extension CategorySelectViewModel where Self: CategorySelectViewModelInput & CategorySelectViewModelOutput {
    var input: CategorySelectViewModelInput { return self }
    var output: CategorySelectViewModelOutput { return self }
}
