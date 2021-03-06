//
// SwiftyColor
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if os(iOS)
  import UIKit
  public typealias SwiftyColor = UIColor
#elseif os(OSX)
  import AppKit
  public typealias SwiftyColor = NSColor
#endif

extension Int {
  public var color: SwiftyColor {
    let red = CGFloat(self as Int >> 16 & 0xff) / 255
    let green = CGFloat(self >> 8 & 0xff) / 255
    let blue  = CGFloat(self & 0xff) / 255
    return SwiftyColor(red: red, green: green, blue: blue, alpha: 1)
  }
}

precedencegroup AlphaPrecedence {
  associativity: left
  higherThan: RangeFormationPrecedence
  lowerThan: AdditionPrecedence
}

infix operator ~ : AlphaPrecedence

public func ~ (color: SwiftyColor, alpha: Int) -> SwiftyColor {
  return color ~ CGFloat(alpha)
}
public func ~ (color: SwiftyColor, alpha: Float) -> SwiftyColor {
  return color ~ CGFloat(alpha)
}
public func ~ (color: SwiftyColor, alpha: CGFloat) -> SwiftyColor {
  return color.withAlphaComponent(alpha)
}

/// e.g. `50%`
postfix operator %
public postfix func % (percent: Int) -> CGFloat {
  return CGFloat(percent)%
}
public postfix func % (percent: Float) -> CGFloat {
  return CGFloat(percent)%
}
public postfix func % (percent: CGFloat) -> CGFloat {
  return percent / 100
}


