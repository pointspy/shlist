//
//  CalculatorView.swift
//  Calculator
//
//  Created by Pavel Lyskov on 08.03.2021.
//  Copyright © 2021 London App Brewery. All rights reserved.
//

import UIKit

final class NumberView: UIView {
    static var shared = NumberView(target: nil)
    
    weak var target: UIKeyInput?
    
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var buttonPoint: UIButton!
    
    lazy var allButtons: [UIButton] = [self.button0, self.button1, self.button2, self.button3, self.button4, self.button5, self.button6, self.button7, self.button8, self.button9, self.buttonPoint]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 230)
    }
    
    init(target: UIKeyInput?) {
        self.target = target
            
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 230))
        setup()
    }
    
    @IBAction func calcButtonPressed(_ sender: UIButton) {
        // What should happen when a non-number button is pressed
        
        target?.deleteBackward()
    }

    @IBAction func numButtonPressed(_ sender: UIButton) {
        if let text = sender.currentTitle {
            if text == "." {
                if let textField = target as? UITextField, let textFieldText = textField.text, !textFieldText.isEmpty {
                    if !textFieldText.contains(".") {
                        target?.insertText(text)
                    }
                }
                
            } else {
                target?.insertText(text)
            }
        }
    }
    
    private func setup() {
        let contentV = fromNib()
        
        for button in allButtons {
            button.accessibilityTraits = [.keyboardKey]
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
            button.backgroundColor = UIColor(named: "keyboardColor")
            button.setTitleColor(.label, for: .normal)
            button.fh.controlEnable(normalColor: UIColor(named: "keyboardColor")!, highlightedColor: UIColor(named: "keyboardColorHigh")!)
            
            if let shadColor = UIColor(named: "keyboardColorShadow") {
                button.layer.shadowColor = shadColor.cgColor
                button.layer.shadowOffset = CGSize(width: 0, height: 1)
                button.layer.shadowOpacity = 1.0
            }
        }
        deleteButton.accessibilityTraits = [.keyboardKey]
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.masksToBounds = true
        deleteButton.backgroundColor = .clear
        deleteButton.imageView?.tintColor = .label
        deleteButton.fh.controlEnable(normalColor: .clear, highlightedColor: UIColor(named: "keyboardColorHigh")!)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        backgroundColor = UIColor(named: "keyboardColorBack")
        contentV?.backgroundColor = UIColor(named: "keyboardColorBack")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
