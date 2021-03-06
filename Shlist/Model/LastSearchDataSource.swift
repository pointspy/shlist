//
//  LastSearchDataSource.swift
//  Shlist
//
//  Created by Pavel Lyskov on 20.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Overture
import RxCocoa
import RxSwift

public final class LastSearchDataSource: LastSearchDataSourceProtocol {
    public typealias Item = Product
    
    let maxCount: Int = 10
    
    public var allItems: [Product] {
        return localItems
    }
    
    private var localItems: [Item] = []
    private let updatedRelay: BehaviorRelay<[Item]> = .init(value: [])
    
    public var items: BehaviorRelay<[Item]> {
        return updatedRelay
    }
    
    public func setNew(item: Product) {
        if let index = localItems.firstIndex(of: item) {
            var itemsTemp = allItems
            
            itemsTemp.remove(at: index)
            itemsTemp.insert(item, at: 0)
            
            localItems = itemsTemp
            
        } else if localItems.count == maxCount {
            var itemsTemp = allItems.dropLast()
            itemsTemp.insert(item, at: 0)
            
            localItems = Array(itemsTemp)
            
        } else {
            var itemsTemp = allItems
            itemsTemp.insert(item, at: 0)
            
            localItems = Array(itemsTemp)
        }
        
        store.set(productsLastStoreValue, value: localItems)
        updatedRelay.accept(localItems)
    }
    
    public func set(items: [Item]) {
        localItems = items
        updatedRelay.accept(localItems)
    }
    
    
}
