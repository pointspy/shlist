//
//  UIBezierPath+Squircle.swift
//  Pixel-iOS
//
//  Created by José Donor on 26/11/2018.
//

// Source : https://github.com/everdrone/react-native-squircle-view/blob/master/ios/RNSquircleView.swift
import UIKit

extension UIBezierPath {
    public convenience init(squircleIn bounds: CGRect,
                            cornerRadii: [UIRectCorner: CGFloat],
                            morphsIntoCircle: Bool) {
        let length = Swift.min(bounds.width, bounds.height)

        guard !(morphsIntoCircle && cornerRadii[.allCorners] == length / 2
            && bounds.width == bounds.height) else {
            self.init(ovalIn: bounds)
            return
        }

        self.init()

        let coeffs: [CGFloat] = [
            0.046412805499999994,
            0.133566352,
            0.22071989825,
            0.348614185,
            0.5115771475,
            0.67454011,
            0.8609766075,
            1.1579757175
        ]

        let normals: [CGFloat] = [
            0.049745972799999996,
            0.1365289826,
            0.22331199200000001,
            0.34713204000000003,
            0.495280188,
            0.643428336,
            0.815904584,
            1.0
        ]

        let count = 8

        var c = [CGFloat](repeating: 0, count: count)

        let max = length / 2
        let min = max / coeffs[7]

        let corners: [UIRectCorner] = [
            .topLeft,
            .topRight,
            .bottomRight,
            .bottomLeft
        ]

        var cornerRadii = cornerRadii.mapValues { $0.abs }

        if let radius = cornerRadii[.allCorners] {
            cornerRadii = [UIRectCorner: CGFloat](uniqueKeysWithValues: corners.map { ($0, radius) })
        }

        func interpolate(from a: CGFloat, to b: CGFloat, by p: CGFloat) -> CGFloat {
            return a + (b - a) * p
        }

        func normalize(_ radius: CGFloat) -> CGFloat {
            if morphsIntoCircle { return radius.max(max) }
            else { return radius.max(min) }
        }

        func interpolationAmount(_ radius: CGFloat) -> CGFloat {
            let norm = normalize(radius)
            return (norm - min) / (max - min)
        }

        func draw(corner: UIRectCorner,
                  biasX: CGFloat,
                  biasY: CGFloat,
                  invertX: Bool,
                  invertY: Bool,
                  swap: Bool) {
            let radius = cornerRadii[corner] ?? 0

            let n = normalize(radius)
            let p = interpolationAmount(radius)

            if morphsIntoCircle {
                (0..<count).forEach { c[$0] = interpolate(from: coeffs[$0], to: normals[$0], by: p) }
            } else {
                (0..<count).forEach { c[$0] = coeffs[$0] }
            }

            var u: [CGFloat] = [
                n * c[1], n * c[4],
                0, n * c[6],
                n * c[0], n * c[5],
                n * c[4], n * c[1],
                n * c[2], n * c[3],
                n * c[3], n * c[2],
                n * c[7], 0,
                n * c[5], n * c[0],
                n * c[6], 0
            ]

            if swap {
                (0..<u.endIndex / 2)
                    .map { $0 * 2 }
                    .forEach { u.swapAt($0, $0 + 1) }
            }

            let ix: CGFloat = invertX ? -1.0 : 1.0
            let iy: CGFloat = invertY ? -1.0 : 1.0
            let bx = biasX
            let by = biasY

            addCurve(to: .init(x: bx + ix * u[0], y: by + iy * u[1]),
                     controlPoint1: .init(x: bx + ix * u[2], y: by + iy * u[3]),
                     controlPoint2: .init(x: bx + ix * u[4], y: by + iy * u[5]))

            addCurve(to: .init(x: bx + ix * u[6], y: by + iy * u[7]),
                     controlPoint1: .init(x: bx + ix * u[8], y: by + iy * u[9]),
                     controlPoint2: .init(x: bx + ix * u[10], y: by + iy * u[11]))

            addCurve(to: .init(x: bx + ix * u[12], y: by + iy * u[13]),
                     controlPoint1: .init(x: bx + ix * u[14], y: by + iy * u[15]),
                     controlPoint2: .init(x: bx + ix * u[16], y: by + iy * u[17]))
        }

        let width = bounds.size.width
        let height = bounds.size.height

        corners.forEach { corner in

            let radius = cornerRadii[corner] ?? 0
            let p = interpolationAmount(radius)
            let n = normalize(radius)

            let value = interpolate(from: coeffs[7], to: 1, by: p)

            switch corner {
            case .topLeft:

                let point = CGPoint(x: 0, y: value * n)

                move(to: point)
                draw(corner: corner, biasX: 0, biasY: 0, invertX: false, invertY: false, swap: false)

            case .topRight:

                let point = CGPoint(x: width - value * n, y: 0)

                addLine(to: point)
                draw(corner: corner, biasX: width, biasY: 0, invertX: true, invertY: false, swap: true)

            case .bottomRight:

                let point = CGPoint(x: width, y: height - value * n)

                addLine(to: point)
                draw(corner: corner, biasX: width, biasY: height, invertX: true, invertY: true, swap: false)

            case .bottomLeft:

                let point = CGPoint(x: value * n, y: height)

                addLine(to: point)
                draw(corner: corner, biasX: 0, biasY: height, invertX: false, invertY: true, swap: true)

            default: fatalError("Corner \(corner) is not supported")
            }
        }

        close()

        apply(.init(translationX: bounds.x, y: bounds.y))
    }
}
