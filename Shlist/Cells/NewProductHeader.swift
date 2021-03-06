//
//  NewProductHeader.swift
//  Shlist
//
//  Created by Pavel Lyskov on 11.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Reusable
import RxCocoa
import RxSwift

final class NewProductHeader: UITableViewCell, NibReusable {
    @IBOutlet var titleLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    public func set(title: String) {
        self.titleLabel.text = title
    }
    
    func setUp() {
        let color = self.traitCollection.userInterfaceStyle == .dark ? UIColor.systemBackground : .secondarySystemBackground
        self.backgroundColor = color
        self.contentView.backgroundColor = color
        
        Settings.Colors.themeService.rx
            .bind({ $0.backgroundColor }, to: self.rx.backgroundColor, self.contentView.rx.backgroundColor)
            .disposed(by: self.disposeBag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        self.selectedBackgroundView = bgColorView
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
}
