//
//  DataSourceProtocol.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift

public protocol SelectedCategoryDataSourceProtocol {
    associatedtype Item
    var items: BehaviorRelay<[Item]> { get }
    var allItems: [Item] { get }
    func setSelected(item: Item, result: @escaping (Bool) -> Void)
    var selectedCategory: BehaviorRelay<Category> { get }
}
