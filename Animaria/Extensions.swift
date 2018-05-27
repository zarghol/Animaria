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

extension Array {
    var randomValue: Element? {
        guard self.count > 0 else {
            return nil
        }
        return self[Int.random(in: 0..<self.count)]
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
}

extension CGFloat {
    func contained(in range: Range<CGFloat>) -> CGFloat {
        return CGFloat.maximum(CGFloat.minimum(self, range.upperBound), range.lowerBound)
    }
}
