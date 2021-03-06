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

public final class ProductDataSource: LocalDataSourceProtocol {
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
        localItems[index] = item
        
        store.set(productsStoreValue, value: localItems)
        updatedRelay.accept(localItems.sorted(by: { p1, p2 in
            p1.category.name < p2.category.name
            
        }))
    }
    
    public func add(item: Item) {
        localItems.append(item)
        store.set(productsStoreValue, value: localItems)
    
        updatedRelay.accept(localItems.sorted(by: { p1, p2 in
            p1.category.name < p2.category.name
            
        }))
    }
    
    public func getItem(withId id: String) -> Item? {
        guard let index = localItems.firstIndex(where: { $0.id == id }) else { return nil }
        return localItems[index]
    }
    
    public func set(items: [Item]) {
        localItems = items.sorted(by: { p1, p2 in
            p1.category.name < p2.category.name
            
        })
        store.set(productsStoreValue, value: localItems)
        updatedRelay.accept(localItems)
    }
    
    public func remove(item: Item) {
        localItems.removeAll { product in
            item.id == product.id
        }
        
        store.set(productsStoreValue, value: localItems)
        updatedRelay.accept(localItems.sorted(by: { p1, p2 in
            p1.category.name < p2.category.name
            
        }))
    }
    
    public func getIndex(for item: Item) -> Int? {
        return localItems.firstIndex(of: item)
    }
}

public extension ProductDataSource {
    func toggle(for productId: String) {
        guard let item = getItem(withId: productId) else { return }
        
        var newItem = item
        newItem.toggle()
        
        set(item: newItem)
    }
    
    func setChecked(value: Bool, for productId: String) {
        
        guard let item = getItem(withId: productId) else { return }
        
        var newItem = item
        newItem.set(checked: value)
        
        set(item: newItem)
        
    }
    
    var newItems: Observable<[Product]> {
        items.flatMap { itms -> Observable<[Product]> in
            let new = Array(itms.filter { !$0.checked })
            return .just(new)
        }
    }
    
    var completeItems: Observable<[Product]> {
        items.flatMap { itms -> Observable<[Product]> in
            let new = Array(itms.filter { $0.checked })
            return .just(new)
        }
    }
    
    func removeAll() {
        localItems.removeAll()
        updatedRelay.accept([])
        store.set(productsStoreValue, value: [])
    }
}
