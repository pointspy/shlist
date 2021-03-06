//
//  SwiftyPyString.swift
//  SwiftyPyString
//

extension Character {
    public init(_ i: Int) {
        self.self = Character(UnicodeScalar(i)!)
    }
}

extension Character {
    var unicode: Unicode.Scalar {
        return self.unicodeScalars.first!
    }

    var properties: Unicode.Scalar.Properties {
        return self.unicode.properties
    }

    public var uppercaseMapping: String {
        return self.properties.uppercaseMapping
    }

    public var lowercaseMapping: String {
        return self.properties.lowercaseMapping
    }

    public var titlecaseMapping: String {
        return self.properties.titlecaseMapping
    }

    public func toUpper() -> Character {
        return Character(self.uppercaseMapping)
    }

    public func toLower() -> Character {
        return Character(self.lowercaseMapping)
    }

    public func toTitle() -> Character {
        return Character(self.titlecaseMapping)
    }

    public var isTitlecase: Bool {
        return self.toTitle() == self
    }

    public func isdecimal() -> Bool {
        return self.properties.generalCategory == .decimalNumber
    }

    public func isdigit() -> Bool {
        if let numericType = self.properties.numericType {
            return numericType == .decimal || numericType == .digit
        }
        return false
    }
}

public func * (str: String, n: Int) -> String {
    return String(repeating: str, count: n > 0 ? n : 0)
}

public func * (n: Int, str: String) -> String {
    return String(repeating: str, count: n > 0 ? n : 0)
}

public func *= (str: inout String, n: Int) {
    str = String(repeating: str, count: n > 0 ? n : 0)
}

extension String {
    func at(_ i: Int) -> Character? {
        if self.count > i {
            return self[self.index(self.startIndex, offsetBy: i)]
        }
        return nil
    }

    public func capitalize() -> String {
        return self.prefix(1).uppercased() + self.dropFirst(1).lowercased()
    }

    public func casefold() -> String {
        var folded = ""
        for c in self {
            folded.append(casefoldTable[c.unicode.value, default: String(c)])
        }
        return folded
    }

    public func center(_ width: Int, fillchar: Character = " ") -> String {
        if self.count >= width {
            return self
        }
        let left = width - self.count
        let right = left / 2 + left % 2
        return String(repeating: fillchar, count: left - right) + self + String(repeating: fillchar, count: right)
    }

    public func count(_ sub: String, start: Int? = nil, end: Int? = nil) -> Int {
        let (start, end, _, length) = Slice(start: start, stop: end).adjustIndex(self.count)
        if sub.count == 0 {
            return length + 1
        }
        var n = self.find(sub, start: start, end: end)
        var c = 0
        while n != -1 {
            c += 1
            n = self.find(sub, start: n + sub.count, end: end)
        }
        return c
    }

    public func endswith(_ suffix: String, start: Int? = nil, end: Int? = nil) -> Bool {
        return self[start, end].hasSuffix(suffix)
    }

    public func endswith(_ suffix: [String], start: Int? = nil, end: Int? = nil) -> Bool {
        let str = self[start, end]
        for s in suffix {
            if str.hasSuffix(s) {
                return true
            }
        }
        return false
    }

    public func expandtabs(_ tabsize: Int = 8) -> String {
        return self.replace("\t", new: String(repeating: " ", count: tabsize))
    }

    static func make_table(_ pattern: String) -> [Character: Int] {
        var table: [Character: Int] = [:]
        let len = pattern.count - 1
        for i in 0..<len {
            table[pattern[i]] = len - i
        }
        return table
    }

    public func find(_ sub: String, start: Int? = nil, end: Int? = nil) -> Int {
        if sub.isEmpty {
            return 0
        }
        let (s, e, _, _) = Slice(start: start, stop: end).adjustIndex(self.count)
        var i = s
        let fin = e - sub.count
        while i <= fin {
            if self[i, i + sub.count] == sub {
                return i
            }
            i += 1
        }

        // let table = String.make_table(sub)
        // print("table:",table)

        // func skip_table(_ c:Character) -> Int {
        //     return table[c,default: sub.count]
        // }
        // var skip = s
        // while self.count - skip >= sub.count {
        //     var i = sub.count - 1
        //     while self[skip + i] == sub[i] {
        //         if i == 0 {
        //             return skip
        //         }
        //         i = i - 1
        //     }
        //     skip = skip + skip_table(self[skip + sub.count - 1])
        // }
        return -1
    }

    public func index(_ sub: String, start: Int? = nil, end: Int? = nil) throws -> Int {
        let i = self.find(sub, start: start, end: end)
        if i == -1 {
            throw PyException.ValueError("substring not found")
        }
        return i
    }

    private func isX(_ conditional: (Character) -> Bool, empty: Bool = false) -> Bool {
        if self.isEmpty {
            return empty
        }
        for chr in self {
            if !conditional(chr) {
                return false
            }
        }
        return true
    }

    public func isalnum() -> Bool {
        let alphaTypes: [Unicode.GeneralCategory] = [.modifierLetter, .titlecaseLetter, .uppercaseLetter, .lowercaseLetter, .otherLetter, .decimalNumber]
        return self.isX { (chr) -> Bool in
            alphaTypes.contains(chr.properties.generalCategory) || chr.properties.numericType != nil
        }
    }

    public func isalpha() -> Bool {
        let alphaTypes: [Unicode.GeneralCategory] = [.modifierLetter, .titlecaseLetter, .uppercaseLetter, .lowercaseLetter, .otherLetter]
        return self.isX { (chr) -> Bool in
            alphaTypes.contains(chr.properties.generalCategory)
        }
    }

    public func isascii() -> Bool {
        return self.isX({ (chr) -> Bool in
            chr.unicode.value >= 0 && chr.unicode.value <= 127
        }, empty: true)
    }

    public func isdecimal() -> Bool {
        return self.isX { (chr) -> Bool in
            chr.properties.generalCategory == .decimalNumber
        }
    }

    public func isdigit() -> Bool {
        return self.isX { (chr) -> Bool in
            if let numericType = chr.properties.numericType {
                return numericType == .decimal || numericType == .digit
            }
            return false
        }
    }

    public func islower() -> Bool {
        if self.isEmpty {
            return false
        }
        var hasCase = false
        for chr in self {
            if chr.isCased {
                if !chr.isLowercase {
                    return false
                }
                hasCase = true
            }
        }
        return hasCase
    }

    public func isnumeric() -> Bool {
        return self.isX { (chr) -> Bool in
            chr.properties.numericType != nil
        }
    }

    public func isprintable() -> Bool {
        let otherTypes: [Unicode.GeneralCategory] = [.otherLetter, .otherNumber, .otherSymbol, .otherPunctuation]
        let separatorTypes: [Unicode.GeneralCategory] = [.lineSeparator, .spaceSeparator, .paragraphSeparator]
        let maybeDisPrintable = otherTypes + separatorTypes
        return self.isX({ (chr) -> Bool in
            if maybeDisPrintable.contains(chr.properties.generalCategory) {
                return chr == " "
            }
            return true
        }, empty: true)
    }

    public func isspace() -> Bool {
        return self.isX { (chr) -> Bool in
            // TODO: unicode propaty
            chr.isWhitespace
        }
    }

    public func istitle() -> Bool {
        if self.isEmpty {
            return false
        }
        var prev_cased = false
        for chr in self {
            if !prev_cased {
                if !chr.isTitlecase {
                    return false
                }
            } else {
                if chr.isCased {
                    if !chr.isLowercase {
                        return false
                    }
                }
            }
            prev_cased = chr.isCased
        }
        return true
    }

    public func isupper() -> Bool {
        if self.isEmpty {
            return false
        }
        var hasCase = false
        for chr in self {
            if chr.isCased {
                if !chr.isUppercase {
                    return false
                }
                hasCase = true
            }
        }
        return hasCase
    }

    public func join(_ iterable: [String]) -> String {
        var str = ""
        for item in iterable {
            str += item
            str += self
        }
        return String(str.dropLast(self.count))
    }

    public func join(_ iterable: [Character]) -> String {
        var str = ""
        for item in iterable {
            str.append(item)
            str += self
        }
        return String(str.dropLast(self.count))
    }

    public func rjust(_ width: Int, fillchar: Character = " ") -> String {
        if self.count >= width {
            return self
        }
        let w = width - self.count
        return String(repeating: fillchar, count: w) + self
    }

    public func lower() -> String {
        return self.lowercased()
    }

    public func lstrip(_ chars: String? = nil) -> String {
        if self.isEmpty {
            return ""
        }
        var i = 0
        if let chars = chars {
            while chars.contains(self[i]) {
                i += 1
            }
            return self[i, nil]
        }
        while self[i].isWhitespace {
            i += 1
        }
        return self[i, nil]
    }

    public static func maketrans(_ x: [UInt32: String?]) -> [Character: String] {
        var _x: [Character: String?] = [:]
        for (key, value) in x {
            _x[Character(UnicodeScalar(key)!)] = value
        }
        return self.maketrans(_x)
    }

    public static func maketrans(_ x: [Character: String?]) -> [Character: String] {
        var cvTable: [Character: String] = [:]
        for (key, value) in x {
            cvTable[key] = value ?? ""
        }
        return cvTable
    }

    public static func maketrans(_ x: String, y: String, z: String = "") -> [Character: String] {
        var cvTable: [Character: String] = [:]
        func max(x: Int, y: Int) -> Int {
            if x > y {
                return x
            }
            return y
        }
        let loop: Int = max(x: x.count, y: y.count)
        for i in 0..<loop {
            cvTable[x[i]] = String(y[i])
        }
        for chr in z {
            cvTable[chr] = ""
        }
        return cvTable
    }

    public func partition(_ sep: String) -> (String, String, String) {
        let tmp = self.split(sep, maxsplit: 1)
        if tmp.count == 1 {
            return (self, "", "")
        }
        return (tmp[0], sep, tmp[1])
    }

    public func replace(_ old: String, new: String, count: Int = Int.max) -> String {
        if self.isEmpty, old.isEmpty, count == Int.max {
            return new
        }
        return new.join(self.split(old, maxsplit: count))
    }

    public func rfind(_ sub: String, start: Int? = nil, end: Int? = nil) -> Int {
        // TODO: Impl
        if sub.isEmpty {
            return self.count
        }
        var (s, e, _, _) = Slice(start: start, stop: end).adjustIndex(self.count)
        if (e - s) < sub.count {
            return -1
        }
        s -= 1
        var fin = e - sub.count
        while fin != s {
            if self[fin, fin + sub.count] == sub {
                return fin
            }
            fin -= 1
        }
        return -1
    }

    public func rindex(_ sub: String, start: Int? = nil, end: Int? = nil) throws -> Int {
        let i = self.rfind(sub, start: start, end: end)
        if i == -1 {
            throw PyException.ValueError("substring not found")
        }
        return i
    }

    public func ljust(_ width: Int, fillchar: Character = " ") -> String {
        if self.count >= width {
            return self
        }
        let w = width - self.count
        return self + String(repeating: fillchar, count: w)
    }

    public func rpartition(_ sep: String) -> (String, String, String) {
        let tmp = self._rsplit(sep, maxsplit: 1)
        if tmp.count == 1 {
            return ("", "", self)
        }
        return (tmp[0], sep, tmp[1])
    }

    func _rsplit(_ sep: String, maxsplit: Int) -> [String] {
        if self.isEmpty {
            return [self]
        }
        if sep.isEmpty {
            // error
            return self._rsplit(maxsplit: maxsplit)
        }
        var result: [String] = []
        var index = 0, prev_index = Int.max, sep_len = sep.count
        var maxsplit = maxsplit
        if maxsplit < 0 {
            maxsplit = Int.max
        }
        while maxsplit != 0 {
            index = self.rfind(sep, end: prev_index)
            if index == -1 {
                break
            }
            index += sep_len
            result.insert(self[index, prev_index], at: 0)
            index -= sep_len

            index -= 1
            prev_index = index + 1

            maxsplit -= 1

            if maxsplit == 0 {
                break
            }
        }
        result.insert(self[0, prev_index], at: 0)
        return result
    }

    func _rsplit(maxsplit: Int) -> [String] {
        var index = self.count - 1, len = 0
        var result: [String] = []
        var maxsplit = maxsplit
        if maxsplit < 0 {
            maxsplit = Int.max
        }
        for chr in self.reversed() {
            if chr.isWhitespace {
                if len != 0 {
                    result.insert(self[index, len], at: 0)
                    maxsplit -= 1
                    index -= len
                }
                index -= 1
                len = 0
            } else {
                len += 1
            }
        }
        let tmp = self[0, index + 1].rstrip()
        if tmp.count != 0 {
            result.insert(tmp, at: 0)
        }
        return result
    }

    public func rsplit(_ sep: String? = nil, maxsplit: Int = (-1)) -> [String] {
        if let sep = sep {
            return self._rsplit(sep, maxsplit: maxsplit)
        }
        return self._rsplit(maxsplit: maxsplit)
    }

    public func rstrip(_ chars: String? = nil) -> String {
        if self.isEmpty {
            return ""
        }
        var i = -1
        if let chars = chars {
            while chars.contains(self[i]) {
                i -= 1
            }
            return self[nil, i == -1 ? nil : i + 1]
        }
        while self[i].isWhitespace {
            i -= 1
        }
        return self[nil, i == -1 ? nil : i + 1]
    }

    func _split(_ sep: String, maxsplit: Int) -> [String] {
        if self.isEmpty {
            return [self]
        }
        if sep.isEmpty {
            // error
            return self._split(maxsplit: maxsplit)
        }
        var maxsplit = maxsplit
        var result: [String] = []
        if maxsplit < 0 {
            maxsplit = Int.max
        }
        var index = 0, prev_index = 0, sep_len = sep.count
        while maxsplit != 0 {
            index = self.find(sep, start: prev_index)
            if index == -1 {
                break
            }
            result.append(self[prev_index, index])
            prev_index = index + sep_len

            maxsplit -= 1
        }

        result.append(self[prev_index, nil])

        return result
    }

    func _split(maxsplit: Int) -> [String] {
        var maxsplit = maxsplit
        var result: [String] = []
        var index = 0
        var len = 0
        if maxsplit < 0 {
            maxsplit = Int.max
        }
        for chr in self {
            if chr.isWhitespace {
                if len != 0 {
                    result.append(self[index, len])
                    maxsplit -= 1
                    index += len
                }
                index += 1
                len = 0
            } else {
                len += 1
            }
            if maxsplit == 0 {
                break
            }
        }
        let tmp = self[index, nil].lstrip()
        if tmp.count != 0 {
            result.append(tmp)
        }
        return result
    }

    public func split(_ sep: String? = nil, maxsplit: Int = (-1)) -> [String] {
        if let sep = sep {
            return self._split(sep, maxsplit: maxsplit)
        }
        return self._split(maxsplit: maxsplit)
    }

    public func splitlines(_ keepends: Bool = false) -> [String] {
        let lineTokens = "\n\r\r\n\u{0b}\u{0c}\u{1c}\u{1d}\u{1e}\u{85}\u{2028}\u{2029}"
        var len = self.count, i = 0, j = 0, eol = 0
        var result: [String] = []
        while i < len {
            while i < len, !lineTokens.contains(self[i]) {
                i += 1
            }
            eol = i
            if i < len {
                i += 1
                if keepends {
                    eol = i
                }
            }
            result.append(self[j, eol])
            j = i
        }
        if j < len {
            result.append(self[j, eol])
        }
        return result
    }

    public func startswith(_ prefix: String, start: Int? = nil, end: Int? = nil) -> Bool {
        return self[start, end].hasPrefix(prefix)
    }

    public func startswith(_ prefix: [String], start: Int? = nil, end: Int? = nil) -> Bool {
        let str = self[start, end]
        for s in prefix {
            if str.hasPrefix(s) {
                return true
            }
        }
        return false
    }

    public func strip(_ chars: String? = nil) -> String {
        return self.lstrip(chars).rstrip(chars)
    }

    public func swapcase() -> String {
        var swapped = ""
        for chr in self {
            if chr.isASCII {
                if chr.isUppercase {
                    swapped.append(chr.lowercaseMapping)
                } else if chr.isLowercase {
                    swapped.append(chr.uppercaseMapping)
                } else {
                    swapped.append(chr)
                }
            } else {
                swapped.append(chr)
            }
        }
        return swapped
    }

    public func title() -> String {
        var titled = ""
        var prev_cased = false
        for chr in self {
            if !prev_cased {
                if !chr.isTitlecase {
                    titled.append(chr.titlecaseMapping)
                } else {
                    titled.append(chr)
                }
            } else {
                if chr.isCased {
                    if !chr.isLowercase {
                        titled.append(chr.lowercaseMapping)
                    } else {
                        titled.append(chr)
                    }
                } else {
                    titled.append(chr)
                }
            }
            prev_cased = chr.isCased
        }
        return titled
    }

    public func translate(_ table: [Character: String]) -> String {
        var transed = ""
        for chr in self {
            transed.append(table[chr, default: String(chr)])
        }
        return transed
    }

    public func upper() -> String {
        return self.uppercased()
    }

    public func zfill(_ width: Int) -> String {
        if !self.isEmpty {
            let h = self[0, 1]
            if h == "+" || h == "-" {
                return h + self[1, nil].rjust(width - 1, fillchar: "0")
            }
        }
        return self.rjust(width, fillchar: "0")
    }
}
