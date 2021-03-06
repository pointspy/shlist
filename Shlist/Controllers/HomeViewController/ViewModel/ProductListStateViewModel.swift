//
//  ProductStateViewModel.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ProductListStateViewModelInput {
    var products: Observable<[Product]> { get }
    var searchActive: BehaviorRelay<Bool> { get }
}

protocol ProductListStateViewModelOutput {
    var newProducts: Observable<[Product]> { get }
    var completeProducts: Observable<[Product]> { get }
    var productSections: Observable<[SectionOfProducts]> { get }
    var searchActiveDriver: Driver<Bool> { get }
}

protocol ProductListStateViewModel {
    var input: ProductListStateViewModelInput { get }
    var output: ProductListStateViewModelOutput { get }
}

extension ProductListStateViewModel where Self: ProductListStateViewModelInput & ProductListStateViewModelOutput {
    var input: ProductListStateViewModelInput { return self }
    var output: ProductListStateViewModelOutput { return self }
}
