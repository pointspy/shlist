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
import Codextended

public final class ColorTypeWrapper: Codable {
    let id: String
    var color: UIColor = UIColor.systemBlue
    public private(set) var checked: Bool
    var colorHex: String
    
    init(id: String, color: UIColor, checked: Bool) {
        self.id = id
        self.color = color
        self.checked = checked
        self.colorHex = color.toHexString()
    }
    
    static let empty: ColorTypeWrapper = ColorTypeWrapper(id: UUID().uuidString, color: UIColor.systemBlue, checked: false)
    
    func setChecked(_ checked: Bool) {
        self.checked = checked
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case colorHex
        case checked
        
    }
    
    public init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        checked = try decoder.decode("checked")
        colorHex = try decoder.decode("colorHex")
        color = UIColor(hexString: colorHex)
    }

    public func encode(to encoder: Encoder) throws {
        
        self.colorHex = color.toHexString()
        
        try encoder.encode(colorHex, for: "colorHex")
        try encoder.encode(id, for: "id")
        try encoder.encode(checked, for: "checked")
        
    }
}

extension ColorTypeWrapper: Equatable, IdentifiableType {
    public typealias Identity = String
    
    public var identity: String {
        return id
    }
    
    public static func == (lhs: ColorTypeWrapper, rhs: ColorTypeWrapper) -> Bool {
        return lhs.id == rhs.id //&& lhs.checked == rhs.checked
    }
}

struct SectionOfColors {
    var id: String
    var items: [ColorTypeWrapper]
}

extension SectionOfColors: AnimatableSectionModelType {
    typealias Identity = String
    
    var identity: String {
        return id
    }
    
    typealias Item = ColorTypeWrapper
    
    init(original: SectionOfColors, items: [Item]) {
        self = original
        self.items = items
    }
}
