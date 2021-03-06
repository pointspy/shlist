//
//  NewProductCell.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Overture
import Reusable
import RxCocoa
import RxSwift
import RxTheme
//import SwipeCellKit

final class SwitchCell: UITableViewCell, NibReusable {
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var switchControl: UISwitch!
    
    @IBOutlet var backView: UIView!
    @IBOutlet var stackView: UIStackView!
    
    public private(set) var disposeBag = DisposeBag()
    
    var product: Product?
    
    func setUp(with options: ProductCellOptions, product: Product) {
        
        
        self.product = product
        self.switchControl.onTintColor = Settings.Colors.blue
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            updateObject(self.contentView, withBackground(color: .clear))
            updateObject(self, withBackground(color: .clear))
        }
        
        let backColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : .systemBackground
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            updateObject(self.backView, concat(
                withBackground(color: backColor),
                withFluidBackground(normalColor: backColor, highlightedColor: UIColor.systemGray),
                withMaskedCorners(),
                rounded(with: 10)
            ))
        }
        
        Settings.Colors.themeService.rx
            .bind({ $0.cellBackViewColor }, to: backView.rx.backgroundColor)
            .bind({ $0.cellBackgroundColor }, to: rx.backgroundColor, contentView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        var currentTheme: Theme
            
        if self.traitCollection.userInterfaceStyle == .dark {
            currentTheme = Settings.Colors.DarkTheme()
        } else {
            currentTheme = Settings.Colors.LightTheme()
        }
        
        Settings.Colors.themeService.attrsStream.asObservable()
            .observe(on: MainScheduler.instance)
            .share(replay: 1, scope: .whileConnected)
            .asDriver(onErrorJustReturn: currentTheme)
            .drive(onNext: {theme in
                 self.backView.fh.enable(normalColor: theme.cellBackViewColor, highlightedColor: theme.cellBackViewColorHiglighted)
            }).disposed(by: disposeBag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        let bgColorView = configure(UIView()) {
            $0.backgroundColor = .clear
        }
        
        selectedBackgroundView = bgColorView
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
}
