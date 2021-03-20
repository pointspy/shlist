//
//  NumberInputViewControllerViewModel.swift
//  Shlist
//
//  Created by Pavel Lyskov on 08.02.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift
import Action

protocol NumberInputViewControllerViewModelInput {
    
//    var quantityTrigger: AnyObserver<Int> { get }
//    var priceTrigger: AnyObserver<(Int, Int)> { get }
    
    var okTrigger: AnyObserver<(Double, Double)> { get }
    var cancelTrigger: AnyObserver<Void> { get }
    var product: Product { get }
}

protocol NumberInputViewControllerViewModelOutput {
    var valuesDriver: Driver<(Double, Double)> { get }
    
}

protocol NumberInputViewControllerViewModel {
    var input: NumberInputViewControllerViewModelInput { get }
    var output: NumberInputViewControllerViewModelOutput { get }
}

extension NumberInputViewControllerViewModel where Self: NumberInputViewControllerViewModelInput & NumberInputViewControllerViewModelOutput {
    var input: NumberInputViewControllerViewModelInput { return self }
    var output: NumberInputViewControllerViewModelOutput { return self }
}
