//
//  ChromaPickerServiceView.swift
//  Shlist
//
//  Created by Pavel Lyskov on 30.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Reusable
import UIKit

final class ChromaPickerServiceView: UIView {
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var colorPicker: ChromaColorPicker!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var hexTextField: UITextField!
    
    @IBOutlet var brightnessSlider: ChromaBrightnessSlider!
    var color: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    init(color: UIColor) {
        super.init(frame: .zero)
        self.color = color
        self.setup()
    }
    
    func setup() {
        fromNib()
        
        self.brightnessSlider.trackColor = self.color ?? .white
        
        self.brightnessSlider.connect(to: self.colorPicker)
        self.colorPicker.addHandle(at: self.color)
        self.colorPicker.currentHandle = self.colorPicker.handles[0]
        self.brightnessSlider.borderWidth = 1
    }
}
