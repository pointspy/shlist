//
//  Array + EnumeratedMap.swift
//  Shlist
//
//  Created by Pavel Lyskov on 24.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Foundation

extension Array {
    public func enumeratedMap<T>(_ transform: (Int, Element) -> T) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        
        for (index, element) in enumerated() {
            result.append(transform(index, element))
        }
        
        return result
    }
    
    public func enumeratedMap<T>(_ transform: (Int, Element) -> T, completion: @escaping () -> Void) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        
        for (index, element) in enumerated() {
            result.append(transform(index, element))
        }
        
        completion()
        return result
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
