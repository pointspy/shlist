//
//  ChromaPickerServiceViewModelImpl.swift
//  Shlist
//
//  Created by Pavel Lyskov on 01.05.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Action
import RxCocoa
import RxSwift
import RxSwiftExt
import SwiftEntryKit

final class ChromaPickerServiceViewModelImpl: ChromaPickerServiceViewModel, ChromaPickerServiceViewModelInput, ChromaPickerServiceViewModelOutput {
    
    public private(set) var disposeBag = DisposeBag()
    
    // MARK: Inputs
    var dataSourceColors: ColorsDataSource
    
    private(set) lazy var colorDoneTrigger = colorDoneAction.inputs
    private(set) lazy var cancelTrigger = cancelAction.inputs
    
    var colorRelay: BehaviorRelay<UIColor> = .init(value: .white)
    
    var textFieldEnterAction: Action<UIViewPropertyAnimator, Never> = Action { animator in
        
        
        return animator.rx.animate().asObservable()
        
    }
    
    var textFieldiExitAction: Action<UIViewPropertyAnimator, Never> = Action { animator in
        
        return animator.rx.animate().asObservable()
        
    }
    
    lazy var colorDoneAction: Action<UIColor, Void> = Action<UIColor, Void> { color in
        
        let colorWrap = ColorTypeWrapper(id: color.toHexString(), color: color, checked: true)
        self.dataSourceColors.changeLastItemWith(newItem: colorWrap)
        self.dataSourceColors.setSelected(item: colorWrap) { _ in }
        
        SwiftEntryKit.dismiss()
        return Observable<Void>.empty()
    }
    
    lazy var cancelAction: Action<Void, Void> = Action<Void, Void> {
        SwiftEntryKit.dismiss()
        return Observable<Void>.empty()
    }
    
    
    // MARK: Otputs
    
    init(dataSourceColors: ColorsDataSource) {
        
        self.dataSourceColors = dataSourceColors
        
    }
    
}
