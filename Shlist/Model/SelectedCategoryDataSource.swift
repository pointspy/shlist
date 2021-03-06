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

public final class SelectedCategoryDataSource: SelectedCategoryDataSourceProtocol {
    public typealias Item = Product
    
    public var allItems: [Product] {
        return localItems
    }
    
    public var selectedCategory: BehaviorRelay<Category> = BehaviorRelay<Category>.init(value: Category.empty)
    
    private var localItems: [Item] = []
    
    private var sortdeItems: [Item] {
        localItems.sorted {
            $0.category.name < $1.category.name
        }
    }
    
    private lazy var updatedRelay: BehaviorRelay<[Item]> = .init(value: localItems)
    
    public var items: BehaviorRelay<[Item]> {
        return updatedRelay
    }
    
    public func setSelected(item: Item, result: @escaping (Bool) -> Void) {
        guard
            var currentSelected = localItems.first(where: {
                $0.checked == false
            })
        else {
            result(false)
            return
        }
        
        if currentSelected == item {
            result(false)
            return
        }
        
        var mutItem = item
        
        currentSelected.set(checked: true)
        mutItem.set(checked: false)
        
        set(item: currentSelected)
        
        let tail = Array(localItems.filter { $0 != item })
        
        let newItems = [mutItem] + tail
        
        localItems = newItems
        updatedRelay.accept(localItems)
        selectedCategory.accept(mutItem.category)
        result(true)
    }
    
    private func set(item: Item) {
        guard let index = localItems.firstIndex(where: { $0.id == item.id }) else { return }
        localItems[index] = item
    }
    
    public func setDefaultSelected(for item: Item, result: @escaping (Bool) -> Void) {
        guard var founded = localItems.first(where: { product in
            product.category.name == item.category.name
        }) else {
            result(false)
            return
        }
        
        var newItems = localItems
        newItems = newItems.compactMap { prod in
            var newP = prod
            newP.set(checked: true)
            return newP
        }
        
        newItems = newItems.filter { $0.category.name != founded.category.name }
        
        founded.set(checked: false)
        newItems = [founded] + newItems
        
        localItems = newItems
        updatedRelay.accept(newItems)
        selectedCategory.accept(founded.category)
    }
    
    public func initialCreate() {
        let allItems: [Item] = Settings.Store.Category.allCases.compactMap { category in
            
            let iconName: String = category.rawValue
            
            return Product(
                id: category.rawValue, name: category.name,
                category: Category(name: category.name, colorHex: 0, iconName: iconName),
                checked: true)
        }
        
        guard var item = allItems.first(where: { instanse in
            instanse.id == "other"
        }) else {
            return
        }
        
        item.set(checked: false)
        
        let tail = allItems.filter { $0.id != "other" }
        
        selectedCategory.accept(item.category)
        
        let newItems = [item] + tail
        
        localItems = newItems
        
        updatedRelay.accept(newItems)
        store.set(categoryDictionaryValue, value: newItems)
    }
    
    public func setItems(_ items: [Item]) {
        localItems = items
        updatedRelay.accept(items)
    }
    
    public func addItem(_ item: Item) {
        var newItems = localItems
        newItems.append(item)
        
        localItems = newItems
        
        updatedRelay.accept(newItems)
        store.set(categoryDictionaryValue, value: newItems)
    }
    
    public func removeItem(with index: Int) {
        guard index < localItems.count else {
            return
        }
        
        let item = sortdeItems[index]
        
        if let newIndex = localItems.firstIndex(where: {it in
            it.id == item.id
        }) {
            
            localItems.remove(at: newIndex)
            updatedRelay.accept(localItems)
            store.set(categoryDictionaryValue, value: localItems)
            
        }
        
        
    }
    
    public func isCustomCategory(for index: Int) -> Bool {
        let item = sortdeItems[index]
        
        return item.category.imageIconTypeRaw != nil || item.category.iconName.isEmpty
    }
}
