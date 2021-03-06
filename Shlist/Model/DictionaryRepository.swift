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

final class DictionaryRepository {
    private let localDS: DictionaryDataSource
    typealias Item = Product
    
    init(localDS: DictionaryDataSource) {
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
     
    func remove(item: Item) {
        localDS.remove(item: item)
    }
    
    func add(item: Item, completion: @escaping (Bool) -> Void) {
        guard !localDS.itemExist(item) else {
            completion(false)
            return
        }
        
        let newItem = Product(id: UUID().uuidString, name: item.name, category: item.category, checked: item.checked)
        localDS.add(item: newItem, completion: completion)
    }
    
    public func itemExist(_ item: Item) -> Bool {
        return localDS.itemExist(item)
    }
    
    public func getItemWithText(_ text: String) -> Item? {
        return localDS.getItemWithText(text)
    }
}
