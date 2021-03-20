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

final class FooterCell: UITableViewCell, NibReusable {
    
    static let numberFormatter: NumberFormatter  = {
        let formatter = NumberFormatter()
//        formatter.maximumFractionDigits = 2
//        formatter.minimumFractionDigits = 2
//        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        formatter.allowsFloats = false
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        return formatter
    }()
    
    @IBOutlet var sumLabel: UILabel!
    
    public private(set) var disposeBag = DisposeBag()
    
    public func set(sum: Double) {
        
//        let sumText: String = FooterCell.numberFormatter.string(from: NSNumber(floatLiteral: sum)) ?? "0.00"
        
        self.sumLabel.attributedText = "\(NSLocalizedString("common.sum", comment: "")): ".at.attributed {
            $0.font(Settings.Fonts.totalSumTitle).foreground(color: Settings.Colors.totalSumTitleColor)
        } + "\(sum.asPretty)\(NSLocalizedString("common.currency", comment: ""))".at.attributed {
            $0.font(Settings.Fonts.totalSumValue).foreground(color: Settings.Colors.totalSumValueColor)
        }
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
