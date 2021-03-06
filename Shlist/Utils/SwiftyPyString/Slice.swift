//
//  Slice.swift
//  SwiftyPyString
//

public class Slice {
    var start: Int?
    var stop: Int?
    var step: Int?

    public func indices(_ length: Int) -> (Int, Int, Int) {
        let (a, b, c, _) = self.adjustIndex(length)
        return (a, b, c)
    }

    public init(stop: Int?) {
        self.stop = stop
    }

    public init(start: Int?, stop: Int?, step: Int? = nil) {
        self.start = start
        self.stop = stop
        self.step = step
    }

    func adjustIndex(_ length: Int) -> (Int, Int, Int, Int) {
        let step: Int = (self.step == 0) ? 1 : self.step ?? 1
        var start: Int = 0
        var stop: Int = 0
        var upper: Int = 0
        var lower: Int = 0

        // Convert step to an integer; raise for zero step.
        let step_sign: Int = step.signum()
        let step_is_negative: Bool = step_sign < 0

        /* Find lower and upper bounds for start and stop. */
        if step_is_negative {
            lower = -1
            upper = length + lower
        }
        else {
            lower = 0
            upper = length
        }

        // Compute start.
        if let s = self.start {
            start = s

            if start.signum() < 0 {
                start += length

                if start < lower /* Py_LT */ {
                    start = lower
                }
            }
            else {
                if start > upper /* Py_GT */ {
                    start = upper
                }
            }
        }
        else {
            start = step_is_negative ? upper : lower
        }

        // Compute stop.
        if let s = self.stop {
            stop = s

            if stop.signum() < 0 {
                stop += length
                if stop < lower /* Py_LT */ {
                    stop = lower
                }
            }
            else {
                if stop > upper /* Py_GT */ {
                    stop = upper
                }
            }
        }
        else {
            stop = step_is_negative ? lower : upper
        }
        var len = 0
        if step < 0 {
            if stop < start {
                len = (start - stop - 1) / (-step) + 1
            }
        }
        else {
            if start < stop {
                len = (stop - start - 1) / step + 1
            }
        }
        return (start, stop, step, len)
    }
}

func backIndex(i: Int, l: Int) -> Int {
    return i < 0 ? l + i : i
}

public protocol Sliceable: Collection {
    init()
    subscript(_ start: Int?, _ stop: Int?, _ step: Int?) -> Self { get }
    subscript(_ start: Int?, _ end: Int?) -> Self { get }
    subscript(_ i: Int) -> Self.Element { get }
    subscript(_ slice: Slice) -> Self { get }
    mutating func append(_ newElement: Self.Element)
}

extension Sliceable {
    public subscript(_ start: Int?, _ stop: Int?, _ step: Int?) -> Self {
        return self[Slice(start: start, stop: stop, step: step)]
    }

    public subscript(_ start: Int?, _ end: Int?) -> Self {
        return self[start, end, nil]
    }

    public subscript(_ slice: Slice) -> Self {
        var (start, _, step, loop) = slice.adjustIndex(self.count)
        var result = Self()
        for _ in 0..<loop {
            result.append(self[start])
            start += step
        }
        return result
    }
}

extension String: Sliceable {
    public subscript(_ i: Int) -> Character {
        get {
            return self[self.index(self.startIndex, offsetBy: backIndex(i: i, l: self.count))]
        } set(c) {
            let v = self.index(self.startIndex, offsetBy: backIndex(i: i, l: self.count))
            let v2 = self.index(v, offsetBy: 1)
            self.replaceSubrange(v..<v2, with: [c])
        }
    }
}
