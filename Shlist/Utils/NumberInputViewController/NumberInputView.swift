//
//  NumberInputView.swift
//  Shlist
//
//  Created by Pavel Lyskov on 08.02.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import Reusable
import UIKit

final class NumberInputView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sumField: NumberTextField!
    @IBOutlet weak var quantityField: NumberTextField!
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var sumLabel: UILabel!
    
    
    @IBOutlet weak var closeButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width, height: 350.0)
    }
    
    func setup() {
        fromNib()
        
        sumField.minValue = 0
        sumField.hideStepper(hide: true)
        
        quantityField.minValue = 1
        
        doneButton.setBackgroundColor(Settings.Colors.blue, for: .normal)
        doneButton.layer.cornerRadius = 10
        doneButton.layer.masksToBounds = true
        
//        sumField.keyboardType = .asciiCapableNumberPad
//        quantityField.keyboardType = .asciiCapableNumberPad
        backgroundColor = .clear
        quantityLabel.text = NSLocalizedString("common.quantity", comment: "")
        sumLabel.text = NSLocalizedString("common.sum", comment: "")
        doneButton.setTitle(NSLocalizedString("common.save", comment: ""), for: .normal)
        
        sumField.inputView = NumberView.shared
        quantityField.inputView = NumberView.shared
    }
}
