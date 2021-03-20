//
//  Rx-Ext.swift
//  Example2WayBinding
//
//  Created by Danny on 26.12.18.
//  Copyright © 2018 Danny. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension ObservableType {
    func currentAndPrevious() -> Observable<(current: Element, previous: Element)> {
        return self.multicast({ () -> PublishSubject<Element> in PublishSubject<Element>() }) { (values: Observable<Element>) -> Observable<(current: Element, previous: Element)> in
            let pastValues = Observable.merge(values.take(1), values)

            return Observable.combineLatest(values.asObservable(), pastValues) { current, previous in
                (current: current, previous: previous)
            }
        }
    }
}

public extension ObservableType where Element: IntTransformable {
    func asIntObservable() -> Observable<Int> {
        return self.map { element in
            element.asInt
        }
    }
}

public extension ObservableType where Element: DoubleTransformable {
    func asDoubleObservable() -> Observable<Double> {
        return self.map { element in
            element.asDouble
        }
    }
}

public extension ObservableType where Element == Double {
    func asIntObservable() -> Observable<Int> {
        return self.map { element in
            element.asInt
        }
    }
}

public extension ObservableType where Element == String {
    func asIntObservable() -> Observable<Int> {
        return self.map { element in
            element.asInt
        }
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Element: IntTransformable {
    func asIntDriver() -> Driver<Int> {
        return self.map { element in
            element.asInt
        }
    }
}
