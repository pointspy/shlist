//
//  ProductStateViewModel.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift

protocol FilterListStateViewModelInput {
    var productsDictionary: BehaviorRelay<[Product]> { get }
    var searchPhrase: BehaviorRelay<String> { get }
    var lastSearchDataSource: LastSearchDataSource { get }
    var selectedCategory: BehaviorRelay<Category> { get }
    var saveToDictionary: BehaviorRelay<Bool> { get }
    var tapAddProductInput: BehaviorRelay<UITapGestureRecognizer> { get }
    var searchVCRelay: BehaviorRelay<UISearchController?> { get }
    var searchActive: BehaviorRelay<Bool> { get }
}

protocol FilterListStateViewModelOutput {
    var lastSearchProducts: Driver<[Product]> { get }
    var filteredProducts: Driver<[Product]> { get }
    var resultProductSections: Driver<[SectionOfProducts]> { get }
    var addingProduct: BehaviorRelay<Product?> { get }
    var saveToDictionaryResult: Driver<Bool> { get }
    var selectedCategoryResult: Driver<Category> { get }
    var tapAddProductOutput: Driver<UITapGestureRecognizer> { get }
    var needToDismiss: BehaviorRelay<Bool> { get }
    var searchVCDriver: Driver<UISearchController?> { get }
}

protocol FilterListStateViewModel {
    var input: FilterListStateViewModelInput { get }
    var output: FilterListStateViewModelOutput { get }
}

extension FilterListStateViewModel where Self: FilterListStateViewModelInput & FilterListStateViewModelOutput {
    var input: FilterListStateViewModelInput { return self }
    var output: FilterListStateViewModelOutput { return self }
}
