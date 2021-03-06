//
//  DataSourceProtocol.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift

public protocol LastSearchDataSourceProtocol {
    associatedtype Item
    var items: BehaviorRelay<[Item]> { get }
    func setNew(item: Item)
    var allItems: [Item] { get }
    func set(items: [Item])
}
