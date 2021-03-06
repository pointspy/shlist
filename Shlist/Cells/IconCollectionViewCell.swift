//
//  IconCollectionViewCell.swift
//  Shlist
//
//  Created by Pavel Lyskov on 23.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Reusable
import RxCocoa
import RxSwift
import RxTheme
import SwiftIcons
import UIKit

final class IconCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var checkView: UIView!
    
    var iconWrap: IconTypeWrapper?
    var colorWrap: ColorTypeWrapper?
    
    static let cellDimension: CGFloat = 60.0
    static let iconDimension: CGFloat = 48.0
    static let symbolDimension: CGFloat = 32.0
    
    public private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let themeDriver = Settings.Colors.themeService.attrsStream
            .asDriver(onErrorJustReturn: Settings.Colors.LightTheme())
        
        themeDriver.drive(onNext: { [weak self] theme in
            guard let self = self else { return }
            
            self.iconView.layer.borderColor = theme.iconCheckColor.cgColor
            
            if let iconWrap = self.iconWrap, let icon = iconWrap.type {
                self.iconView.setIcon(icon: .fontAwesomeSolid(icon), textColor: iconWrap.checked ? .white : theme.iconMainColor, backgroundColor: .clear, size: CGSize(width: IconCollectionViewCell.symbolDimension, height: IconCollectionViewCell.symbolDimension))
                self.iconView.backgroundColor = iconWrap.checked ? iconWrap.selectedColor : theme.iconBackColor
                self.checkView.alpha = iconWrap.checked ? 1 : 0
            } else if let colorWrap = self.colorWrap {
                self.iconView.image = nil
                self.iconView.backgroundColor = colorWrap.checked ? colorWrap.color : theme.iconBackColor
                self.checkView.alpha = colorWrap.checked ? 1 : 0
            }
          }).disposed(by: disposeBag)
    }
    
    func setType(with iconWrap: IconTypeWrapper?, colorWrap: ColorTypeWrapper?) {
         
        self.iconWrap = iconWrap
        self.colorWrap = colorWrap
        
        checkView.alpha = 0
        checkView.backgroundColor = .clear
        checkView.layer.borderWidth = 3
        checkView.layer.borderColor = Settings.Colors.themeService.attrs.iconCheckColor.cgColor
        checkView.layer.cornerRadius = IconCollectionViewCell.cellDimension / 2
        checkView.clipsToBounds = true
        
        iconView.contentMode = .center
        iconView.layer.cornerRadius = IconCollectionViewCell.iconDimension / 2
        iconView.clipsToBounds = true
        iconView.isUserInteractionEnabled = true
        iconView.fh.setScaleBehavior(enabled: true)

         if let icon = self.iconWrap?.type, let color = self.colorWrap?.color {
         
             let sColor = color.isLight() ? UIColor.black : .white
             
             self.iconView.setIcon(icon: .fontAwesomeSolid(icon), textColor: sColor, backgroundColor: .clear, size: CGSize(width: IconCollectionViewCell.symbolDimension, height: IconCollectionViewCell.symbolDimension))
         
             self.iconView.backgroundColor = color
             
         } else if let icon = self.iconWrap?.type {
             self.iconView.setIcon(icon: .fontAwesomeSolid(icon), textColor: Settings.Colors.themeService.attrs.iconMainColor, backgroundColor: .clear, size: CGSize(width: IconCollectionViewCell.symbolDimension, height: IconCollectionViewCell.symbolDimension))
             self.iconView.backgroundColor = Settings.Colors.themeService.attrs.iconBackColor
         } else if let color = self.colorWrap?.color {
             self.iconView.image = nil
             self.iconView.backgroundColor = color
         }
    }
    
    func setChecked(_ checked: Bool, animated: Bool = false) {
      
        let block: () -> Void = {[weak self] in
            guard let self = self else {return}
            if let icon = self.iconWrap?.type, let color = self.colorWrap?.color {
            
                let sColor = color.isLight() ? UIColor.black : .white
                
                self.iconView.setIcon(icon: .fontAwesomeSolid(icon), textColor: sColor, backgroundColor: .clear, size: CGSize(width: IconCollectionViewCell.symbolDimension, height: IconCollectionViewCell.symbolDimension))
            
                self.iconView.backgroundColor = color
                
            } else if let icon = self.iconWrap?.type {
                self.iconView.setIcon(icon: .fontAwesomeSolid(icon), textColor: Settings.Colors.themeService.attrs.iconMainColor, backgroundColor: .clear, size: CGSize(width: IconCollectionViewCell.symbolDimension, height: IconCollectionViewCell.symbolDimension))
                self.iconView.backgroundColor = Settings.Colors.themeService.attrs.iconBackColor
            } else if let color = self.colorWrap?.color {
                self.iconView.image = nil
                self.iconView.backgroundColor = color
            }
            
            self.checkView.alpha = checked ? 1 : 0
 
        }
        
        if !animated {
            block()
        } else {
            UIView.animate(withDuration: 0.217, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                block()
            }, completion: nil)
        }
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
}
