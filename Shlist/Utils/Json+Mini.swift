//
//  Json+Mini.swift
//  Shlist
//
//  Created by Pavel Lyskov on 16.01.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import Foundation

extension String {
    public var JSONminify: String {
        // http://stackoverflow.com/questions/8913138/
        // https://developer.apple.com/reference/foundation/nsregularexpression#//apple_ref/doc/uid/TP40009708-CH1-SW46
        let minifyRegex = "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+"
        if let regexMinify = try? NSRegularExpression(pattern: minifyRegex, options: .caseInsensitive) {
            let modString = regexMinify.stringByReplacingMatches(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.count), withTemplate: "$1")
            return modString
                .replacingOccurrences(of: "[\n\t\r]", with: "", options: .regularExpression, range: startIndex ..< endIndex)
        } else {
            return self
        }
    }
}
