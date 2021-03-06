//
//  ProductStateViewModel.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift
import Action

protocol ChromaPickerServiceViewModelInput {
    var dataSourceColors: ColorsDataSource { get }
    
    var colorDoneTrigger: AnyObserver<UIColor> { get }
    var cancelTrigger: AnyObserver<Void> { get }

}

protocol ChromaPickerServiceViewModelOutput {
   
}

protocol ChromaPickerServiceViewModel {
    var input: ChromaPickerServiceViewModelInput { get }
    var output: ChromaPickerServiceViewModelOutput { get }
}

extension ChromaPickerServiceViewModel where Self: ChromaPickerServiceViewModelInput & ChromaPickerServiceViewModelOutput {
    var input: ChromaPickerServiceViewModelInput { return self }
    var output: ChromaPickerServiceViewModelOutput { return self }
}
