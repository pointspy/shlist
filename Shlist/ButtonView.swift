//
//  ButtonView.swift
//  Shlist
//
//  Created by Pavel Lyskov on 11.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Reusable
import UIKit

class ButtonView: UIView, NibOwnerLoadable {

    @IBOutlet var button: UIButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
    }
}
