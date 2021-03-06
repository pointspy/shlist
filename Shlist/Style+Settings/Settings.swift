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
          } catch let error {
            print(error)
          }
        }
        
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
                    return "Рыба"
                case .meat:
                    return "Мясо"
                case .egg:
                    return "Яйца"
                case .milk:
                    return "Молочные продукты"
                case .veget:
                    return "Овощи и фрукты"
                case .grain:
                    return "Мука и зерно"
                case .oilAndSpices:
                    return "Масла, соусы и специи"
                case .bread:
                    return "Хлебобулочные"
                case .sweat:
                    return "Сладости"
                case .cafe:
                    return "Кафе"
                case .drink:
                    return "Напитки"
                case .cosmetic:
                    return "Косметика"
                case .chemical:
                    return "Бытовая химия"
                case .pharmacy:
                    return "Аптека"
                case .snack:
                    return "Снэк"
                case .other:
                    return "Другое"
                case .clothes:
                    return "Одежда"
                case .furniture:
                    return "Мебель"
                case .repair:
                    return "Инструмент"
                }
            }
            
            var products: [String] {
                switch self {
                case .fish:
                    return ["Рыба", "Анчоусы", "Горбуша", "Желтохвост (лакедра)", "Камбала", "Карп", "Кета", "Кижуч", "Масляная рыба (эсколар)", "Минтай", "Налим", "Окунь морской (красный)", "Осётр", "Палтус", "Сардина", "Сельдь", "Сёмга", "Сибас", "Скумбрия", "Ставрида", "Судак", "Терпуг", "Тилапия", "Треска", "Тунец", "Угорь", "Форель", "Чавыча", "Щука", "Икра красная или чёрная", "Рыба", "Кальмар", "Мидии", "Моллюски", "Морской гребешок", "Устрицы", "Краб", "Креветки", "Лобстеры (омары, лангусты)", "Раки", "Водоросли нори", "Морская капуста"]
                case .meat:
                    return ["Мясо 🥩", "Лягушачьи лапки", "Свинина 🥩", "Корейка свиная", "Говядина", "Телятина", "Говяжий язык", "Говяжья печень", "Баранина", "Крольчатина", "Курица 🍗", "Куриная грудка", "Куриные ножки", "Курица", "Куриная печень", "Куриные сердца", "Бедро индейки (филе)", "Голень индейки", "Грудка индейки (филе)", "Индейка", "Печень индейки", "Гусь", "Утка (мясо утиное)", "Фуа-гра", "Жир свиной (сало свиное)", "Сало свиное топлёное (смалец)", "Кости на суп 🍖", "Колбаса", "Колбаса копченая", "Колбаса сырокопченая", "Колбаса вяленая", "Хамон", "Сосиски", "Сардельки", "Пельмени", "Хинкали", "Манты", "Котлеты куриные", "Котлеты мясные", "Окорок", "Буженина", "Ребрышки"]
                case .egg:
                    return ["Яйца", "Яйцо гусиное", "Яйцо индейки", "Яйцо куриное", "Яйцо куриное", "Яйцо перепелиное", "Яйцо утиное"]
                case .milk:
                    return ["Сыр cливочный", "Сыр Бри", "Сыр Гауда", "Сыр Камамбер", "Сыр козий", "Сыр Моцарелла", "Сыр Пармезан",  "Сыр фета", "Сыр Филадельфия", "Сыр швейцарский", "Сыр Эдам", "Сыры с плесенью", "Йогурт", "Кефир", "Масло сливочное", "Молоко", "Молоко козье", "Молоко коровье", "Молоко сгущённое", "Молоко сухое", "Молочная сыворотка", "Ряженка", "Сметана", "Сметана обезжиренная", "Творог 2% жирности", "Протеиновые добавки на основе молока", "Сыр творожный", "Сыр плавленный"]
                case .veget:
                    return ["Соевые бобы", "Соевый соус", "Соевый сыр тофу", "Дыня", "Картофель 🥔", "Картофельное пюре", "Васаби", "Дайкон", "Корень имбиря", "Корень цикория", "Морковь 🥕", "Редиска", "Репа", "Свекла", "Лук репчатый", "Лук-шалот", "Чеснок 🧄", "Баклажан 🍆", "Перец болгарский",  "Перец чили красный острый", "Помидоры 🍅", "Физалис", "Кабачок", "Огурцы 🥒", "Патиссон", "Тыква", "Арахис", "Бобы", "Бобы зелёные", "Горох", "Зелёный горошек", "Нут", "Фасоль белая", "Фасоль красная (Кидни)", "Фасоль стручковая", "Фасоль чёрная", "Чечевица", "Брокколи 🥦", "Брокколи китайская", "Брюссельская капуста", "Капуста", "Капуста квашеная", "Капуста красная", "Капуста листовая", "Капуста пекинская", "Капуста савойская", "Цветная капуста", "Салат 🥬", "Салат кочанный", "Салат латук", "Артишоки", "Бамбуковые побеги", "Кукуруза 🌽", "Кукуруза", "Сельдерей", "Спаржа", "Кинза (листья кориандра)",  "Лук зелёный", "Лук-батун", "Лук-порей 🧅", "Петрушка", "Руккола", "Шпинат", "Щавель", "Перец чили острый 🌶", "Экстракт имбиря", "Лавровый лист", "Абрикос", "Айва", "Апельсины 🍊", "Арбуз 🍉", "Бананы", "Гранат", "Грейпфрут", "Груша 🍐", "Дыня", "Инжир", "Киви 🥝", "Лайм", "Лимон 🍋", "Мандарины", "Маслины", "Оливки зелёные", "Персик 🍑", "Слива", "Хурма", "Яблоки 🍏", "Бузина", "Виноград 🍇", "Вишня 🍒", "Голубика", "Ежевика", "Клубника 🍓", "Клюква", "Крыжовник", "Малина", "Смородина красная или белая", "Смородина чёрная", "Ягоды годжи", "Авокадо", "Ананас 🍍", "Гуава", "Дуриан", "Манго", "Маракуйя", "Мушмула", "Папайя", "Помело",  "Фейхоа", "Бананы 🍌", "Изюм", "Курага", "Финики", "Чернослив", "Каркаде", "Грибы", "Гриб древесный", "Грибы вешенки", "Грибы лисички", "Грибы майтаке", "Шампиньоны", "Кокосовая стружка", "Мякоть кокоса", "Арахис", "Бразильский орех", "Грецкий орех", "Кедровый орех", "Кешью", "Миндаль", "Орех макадамия", "Пекан", "Фисташки", "Фундук", "Кокос 🥥"]
                case .grain:
                    return ["Каша овсяная", "Каша гречневая", "Каша перловая", "Каша пшеничная",  "Крахмал кукурузный", "Мука гречневая", "Мука овсяная",  "Мука пшеничная", "Мука ржаная", "Мука рисовая", "Отруби овсяные", "Отруби пшеничные", "Отруби рисовые", "Лапша (макароны, паста)", "Лапша гречневая (соба)", "Лапша домашняя", "Лапша из цельнозерновой пшеницы", "Лапша кукурузная", "Лапша рисовая", "Лапша яичная"]
                case .oilAndSpices:
                    return ["Масло арахисовое", "Масло горчичное", "Масло кунжутное", "Масло льняное", "Масло оливковое", "Масло пальмовое", "Масло подсолнечное", "Майонез", "Соль 🧂", "Перец"]
                case .bread:
                    return ["Хлеб 🍞", "Блины 🥞", "Булочки", "Лаваш", "Сухари панировочные", "Тортилья", "Фокачча", "Хлеб белый пшеничный", "Хлеб мультизерновой", "Хлеб овсяный", "Хлеб пшеничный цельнозерновой", "Хлеб ржаной", "Хлебцы мультизерновые", "Хлебцы ржаные", "Батон 🥖", "Пирог 🥮"]
                case .sweat:
                    return ["Торт 🎂",
                            
                            "Шоколад 🍫",
                            
                            "Конфеты 🍬",
                            
                            "Мороженое🍦",
                            
                            "Мёд 🍯",
                            
                            "Пирожное 🍮",
                            
                            "Печенье 🍪",
                            
                            "Кекс 🥮",
                            
                            "Мармелад", "Зефир", "Ирис", "Карамель", "Кекс шоколадный", "Крекер", "Печенье овсяное", "Халва", "Аспартам", "Сахар", "Сахар коричневый", "Сахарин", "Стевия (сахарозаменитель)",  "Фруктоза", "Шоколад тёмный (70-85% какао)", "Шоколадный батончик"]
                    
                case .cafe:
                    return ["Паста 🍝",
                            
                            "Суши 🍣",
                            
                            "Пирожки 🥟",
                            
                            "Рис 🍚",
                            
                            "Салат 🥗",
                            
                            "Лапша 🍜",
                            
                            "Жульен 🍲",
                            
                            "Гамбургер 🍔 ",
                            
                            "Хот-дог 🌭 ",
                            
                            "Картофель фри 🍟",
                            
                            "Пицца 🍕",
                            
                            "Кебаб 🥙",
                            
                            "Тортилья 🌯",
                            "Плов",
                            "Хачапури"]
                case .drink:
                    return ["Вода 💧", "Минеральная вода 💧", "Сок 🧃", "Кокосовое молоко", "Морс клюквенный", "Сок абрикосовый (нектар)", "Сок 🧃 апельсиновый", "Сок 🧃 виноградный", "Сок 🧃 гранатовый", "Сок 🧃 грейпфрутовый", "Сок 🧃 грушевый (нектар)", "Сок 🧃 лайма", "Сок 🧃 лимонный", "Сок 🧃 манго (нектар)",  "Сок 🧃 персиковый (нектар)", "Сок 🧃 яблочный", "Кока-кола 🥤", "Кофе зерновой", "Кофе ☕️ растворимый", "Кофе ☕️", "Цикорий", "Чай 🍵", "Чай 🍵 зелёный", "Чай 🍵 чёрный", "Энергетический напиток", "Вино 🍷", "Вино 🍷 белое", "Вино 🍷 десертное сладкое", "Вино 🍷 десертное сухое", "Вино 🍷 красное", "Вино 🍷 розовое", "Виски 🥃", "Водка", "Джин", "Пиво 🍺", "Ром", "Саке 🍶", "Мартини 🍸", "Шампанское 🍾"]
                case .cosmetic:
                    return ["Зубная паста", "Гель для душа🧴",
                            
                            "Шампунь 🧴",
                            
                            "Туалетная бумага 🧻",
                            
                            "Мыло 🧼"]
                case .pharmacy:
                    return ["Аспирин", "Капли для носа"]
                case .chemical:
                    return ["Стиральный порошок", "Моющее для посуды"]
                case .snack:
                    return ["Чипсы", "Семечки", "Сухарики", "Кальмар сушенный", "Рыба соленая"]
                    
                case .other:
                    return ["Вкусняшки коту 🐈", "Корм коту 🐈", "Сигареты 🚬"]
                case .clothes:
                    return ["Рубашка"]
                case .furniture:
                    return ["Стул"]
                case .repair:
                    return ["Пила"]
                }
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
