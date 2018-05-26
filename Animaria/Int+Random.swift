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
