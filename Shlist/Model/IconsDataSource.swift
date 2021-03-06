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

public final class IconsDataSource: LocalDataSourceProtocol {
    public typealias Item = IconTypeWrapper
    
    public var allItems: [Item] {
        return localItems
    }
    
    private var localItems: [Item] = {
        FASolidType.allCases.enumeratedMap {index, type in
            
            return index == 0 ? IconTypeWrapper(id: "first.default.selected.icon", type: type, checked: true) :
            IconTypeWrapper(id: UUID().uuidString, type: type, checked: false)
        }
    }()
    private lazy var updatedRelay: BehaviorRelay<[Item]> = .init(value: self.localItems)
    public let currentSelectedRelay: BehaviorRelay<Item> = FASolidType.allCases.isEmpty ? .init(value: .empty) : .init(value: IconTypeWrapper(id: "first.default.selected.icon", type: FASolidType.allCases[0], checked: true))
    
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

extension IconsDataSource {
    
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
            if currentSelectedIndex == itemIndex {
                result(false)
                return
            }
            
            var currentSelected = localItems[currentSelectedIndex]
            currentSelected.setChecked(false)
            newItems[currentSelectedIndex] = currentSelected
        }

        var mutItem = item
        mutItem.setChecked(true)
        newItems[itemIndex] = mutItem
  
        localItems = newItems
        updatedRelay.accept(localItems)
        currentSelectedRelay.accept(mutItem)
        result(true)
    }
    
}
