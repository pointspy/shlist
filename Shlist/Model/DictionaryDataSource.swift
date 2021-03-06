//
//  ProductDataSource.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Overture
import RxCocoa
import RxSwift

public final class DictionaryDataSource: LocalDataSourceProtocol {
    public typealias Item = Product
    
    public var allItems: [Item] {
        return localItems
    }
    
    private var localItems: [Item] = []
    private let updatedRelay: BehaviorRelay<[Item]> = .init(value: [])
    
    public var items: BehaviorRelay<[Item]> {
        return updatedRelay
    }
    
    public func set(item: Item) {

        guard let index = localItems.firstIndex(where: { $0.id == item.id }) else { return }
        var newItems = localItems
        newItems[index] = item
        localItems = newItems
        store.set(productsDictionaryValue, value: newItems)
        updatedRelay.accept(newItems)
    }
    
    public func add(item: Item, completion: @escaping (Bool) -> Void) {
        var newItems = localItems
        newItems.append(item)
        localItems = newItems
        
        updatedRelay.accept(newItems)
        store.set(productsDictionaryValue, value: newItems)
        completion(true)
    }
    
    public func getItem(withId id: String) -> Item? {
        guard let index = localItems.firstIndex(where: { $0.id == id }) else { return nil }
        return localItems[index]
    }
    
    public func itemExist(_ item: Item) -> Bool {
        return localItems.contains(where: {
            $0.name == item.name && $0.category == item.category
        })
    }
    
    public func set(items: [Item]) {
        localItems = items
        updatedRelay.accept(items)
    }
    
    public func remove(item: Item) {
        
        var newItems = localItems
        
        newItems.removeAll { product in
            item.name == product.name && item.category == product.category
         }
        localItems = newItems
        store.set(productsDictionaryValue, value: newItems)
        updatedRelay.accept(newItems)
    }
    
    public func getIndex(for item: Item) -> Int? {
        return localItems.firstIndex(of: item)
    }
    
    public func getItemWithText(_ text: String) -> Item? {
        
        return localItems.first(where: {item in
            item.category.name == text
        })
        
    }
}

