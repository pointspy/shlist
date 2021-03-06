//
//  NSAttributedStringExtensions.swift
//  TinyConsole
//
//  Created by Devran on 30.09.19.
//

import Foundation

extension NSAttributedString {
    static func breakLine() -> NSAttributedString {
        return NSAttributedString(string: "\n")
    }
    
    var range: NSRange {
        return NSRange(location: 0, length: length)
    }
}
