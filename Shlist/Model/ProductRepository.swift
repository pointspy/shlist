//
//  ProductRepository.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Action
import RxCocoa
import RxSwift

final class ProductRepository {
    private let localDS: ProductDataSource
    typealias Item = Product
    
    init(localDS: ProductDataSource) {
        self.localDS = localDS
    }
    
    public var items: BehaviorRelay<[Item]> {
        return localDS.items
    }
    
    public func set(item: Item) {
        localDS.set(item: item)
    }
    
    public func getItem(withID id: String) -> Item? {
        return localDS.getItem(withId: id)
    }
    
    public func set(items: [Item]) {
        localDS.set(items: items)
    }
    
    var allItems: [Item] {
        return localDS.allItems
    }
    
    func toggle(for productId: String) {
        localDS.toggle(for: productId)
    }
    
    func setChecked(value: Bool, for productId: String) {
        localDS.setChecked(value: value, for: productId)
    }
    
    var newItems: Observable<[Product]> {
        return localDS.newItems
    }
    
    var completeItems: Observable<[Product]> {
        return localDS.completeItems
    }
    
//    func set(price: Int, for product: Product) {
//        self.localDS.set(price: price, for: product)
//    }
    
    func remove(item: Item) {
        localDS.remove(item: item)
    }
    
    func removeAll() {
        localDS.removeAll()
    }
    
    func add(item: Item) {
        localDS.add(item: item)
    }
}
