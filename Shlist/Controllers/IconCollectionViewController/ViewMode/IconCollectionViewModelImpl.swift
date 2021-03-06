//
//  IconCollectionViewModelInputImpl.swift
//  Shlist
//
//  Created by Pavel Lyskov on 23.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt

final class IconCollectionViewModelImpl: IconCollectionViewModel, IconCollectionViewModelInput,
    IconCollectionViewModelOutput {
    // MARK: Input
    
    var iconsWrap: BehaviorRelay<[IconTypeWrapper]>
    var dataSource: IconsDataSource
    var dataSourceColors: ColorsDataSource
    
    var categoryNameRelay: BehaviorRelay<String?> = .init(value: nil)
    
    // MARK: Output
    
    var resultIconSections: Driver<[CategoryStyleMultipleSectionModel]> {
        return Driver.combineLatest(iconsWrap.asDriver(), dataSourceColors.items.asDriver())
            .flatMapLatest { value -> Driver<[CategoryStyleMultipleSectionModel]> in
                
                let (icons, colors) = value
                
                let colorsSectionItems = colors.compactMap { color in
                    SectionItem.ColorsSectionItem(title: color.id, color: color)
                }
                
                let iconsSectionItems = icons.compactMap { icon in
                    SectionItem.IconsSectionItem(title: icon.id, icon: icon)
                }
                
                let sectionColors = CategoryStyleMultipleSectionModel.ColorsProvidableSection(title: "Colors Section", items: colorsSectionItems)
                let sectionIcons = CategoryStyleMultipleSectionModel.IconsProvidableSection(title: "Icons Section", items: iconsSectionItems)
                
                return BehaviorRelay<[CategoryStyleMultipleSectionModel]>.init(value: [sectionColors, sectionIcons])
                    .asDriver()
            }
    }
    
    var selectedIconWrap: Driver<IconTypeWrapper> {
        return dataSource.currentSelectedRelay.asDriver()
    }
    
    var selectedColorWrap: Driver<ColorTypeWrapper> {
        return dataSourceColors.currentSelectedRelay.asDriver()
    }
    
    var categoryNameDriver: Driver<String?> {
        return categoryNameRelay.asDriver()
    }
    
    var categoryRelay: BehaviorRelay<Category?> = BehaviorRelay<Category?>.init(value: nil)
    
    // MARK: Init
    
    let disposeBag = DisposeBag()
    
    init(iconsWrap: BehaviorRelay<[IconTypeWrapper]>, dataSource: IconsDataSource, dataSourceColors: ColorsDataSource) {
        self.iconsWrap = iconsWrap
        self.dataSource = dataSource
        self.dataSourceColors = dataSourceColors
        
        Driver.combineLatest(categoryNameDriver, selectedColorWrap, selectedIconWrap)
            .flatMapLatest { value -> Driver<Category?> in
                
                let (name, color, icon) = value
                
                guard let nameNew = name, let type = icon.type else {
                    return BehaviorRelay<Category?>.init(value: nil).asDriver()
                }
                
                let category = Category(name: nameNew, colorHex: Int(color.color.toHex()), iconName: "", imageIconTypeRaw: type.rawValue)
                
                return BehaviorRelay<Category?>.init(value: category).asDriver()
                
            }.drive(categoryRelay)
            .disposed(by: disposeBag)
    }
}
