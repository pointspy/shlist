//
//  Settings.swift
//  Shlist
//
//  Created by Pavel Lyskov on 10.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTheme
import Storez
import UIKit

protocol Theme {
    var priceFieldBackgroundColor: UIColor { get }
    var cellBackgroundColor: UIColor { get }
    var cellBackViewColor: UIColor { get }
    var cellBackViewColorHiglighted: UIColor { get }
    var backgroundColor: UIColor { get }
    var menuButtonColor: UIColor { get }
    var iconBackColor: UIColor { get }
    var iconMainColor: UIColor { get }
    var iconCheckColor: UIColor { get }
    var customCategoryCheck: UIColor { get }
    var textFieldCategoryNameHighlight: UIColor { get }
}

public enum Settings {
    enum Fonts {
        static let priceField = UIFont(name: "SFProRounded-Semibold", size: 16)!
        static let totalSumTitle = UIFont.systemFont(ofSize: 19)
        static let totalSumValue = UIFont(name: "SFProRounded-Bold", size: 19)!
        static let categoryName = UIFont(name: "SFProRounded-Bold", size: 21)!
        static let smallHeader = UIFont(name: "SFProRounded-Bold", size: 17)!
    }
    
    enum Colors {
        struct LightTheme: Theme {
            let priceFieldBackgroundColor = UIColor.secondarySystemBackground
            let cellBackgroundColor = UIColor.clear
            let backgroundColor: UIColor = 0xF2F2F7.color
            let cellBackViewColor = UIColor.white
            let cellBackViewColorHiglighted = UIColor.white.darkened()
            let menuButtonColor = UIColor.secondaryLabel
            let iconBackColor = UIColor.systemBackground.darkened(amount: 0.07)
            let textFieldCategoryNameHighlight = UIColor.systemBackground.darkened(amount: 0.14)
            let iconMainColor = UIColor.label
            let iconCheckColor = UIColor.label.lighter(amount: 0.75)
            let customCategoryCheck = UIColor.secondaryLabel
        }
        
        struct DarkTheme: Theme {
            let priceFieldBackgroundColor = UIColor.tertiarySystemBackground
            let cellBackgroundColor = UIColor.clear
            let backgroundColor: UIColor = 0x000000.color
            let cellBackViewColor: UIColor = 0x1C1C1E.color
            let cellBackViewColorHiglighted: UIColor = 0x1C1C1E.color.lighter()
            let menuButtonColor = UIColor.label
            let iconBackColor = UIColor.secondarySystemBackground.lighter(amount: 0.05)
            let textFieldCategoryNameHighlight = UIColor.secondarySystemBackground.lighter(amount: 0.1)
            let iconMainColor = UIColor.label
            let iconCheckColor = UIColor.label.darkened(amount: 0.5)
            let customCategoryCheck = UIColor.secondaryLabel
        }
        
        enum ThemeType: ThemeProvider {
            case light, dark
            var associatedObject: Theme {
                switch self {
                case .light:
                    return LightTheme()
                case .dark:
                    return DarkTheme()
                }
            }
        }
        
        static let themeService = ThemeType.service(initial: .light)
        
        static var blue: UIColor = 0x1880FA.color
        static var totalSumTitleColor = UIColor.secondaryLabel
        static var totalSumValueColor = UIColor.label
        
        static let nameChecked = UIColor.tertiaryLabel
        static let nameUnChecked = UIColor.label
        static let swipeActionCategory: UIColor = 0x2B30A8.color
        static let mainUncheckColor: UIColor = 0x5A6770.color
        
        static var categoryColors: [UIColor] = [.systemBlue, .systemRed, .systemPink, .systemIndigo, 0xFF7200.color, 0xFF9400.color, 0x02BCF4.color, 0xFF85AE.color, 0xEBBC00.color, 0x2B30A8.color]
    }
    
    enum Store {
        static func loadItems(from url: URL? = nil) -> [Product] {
            var items: [Product] = []
            let urlToRead = url ?? tasksDocURL
            guard FileManager.default.fileExists(atPath: urlToRead.path) else {
                return []
            }

            let decoder = PropertyListDecoder()

            do {
                let tasksData = try Data(contentsOf: urlToRead)
                items = try decoder.decode([Product].self, from: tasksData)
            } catch {
                print(error)
            }
            
            return items
        }
        
        static func saveItems(_ items: [Product]) {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml

            do {
                let tasksData = try encoder.encode(items)
                try tasksData.write(to: tasksDocURL, options: .atomicWrite)
            } catch {
                print(error)
            }
        }
        
        /// #Helpers fo plist
                
        static func loadPlist(from url: URL? = nil) -> [String] {
            var items: [String] = []
            let urlToRead = url ?? plistURL
            guard FileManager.default.fileExists(atPath: urlToRead.path) else {
                return []
            }

            let decoder = PropertyListDecoder()

            do {
                let tasksData = try Data(contentsOf: urlToRead)
                items = try decoder.decode([String].self, from: tasksData)
            } catch {
                print(error)
            }
                    
            return items
        }
                
        static var tempPlistData: [String] = ["Saw", "Hammer", "Nails", "Screwdriver", "Plane"]
        
        static var tempPlistDataRu: [String] = ["Пила", "Молоток", "Гвозди", "Отвертка", "Рубанок"]
                
        static func savePlist() {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let items = tempPlistData
            let itemsRu = tempPlistDataRu
            do {
                let plistData = try encoder.encode(items)
                let plistDataRu = try encoder.encode(itemsRu)
           
                if let topVC = UIApplication.topViewController() {
                    let items: [Any] = [plistData, plistDataRu]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    ac.popoverPresentationController?.sourceView = topVC.view
                    topVC.present(ac, animated: true)
                }
                    
            } catch {
                print(error)
            }
        }

        static let plistURL = URL(
            fileURLWithPath: "plist_helper_localize",
            relativeTo: FileManager.documentsDirectoryURL
        )
        .appendingPathExtension("plist")
        
        static let plistURLRu = URL(
            fileURLWithPath: "plist_helper_localize_ru",
            relativeTo: FileManager.documentsDirectoryURL
        )
        .appendingPathExtension("plist")
        
        static let fileExtension = "shlist"

        static let tasksDocURL = URL(
            fileURLWithPath: "shlistitems",
            relativeTo: FileManager.documentsDirectoryURL
        )
        .appendingPathExtension(fileExtension)
        
        static let tasksMarkDownURL = URL(
            fileURLWithPath: "shlistmarkdown",
            relativeTo: FileManager.documentsDirectoryURL
        )
        .appendingPathExtension("md")
        
        static var productDictionaryRepository = DictionaryRepository(localDS: DictionaryDataSource())
        
        static var lastSearchDataSource = LastSearchDataSource()
        static var productsRepo = ProductRepository(localDS: ProductDataSource())
        static var selectedCategoryDataSource = SelectedCategoryDataSource()
        static var colorsDS = ColorsDataSource()
        
        enum Category: String {
            case fish
            case meat
            case egg
            case milk
            case veget
            case oilAndSpices
            case grain
            case bread
            case sweat
            case drink
            case cosmetic
            case cafe
            case chemical
            case pharmacy
            case snack
            case other
            case clothes
            case furniture
            case repair
            
            var name: String {
                switch self {
                case .fish:
                    return NSLocalizedString("category.name.fish", comment: "")
                case .meat:
                    return NSLocalizedString("category.name.meat", comment: "")
                case .egg:
                    return NSLocalizedString("category.name.eggs", comment: "")
                case .milk:
                    return NSLocalizedString("category.name.milk", comment: "")
                case .veget:
                    return NSLocalizedString("category.name.veget", comment: "")
                case .grain:
                    return NSLocalizedString("category.name.grain", comment: "")
                case .oilAndSpices:
                    return NSLocalizedString("category.name.oilAndSpices", comment: "")
                case .bread:
                    return NSLocalizedString("category.name.bread", comment: "")
                case .sweat:
                    return NSLocalizedString("category.name.sweat", comment: "")
                case .cafe:
                    return NSLocalizedString("category.name.cafe", comment: "")
                case .drink:
                    return NSLocalizedString("category.name.drink", comment: "")
                case .cosmetic:
                    return NSLocalizedString("category.name.cosmetic", comment: "")
                case .chemical:
                    return NSLocalizedString("category.name.chemical", comment: "")
                case .pharmacy:
                    return NSLocalizedString("category.name.pharmacy", comment: "")
                case .snack:
                    return NSLocalizedString("category.name.snack", comment: "")
                case .other:
                    return NSLocalizedString("category.name.other", comment: "")
                case .clothes:
                    return NSLocalizedString("category.name.clothes", comment: "")
                case .furniture:
                    return NSLocalizedString("category.name.furniture", comment: "")
                case .repair:
                    return NSLocalizedString("category.name.repair", comment: "")
                }
            }
            
            var products: [String] {
                if let plistURL = Bundle.main.url(forResource: "\(self.rawValue)", withExtension: "plist") {
                    if let plistArray = NSArray(contentsOf: plistURL) as? [String] {
                        return plistArray
                    }
                }
                return []
            }
        }
    }
}

extension Settings.Store.Category {
    static let allCases: [Settings.Store.Category] = [.fish, .meat, .egg, .milk, .veget, .oilAndSpices, .grain, .bread, .sweat, .drink, .cosmetic, .cafe, .chemical, .pharmacy, .snack, .other, .clothes, .furniture, .repair]
    
    /**
     Create dictionary
     */
    static func createDictionary() {
        var result: [Product] = []
        
        for category in Settings.Store.Category.allCases {
            category.products.forEach {
                let prod = Product(id: UUID().uuidString, name: $0, category: Category(name: category.name, colorHex: 0x000000, iconName: category.rawValue))
                result.append(prod)
            }
        }
        
        let res = result.sorted { $0.name < $1.name }
        
        let filter = res.enumerated().filter { i, prod in
            if i > 0 {
                return prod.name != res[i - 1].name
            } else {
                return true
            }
        }.compactMap { $0.element }
        
        let resFilter = Array(filter)
        
        Settings.Store.productDictionaryRepository.set(items: resFilter)
        store.set(productsDictionaryValue, value: resFilter)
    }
}

extension UIColor {
    static let dimmedLightBackground = UIColor(white: 100.0 / 255.0, alpha: 0.3)
    static let dimmedDarkBackground = UIColor(white: 50.0 / 255.0, alpha: 0.3)
    static let dimmedDarkestBackground = UIColor(white: 0, alpha: 0.5)
}

public extension FileManager {
    static var documentsDirectoryURL: URL? {
        return Folder.documents?.url
    }
}
