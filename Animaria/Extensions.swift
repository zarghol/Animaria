//
//  Int+Random.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation
import GameplayKit


extension Int {
    static func random(in range: Range<Int>? = nil) -> Int {
        let source = GKRandomSource.sharedRandom()
        guard let range = range else {
            return source.nextInt()
        }
        guard range.lowerBound >= 0 else {
            return 0 // throw ??
        }
        
        guard !range.isEmpty else {
            return range.lowerBound
        }
        
        let interval = range.upperBound - range.lowerBound
        return source.nextInt(upperBound: interval) + range.lowerBound
    }
}

extension SKView {
    open override func scrollWheel(with event: NSEvent) {
        self.scene?.scrollWheel(with: event)
    }
}

extension CGVector {
    static func * (left: CGVector, right: CGFloat) -> CGVector {
        var newVector = left
        newVector.dx *= right
        newVector.dy *= right
        return newVector
    }

    static func + (left: CGVector, right: CGVector) -> CGVector {
        var newVector = left
        newVector.dx += right.dx
        newVector.dy += right.dy
        return newVector
    }
}

extension vector_float2 {
    var pointValue: CGPoint {
        return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
}

extension CGPoint {
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        var newVector = left
        newVector.x *= right
        newVector.y *= right
        return newVector
    }

    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        var newVector = left
        newVector.x /= right
        newVector.y /= right
        return newVector
    }

    var vector2_floatValue: vector_float2 {
        return vector_float2(x: Float(self.x), y: Float(self.y))
    }
}

extension CGSize {
    static func / (left: CGSize, right: CGFloat) -> CGSize {
        var newVector = left
        newVector.height /= right
        newVector.width /= right
        return newVector
    }
}

extension CGFloat {
    func contained(in range: Range<CGFloat>) -> CGFloat {
        return CGFloat.maximum(CGFloat.minimum(self, range.upperBound), range.lowerBound)
    }
}

extension Dictionary {
    func map<T: Hashable, U>(_ transform: ((key: Key, value: Value)) throws -> (T, U)) rethrows -> [T: U] {
        var result = [T: U]()
        for (key, value) in self {
            let (newKey, newValue) = try transform((key, value))
            result[newKey] = newValue
        }
        return result
    }
}

extension Array {
    func subset<Value: Equatable>(filterPath: KeyPath<Element, Value>, values: [Value]) -> [Element] {
        return self.filter { values.contains($0[keyPath: filterPath]) }
    }
}
