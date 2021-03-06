//
//  InputDialogView.swift
//  Shlist
//
//  Created by Pavel Lyskov on 06.02.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import Foundation
import Reusable
import UIKit

final class InputDialogView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    init() {
        super.init(frame: .zero)
        
        self.setup()
    }
    
    func setup() {
        fromNib()
        
        
    }
}
