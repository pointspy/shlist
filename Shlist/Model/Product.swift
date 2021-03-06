//
//  Product.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Foundation
import ObjectMapper
import ResilientDecoding
import RxDataSources
import SwiftIcons
import UIKit

public struct Category: Codable, Equatable {
    var name: String
    var colorHex: Int
    var iconName: String
    var imageIconTypeRaw: Int?
    
    private enum CodingKeys: String, CodingKey {
        case name, colorHex, iconName, imageIconTypeRaw
    }
    
    static let empty = Category(name: "Другое", colorHex: 0, iconName: "other")
    
    public static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name &&
            lhs.colorHex == rhs.colorHex &&
            lhs.iconName == rhs.iconName &&
            lhs.imageIconTypeRaw == rhs.imageIconTypeRaw
    }
}

public struct Product: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case category
        case price
        case id
        case checked
        case count
    }
    
    // MARK: - Properties
    
    static let empty = Product(id: "empty", name: "", category: Category.empty, checked: false)
    
    public let id: String
    var name: String
    var category: Category
    var price: Double = 0
    var count: Double = 1
    
    var sum: Double {
        return price * count
    }
    
    public var checked: Bool
    
    static let priceFormatter = NumberFormatter()
    
    // MARK: - Initializers
    
    func setup() {
//        Product.priceFormatter.numberStyle = .currency
        Product.priceFormatter.allowsFloats = false
//        Product.priceFormatter.formatterBehavior = .default
    }
    
    init(id: String, name: String, category: Category, checked: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.checked = checked
        setup()
    }
    
    // MARK: - Formatters
    
    func formattedPrice() -> String? {
        /** Build the price string.
         Use the priceFormatter to obtain the formatted price of the product.
         */
        return Product.priceFormatter.string(from: NSNumber(value: price))
    }
    
    static func toPrice(with text: String?) -> Double? {
        guard let text = text else {
            return nil
        }
        
        let clearText = text.replacingOccurrences(of: "₽", with: "")
        
        return priceFormatter.number(from: clearText)?.doubleValue
    }
    
    mutating func set(price: Double) {
        self.price = price
    }
    
    mutating func set(count: Double) {
        self.count = count
    }
    
    mutating func set(checked: Bool) {
        self.checked = checked
    }
    
    mutating func setCategory(_ category: Category) {
        self.category = category
    }
    
    mutating func toggle() {
        set(checked: !checked)
    }
}

extension Product: MarkdownTaskCompletable {
    func getTextFrom(value: Double) -> String {
        let formatter = NumberFormatter()

        formatter.allowsFloats = false
        
        return formatter.string(from: NSNumber(floatLiteral: value)) ?? ""
    }
    
    public var markdown: String {
        var result = checked ? "~~\(name)~~" : "\(name)"
        let tail: String
        if price > 0, count == 1 {
            tail = "` \(getTextFrom(value: price))₽ `"
        } else if price > 0, count > 0, count != 1.0 {
            tail = "` \(getTextFrom(value: price))₽ x \(getTextFrom(value: count)) = \(getTextFrom(value: sum))₽ `"
            
        } else if price == 0, count != 1.0 {
            tail = "` \(getTextFrom(value: count)) `"
        } else {
            tail = ""
        }
        
        result = result + " " + tail
        
        return result
    }
}

extension Product: Equatable, IdentifiableType {
    public typealias Identity = String
    
    public var identity: String {
        return id
    }
    
    public static func == (lhs: Product, rhs: Product) -> Bool {
        return (lhs.id == rhs.id) && (lhs.checked == rhs.checked) && (lhs.category.name == rhs.category.name) && (lhs.price == rhs.price) && (lhs.count == rhs.count)
    }
}

struct SectionOfProducts {
    var header: String
    var items: [Product]
    var type: SectionType
}

extension SectionOfProducts: AnimatableSectionModelType {
    typealias Identity = String
    
    var identity: String {
        return type.rawValue
    }
    
    typealias Item = Product
    
    init(original: SectionOfProducts, items: [Item]) {
        self = original
        self.items = items
    }
}

enum SectionType: String {
    case newHeader
    case newContent
    case newFooter
    case completeHeader
    case completeContent
    case completeFooter
    case lastSearchHeader
    case lastSearchContent
    case currentSearchHeader
    case currentSearchContent
    case addNewProductHeader
    case addNewProductCell
    case addNewProductSettingsHeader
    case addNewProductSettingsContent
    case addNewProductChooseCategoryHeader
    case addNewProductChooseCategoryContent
}

extension Product: PrettyPrintable {}
extension Category: PrettyPrintable {}
extension Product: JSONSerializable {}
extension Category: JSONSerializable {}

extension Category: ImmutableMappable {
    public init(map: Map) throws {
        name = try map.value("name")
        colorHex = try map.value("colorHex")
        iconName = try map.value("iconName")
        imageIconTypeRaw = try map.value("imageIconTypeRaw")
    }
    
    public mutating func mapping(map: Map) {
        name <- map["name"]
        colorHex <- map["colorHex"]
        iconName <- map["iconName"]
        imageIconTypeRaw <- map["imageIconTypeRaw"]
    }
}

extension Product: ImmutableMappable {
    public init(map: Map) throws {
        id = try map.value("id")
        name = try map.value("name")
        category = try map.value("category")
        price = try map.value("price")
        checked = try map.value("checked")
        count = try map.value("count")
    }
    
    public mutating func mapping(map: Map) {
        id >>> map["id"]
        name <- map["name"]
        category <- map["category"]
        price <- map["price"]
        checked <- map["checked"]
        count <- map["count"]
    }
}

extension SectionOfProducts: ImmutableMappable {
    init(map: Map) throws {
        header = try map.value("header")
        items = try map.value("items")
        type = try map.value("type")
    }
    
    mutating func mapping(map: Map) {
        header <- map["header"]
        items <- map["items"]
        type <- map["type"]
    }
}

public extension Product {
    var jsonString: String? {
        return Mapper().toJSONString(self, prettyPrint: false)
    }
}
