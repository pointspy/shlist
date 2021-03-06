//
//  CategoryStyleMultipleSectionModel.swift
//  Shlist
//
//  Created by Pavel Lyskov on 24.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxDataSources
import UIKit

enum CategoryStyleMultipleSectionModel {
    case ColorsProvidableSection(title: String, items: [SectionItem])
    case IconsProvidableSection(title: String, items: [SectionItem])
    case SpaceProvidableSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case ColorsSectionItem(title: String, color: ColorTypeWrapper)
    case IconsSectionItem(title: String, icon: IconTypeWrapper)
    case SpaceSectionItem(title: String, height: CGFloat)
}

extension SectionItem: IdentifiableType, Equatable {
    public typealias Identity = String
    
    public var identity: String {
        return id
    }
    
    public static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    public var id: String {
        switch self {
        case let .ColorsSectionItem(title: title, color: color):
            return title + color.id
        case let .IconsSectionItem(title: title, icon: icon):
            return title + icon.id
        case let .SpaceSectionItem(title: title, height: height):
            return title + "\(height)"
        }
    }
}

extension CategoryStyleMultipleSectionModel: AnimatableSectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch self {
        case .ColorsProvidableSection(title: _, items: let items):
            return items.map { $0 }
        case .IconsProvidableSection(title: _, items: let items):
            return items.map { $0 }
        case .SpaceProvidableSection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    var id: String {
        switch self {
        case .ColorsProvidableSection(title: let title, items: _):
            return title
        case .IconsProvidableSection(title: let title, items: _):
            return title
        case .SpaceProvidableSection(title: let title, items: _):
            return title
        }
    }
    
    init(original: CategoryStyleMultipleSectionModel, items: [Item]) {
        switch original {
        case let .ColorsProvidableSection(title: title, items: _):
            self = .ColorsProvidableSection(title: title, items: items)
        case let .IconsProvidableSection(title: title, items: _):
            self = .IconsProvidableSection(title: title, items: items)
        case let .SpaceProvidableSection(title: title, items: items):
            self = .SpaceProvidableSection(title: title, items: items)
        }
    }
}

extension CategoryStyleMultipleSectionModel: IdentifiableType {
    public typealias Identity = String
    
    public var identity: String {
        return id
    }
    
    public static func == (lhs: CategoryStyleMultipleSectionModel, rhs: CategoryStyleMultipleSectionModel) -> Bool {
        return (lhs.id == rhs.id)
    }
}

extension CategoryStyleMultipleSectionModel {
    var title: String {
        switch self {
        case .ColorsProvidableSection(title: let title, items: _):
            return title
        case .IconsProvidableSection(title: let title, items: _):
            return title
        case .SpaceProvidableSection(title: let title, items: _):
            return title
        }
    }
}
