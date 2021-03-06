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
import SwiftIcons
import RxSwiftExt

public final class ColorsDataSource: LocalDataSourceProtocol {
    public typealias Item = ColorTypeWrapper
    
    public var allItems: [Item] {
        return localItems
    }
    
    public func setInitial() {
        let newItems = Settings.Colors.categoryColors.enumeratedMap {index, color in
            
            return index == 0 ? ColorTypeWrapper(id: "first.default.selected.color", color: color, checked: true) :
            ColorTypeWrapper(id: UUID().uuidString, color: color, checked: false)
        }
        
        self.localItems = newItems
        updatedRelay.accept(localItems)
        store.set(colorsDictionaryValue, value: localItems)
    }
    
    private var localItems: [Item] = []
    private lazy var updatedRelay: BehaviorRelay<[Item]> = .init(value: self.localItems)
    public let currentSelectedRelay: BehaviorRelay<Item> = Settings.Colors.categoryColors.isEmpty ? .init(value: .empty) : .init(value: ColorTypeWrapper(id: "first.default.selected.color", color: Settings.Colors.categoryColors[0] , checked: true))
    
    public var items: BehaviorRelay<[Item]> {
        return updatedRelay
    }
    
    public func set(item: Item) {

        guard let index = localItems.firstIndex(where: { $0.id == item.id }) else { return }
        localItems[index] = item
        
        updatedRelay.accept(localItems)
    }
    
    public func add(item: Item) {
        localItems.append(item)
        updatedRelay.accept(localItems)
    }
    
    public func getItem(withId id: String) -> Item? {
        guard let index = localItems.firstIndex(where: { $0.id == id }) else { return nil }
        return localItems[index]
    }
    
    public func getItemWithIndex(_ index: Int) -> Item? {
        guard index >= 0, index < localItems.count else {
            return nil
        }
        return localItems[index]
    }
    
    public func set(items: [Item]) {
        localItems = items
        
        updatedRelay.accept(localItems)
    }
    
    public func remove(item: Item) {
        localItems.removeAll { product in
            item.id == product.id
        }
   
        updatedRelay.accept(localItems)
    }
    
    public func getIndex(for item: Item) -> Int? {
        return localItems.firstIndex(of: item)
    }
}

extension ColorsDataSource {
    
    public func setSelected(item: Item, result: @escaping (Bool) -> Void) {
        var currentSelectedIndex: Int?
        
        guard let itemIndex = localItems.firstIndex(of: item) else {
            result(false)
            return
        }
         
        if  let indexSel = localItems.firstIndex(where: {
            $0.checked == true
        }) {
            currentSelectedIndex = indexSel
        }
        
        var newItems = localItems

        if  let currentSelectedIndex = currentSelectedIndex {
//            if currentSelectedIndex == itemIndex {
//                result(false)
//                return
//            }
            
            let currentSelected = localItems[currentSelectedIndex]
            currentSelected.setChecked(false)
            newItems[currentSelectedIndex] = currentSelected
        }

        let mutItem = item
        mutItem.setChecked(true)
        newItems[itemIndex] = mutItem
  
        localItems = newItems
        updatedRelay.accept(localItems)
        currentSelectedRelay.accept(mutItem)
        store.set(colorsDictionaryValue, value: localItems)
        result(true)
    }
    
    public func changeLastItemWith(newItem: Item) {
        
        localItems = localItems.dropLast()
        localItems.append(newItem)
        updatedRelay.accept(localItems)
        store.set(colorsDictionaryValue, value: localItems)
    }
    
}
