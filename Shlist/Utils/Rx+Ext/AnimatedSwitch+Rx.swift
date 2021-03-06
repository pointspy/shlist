//
//  AnimatedSwitch+Rx.swift
//  Shlist
//
//  Created by Pavel Lyskov on 17.01.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

#if os(iOS)

import Lottie
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: AnimatedSwitch {
    /// Reactive wrapper for `isOn` property.
    public var isOn: ControlProperty<Bool> {
        return value
    }

    /// Reactive wrapper for `isOn` property.
    ///
    /// ⚠️ Versions prior to iOS 10.2 were leaking `UISwitch`'s, so on those versions
    /// underlying observable sequence won't complete when nothing holds a strong reference
    /// to `UISwitch`.
    public var value: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { animatedSwitch in
            animatedSwitch.isOn
        }, setter: { animatedSwitch, value in
            animatedSwitch.setIsOn(value, animated: true)
        })
    }
}

#endif
