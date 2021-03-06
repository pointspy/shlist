//
//  NewProductCell.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import CoreGraphics
import Overture
import Reusable
import RxCocoa
import RxSwift
import RxTheme
import SwiftIcons
//import SwipeCellKit

final class ProductCellNew: UITableViewCell, NibReusable {
    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var iconView: UIImageView!

    public private(set) var disposeBag = DisposeBag()

    @IBOutlet weak var checkBoxView: Checkbox!
    var oldText: String = ""

    var product: Product?

    func setUp(with options: ProductCellOptions, product: Product) {
        disposeBag = DisposeBag()

        self.product = product

        updateObject(contentView, withBackground(color: .clear))
        updateObject(self, withBackground(color: .clear))

        Settings.Colors.themeService.rx
            .bind(
                { $0.cellBackgroundColor }, to: rx.backgroundColor)
            .disposed(by: disposeBag)

        Settings.Colors.themeService.rx
            .bind(
                { $0.cellBackViewColor }, to: contentView.rx.backgroundColor)
            .disposed(by: disposeBag)

        checkBoxView.borderStyle = .circle
        checkBoxView.checkmarkStyle = .circle
        checkBoxView.borderLineWidth = 2
        checkBoxView.uncheckedBorderColor = .lightGray
        checkBoxView.checkedBorderColor = Settings.Colors.blue
        checkBoxView.checkmarkSize = 0.72
        checkBoxView.checkmarkColor = Settings.Colors.blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

        let bgColorView = update(UIView(), mut(\UIView.backgroundColor, .clear))

        selectedBackgroundView = bgColorView
    }

    public func set(checked: Bool) {
        guard let product = self.product else { return }
        var image: UIImage?

        let imageName: String =
            checked ? product.category.iconName : "\(product.category.iconName)_checked"

        if let iconTypeRaw = product.category.imageIconTypeRaw, let type = FASolidType(rawValue: iconTypeRaw) {
            let scale = UIScreen.main.scale
            let iconSize: CGFloat = scale * 23.0
            let backSize: CGFloat = scale * 32.0

            let imageS = UIImage(icon: .fontAwesomeSolid(type), size: CGSize(width: iconSize, height: iconSize), textColor: .white, backgroundColor: .clear)

            let curColor = checked ? Settings.Colors.mainUncheckColor : product.category.colorHex.color

            let backImage = UIImage.size(width: backSize, height: backSize)
                .color(gradient: [curColor.lighter(amount: 0.15), curColor], locations: [0, 1], from: CGPoint(x: 0.5, y: 0), to: CGPoint(x: 0.5, y: 1))
                .corner(radius: backSize / 2)
                .border(color: curColor.lighter(amount: 0.15))
                .border(alignment: .outside)
                .border(width: 1.0)
                .image

            let imageNew = backImage + imageS

            image = imageNew

        } else if let imageNew = UIImage(named: imageName) {
            image = imageNew

        } else {
            image = checked ? UIImage(named: "checked") : UIImage(named: "unChecked")
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            updateObject(self.iconView, withImage(image))
//            updateObject(
//                self.nameLabel,
//                withTextColor(
//                    color: checked ? Settings.Colors.nameChecked : Settings.Colors.nameUnChecked))
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.checkBoxView.isChecked = checked
        }
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
}
