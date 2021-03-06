//
//  ProductStateViewModel.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift

protocol IconCollectionViewModelInput {
    var iconsWrap: BehaviorRelay<[IconTypeWrapper]> { get }
    var dataSource: IconsDataSource { get }
    var dataSourceColors: ColorsDataSource { get }

    var categoryNameRelay: BehaviorRelay<String?> { get }
}

protocol IconCollectionViewModelOutput {
    var resultIconSections: Driver<[CategoryStyleMultipleSectionModel]> { get }
    var selectedIconWrap: Driver<IconTypeWrapper> { get }
    var selectedColorWrap: Driver<ColorTypeWrapper> { get }

    var categoryNameDriver: Driver<String?> { get }
    var categoryRelay: BehaviorRelay<Category?> { get }
}

protocol IconCollectionViewModel {
    var input: IconCollectionViewModelInput { get }
    var output: IconCollectionViewModelOutput { get }
}

extension IconCollectionViewModel where Self: IconCollectionViewModelInput & IconCollectionViewModelOutput {
    var input: IconCollectionViewModelInput { return self }
    var output: IconCollectionViewModelOutput { return self }
}
