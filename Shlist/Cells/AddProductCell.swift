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

final class AddProductCell: UITableViewCell, NibReusable {
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var iconView: UIImageView!
    
    @IBOutlet var backView: CornerRoundingView!
    @IBOutlet var stackView: UIStackView!
    
    public private(set) var disposeBag = DisposeBag()
    
    var oldText: String = ""
    
    var product: Product?
    
    func setUp(with options: ProductCellOptions, product: Product) {
        disposeBag = DisposeBag()
        
        self.product = product
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            updateObject(self.contentView, withBackground(color: .clear))
            updateObject(self, withBackground(color: .clear))
        }
        
        let backColor = Settings.Colors.blue
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            updateObject(self.backView, concat(
                withBackground(color: backColor),
                withFluidBackground(normalColor: backColor, highlightedColor: backColor.lighter())
            ))
        }
        
        backView.cornerRadius = backView.layer.bounds.height / 2
        backView.isSquircle = false
        
        Settings.Colors.themeService.rx
            .bind({ $0.cellBackgroundColor }, to: rx.backgroundColor, contentView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        iconView.image = UIImage(systemName: "plus.circle.fill")?.with(color: .white)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        let bgColorView = update(UIView(), mut(\UIView.backgroundColor, .clear))
        
        selectedBackgroundView = bgColorView
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
    
    public func animatePresent() {
        
        self.iconView.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5).rotated(by: .pi)
        
        UIView.animate(withDuration: 0.5, delay: 0.35, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .beginFromCurrentState, animations: {[weak self] in
            guard let self = self else { return }
            self.iconView.transform = .identity
            
        }, completion: nil)
        
    }
}
