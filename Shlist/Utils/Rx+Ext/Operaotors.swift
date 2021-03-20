//
//  Operaotors.swift
//  Example2WayBinding
//
//  Created by Danny on 26.12.18.
//  Copyright © 2018 Danny. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

infix operator <~>

func <~> <T: Equatable>(lhs: BehaviorRelay<T>, rhs: BehaviorRelay<T>) -> Disposable {
    typealias ItemType = (current: T, previous: T)
    
    return Observable.combineLatest(lhs.currentAndPrevious(), rhs.currentAndPrevious())
        .filter({ (first: ItemType, second: ItemType) -> Bool in
            return first.current != second.current
        })
        .subscribe(onNext: { (first: ItemType, second: ItemType) in
            if first.current != first.previous {
                rhs.accept(first.current)
            }
            else if (second.current != second.previous) {
                lhs.accept(second.current)
            }
        })
}

func <~> <T: Equatable>(lhs: ControlProperty<T>, rhs: BehaviorRelay<T>) -> Disposable {
    typealias ItemType = (current: T, previous: T)
    
    return Observable.combineLatest(lhs.currentAndPrevious(), rhs.currentAndPrevious())
        .filter({ (first: ItemType, second: ItemType) -> Bool in
            return first.current != second.current
        })
        .subscribe(onNext: { (first: ItemType, second: ItemType) in
            if first.current != first.previous {
                rhs.accept(first.current)
            }
            else if (second.current != second.previous) {
                lhs.onNext(second.current)
            }
        })
}

func <~> <T: IntTransformable>(lhs: BehaviorRelay<T>, rhs: BehaviorRelay<T>) -> Disposable {
    typealias ItemType = (current: T, previous: T)
    
    return Observable.combineLatest(lhs.currentAndPrevious(), rhs.currentAndPrevious())
        .filter({ (first: ItemType, second: ItemType) -> Bool in
            return first.current.asInt != second.current.asInt
        })
        .subscribe(onNext: { (first: ItemType, second: ItemType) in
            if first.current.asInt != first.previous.asInt {
                rhs.accept(first.current)
            }
            else if (second.current.asInt != second.previous.asInt) {
                lhs.accept(second.current)
            }
        })
}

func <~> (lhs: BehaviorRelay<String?>, rhs: BehaviorRelay<Double>) -> Disposable {
    typealias ItemType = (current: Double, previous: Double)
    
    return Observable.combineLatest(lhs.asObservable().map {$0 ?? "0"}.asDoubleObservable().currentAndPrevious(), rhs.asObservable().asDoubleObservable().currentAndPrevious())
        .observe(on: MainScheduler.asyncInstance)
        .filter({ (first: ItemType, second: ItemType) -> Bool in
            return first.current != second.current
        })
        .subscribe(onNext: { (first: ItemType, second: ItemType) in
            if first.current != first.previous {
                rhs.accept(first.current.asDouble)
            }
            else if (second.current != second.previous) {
                lhs.accept("\(second.current)")
            }
        })
}

func <~> (lhs: BehaviorRelay<String?>, rhs: BehaviorRelay<Int>) -> Disposable {
    typealias ItemType = (current: Int, previous: Int)
    
    return Observable.combineLatest(lhs.asObservable().map {$0 ?? "0"}.asIntObservable().currentAndPrevious(), rhs.asObservable().currentAndPrevious())
        .observe(on: MainScheduler.asyncInstance)
        .filter({ (first: ItemType, second: ItemType) -> Bool in
            return first.current != second.current
        })
        .subscribe(onNext: { (first: ItemType, second: ItemType) in
            if first.current != first.previous {
                rhs.accept(first.current)
            }
            else if (second.current != second.previous) {
                lhs.accept("\(second.current)")
            }
        })
}
