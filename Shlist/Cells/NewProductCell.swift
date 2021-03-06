//
//  NewProductCell.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

// import SwipeCellKit
import CoreGraphics
import Overture
import Reusable
import RxCocoa
import RxSwift
import RxTheme
import SwiftIcons


struct ProductCellOptions: OptionSet {
    let rawValue: Int

    static let top = ProductCellOptions(rawValue: 1 << 0)
    static let medium = ProductCellOptions(rawValue: 1 << 1)
    static let bottom = ProductCellOptions(rawValue: 1 << 2)
    static let withoutFluidTouch = ProductCellOptions(rawValue: 1 << 3)

    static let single: ProductCellOptions = [.top, .bottom]
    static let all: ProductCellOptions = [.top, .medium, .bottom]
}

final class NewProductCell: UITableViewCell, NibReusable {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceField: PriceField!
    @IBOutlet var iconView: UIImageView!

    @IBOutlet var checkIcon: UIImageView!
    @IBOutlet var backView: UIView!
    @IBOutlet var stackView: UIStackView!

    public private(set) var disposeBag = DisposeBag()

    var searchRelay: BehaviorRelay<String> = .init(value: "")

    var checkMarkIsAvailable: Bool = false {
        didSet {
            setCheckmark(available: checkMarkIsAvailable)
        }
    }

    var oldText: String = ""

    var product: Product?

    func hidePrice() {
        stackView.arrangedSubviews[2].isHidden = true
    }

    func setUp(with options: ProductCellOptions, product: Product) {
        disposeBag = DisposeBag()

        stackView.arrangedSubviews[3].isHidden = true

        self.product = product

        updateObject(contentView, withBackground(color: .clear))
        updateObject(self, withBackground(color: .clear))

        let backColor = Settings.Colors.themeService.attrs.cellBackViewColor

        updateObject(
            priceField,
            concat(
                withTextAligment(.center),
                rounded(with: 8),
                withMaskedCorners(),
                withTint(color: .white),
                withFont(Settings.Fonts.priceField),
                withBackground(
                    color: traitCollection.userInterfaceStyle == .dark
                        ? UIColor.tertiarySystemBackground : .secondarySystemBackground)))

        updateObject(
            backView,
            concat(
                withBackground(color: backColor),
                withMaskedCorners(),
                rounded(with: 10)))

        Settings.Colors.themeService.rx
            .bind({ $0.priceFieldBackgroundColor }, to: priceField.rx.backgroundColor)
            .bind({ $0.cellBackViewColor }, to: backView.rx.backgroundColor)
            .bind(
                { $0.cellBackgroundColor }, to: rx.backgroundColor, contentView.rx.backgroundColor)
            .disposed(by: disposeBag)

        if !options.contains(.withoutFluidTouch) {
            Settings.Colors.themeService.attrsStream.asObservable()
                .share(replay: 1, scope: .whileConnected)
                .observe(on: MainScheduler.instance)
                .asDriver(onErrorJustReturn: Settings.Colors.LightTheme())
                .drive(onNext: { theme in
                    self.backView.fh.enable(
                        normalColor: theme.cellBackViewColor,
                        highlightedColor: theme.cellBackViewColorHiglighted)
                }).disposed(by: disposeBag)
        }

        priceField.rx.controlProperty(
            editingEvents: .editingChanged,
            getter: { field in

                guard let text = field.text else { return "0" }

                let count = text.count < 4 ? text.count : 4

                let t = String("\(text.prefix(count))")

                return t
            },
            setter: { /* [weak self] */ field, new in
                //            guard let self = self else { return }
                guard new.count < 6 else { return }

                field.text = new
            }).bind(to: priceField.rx.text)
            .disposed(by: disposeBag)

        priceField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    updateObject(
                        self.priceField,
                        concat(
                            withBackground(color: Settings.Colors.blue),
                            withTextColor(color: .white)))

                    if let text = self.priceField.text, !text.isEmpty {
                        self.priceField.text = text.replacingOccurrences(of: "₽", with: "")
                    }
                }

            }).disposed(by: disposeBag)

        priceField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    updateObject(
                        self.priceField,
                        concat(
                            withBackground(
                                color: self.traitCollection.userInterfaceStyle == .dark
                                    ? UIColor.tertiarySystemBackground : .secondarySystemBackground),
                            withTextColor(color: .label)))

                    if let text = self.priceField.text, !text.isEmpty {
                        self.priceField.text = "\(text)₽"
                    } else {
                        self.priceField.text = "0₽"
                    }
                }

            }).disposed(by: disposeBag)
        
        searchRelay.asDriver()
            .drive(onNext: { searchPrase in
                if !searchPrase.isEmpty {
                    self.nameLabel.highlight(text: searchPrase, normal: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], highlight: [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
                }

            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

        let bgColorView = update(UIView(), mut(\UIView.backgroundColor, .clear))

        selectedBackgroundView = bgColorView
    }

    public func set(checked: Bool, whithoutChangeTextColor: Bool = false) {
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

        } else if !imageName.isEmpty, UIImage(named: imageName) == nil {
            image = checked ? UIImage(named: "other") : UIImage(named: "other_checked")
        } else {
            image = checked ? UIImage(named: "checked") : UIImage(named: "unChecked")
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            updateObject(self.iconView, withImage(image))
            if !whithoutChangeTextColor {
                updateObject(
                    self.nameLabel,
                    withTextColor(
                        color: checked ? Settings.Colors.nameChecked : Settings.Colors.nameUnChecked))
            }
        }
    }

    func setCheckmark(available: Bool) {
        stackView.arrangedSubviews[3].isHidden = !available
    }

    func setCheckMark(visible: Bool, animated: Bool) {
        if animated {
            UIView.animate(
                withDuration: 0.217,
                animations: {
                    self.checkIcon.alpha = visible ? 1 : 0
                    self.checkIcon.transform =
                        visible
                            ? CGAffineTransform(scaleX: 1, y: 1)
                            : CGAffineTransform(scaleX: 0.8, y: 0.8)
                })

        } else {
            checkIcon.alpha = visible ? 1 : 0
            checkIcon.transform =
                visible
                    ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }

    public func setCkeckForCustomCategory() {
        setCheckmark(available: true)

        configure(checkIcon) {
            $0?.alpha = 1
            $0?.backgroundColor = .clear
            $0?.contentMode = .center
        }

        Settings.Colors.themeService.attrsStream.asObservable()
            .share(replay: 1, scope: .whileConnected)
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: Settings.Colors.LightTheme())
            .drive(onNext: { theme in
                let image = UIImage.size(width: 8, height: 8)
                    .color(theme.menuButtonColor)
                    .corner(radius: 4)
                    .image

                self.checkIcon.image = image
            }).disposed(by: disposeBag)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
    
    override func prepareForReuse() {
        self.nameLabel.text = ""
        self.nameLabel.textColor = .label
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
    
    
}
