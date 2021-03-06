//
//  IconTypeWrapper.swift
//  Shlist
//
//  Created by Pavel Lyskov on 23.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Foundation
import RxDataSources
import UIKit
import SwiftIcons
import ObjectMapper

public final class IconTypeWrapper {
    let id: String
    var type: FASolidType?
    public private(set) var checked: Bool
    var selectedColor: UIColor = .systemBlue
    
    init(id: String, type: FASolidType?, checked: Bool) {
        self.id = id
        self.type = type
        self.checked = checked
    }
    
    static let empty: IconTypeWrapper = IconTypeWrapper(id: UUID().uuidString, type: nil, checked: false)
    
    func setChecked(_ checked: Bool) {
        self.checked = checked
    }
}

extension IconTypeWrapper: Equatable, IdentifiableType {
    public typealias Identity = String
    
    public var identity: String {
        return id
    }
    
    public static func == (lhs: IconTypeWrapper, rhs: IconTypeWrapper) -> Bool {
        return lhs.id == rhs.id //&& lhs.checked == rhs.checked
    }
}

struct SectionOfIcons {
    typealias Item = IconTypeWrapper
    var id: String
    var items: [IconTypeWrapper]
}

extension SectionOfIcons: AnimatableSectionModelType {
    typealias Identity = String
    
    var identity: String {
        return id
    }
    
    init(original: SectionOfIcons, items: [Item]) {
        self = original
        self.items = items
    }
}
