//
//  ScreenBorderType.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

enum ScreenBorderType {
    case up, down, left, right, upLeft, upRight, downLeft, downRight
    
    var direction: CGVector {
        switch self {
        case .up:
            return CGVector(dx: 0, dy: 1)
        case .down:
            return CGVector(dx: 0, dy: -1)
        case .left:
            return CGVector(dx: -1, dy: 0)
        case .right:
            return CGVector(dx: 1, dy: 0)
        case .upLeft:
            return CGVector(dx: -1, dy: 1)
        case .upRight:
            return CGVector(dx: 1, dy: 1)
        case .downLeft:
            return CGVector(dx: -1, dy: -1)
        case .downRight:
            return CGVector(dx: 1, dy: -1)
        }
    }
    
    func directionAvailable(cameraFrame: CGRect, mapSize: CGSize, uiHeight: CGFloat) -> CGVector? {
        switch self {
        case .up:
            return cameraFrame.maxY < mapSize.height ? self.direction : nil
        case .down:
            return cameraFrame.minY > -1 * uiHeight ? self.direction : nil
        case .left:
            return cameraFrame.minX > 0 ? self.direction : nil
        case .right:
            return cameraFrame.maxX < mapSize.width ? self.direction : nil
        case .upLeft:
            let upComposant = cameraFrame.maxY < mapSize.height
            let leftComposant = cameraFrame.minX > 0
            switch (leftComposant, upComposant) {
            case (true, true):
                return self.direction
            case (true, false):
                return ScreenBorderType.left.direction
            case (false, true):
                return ScreenBorderType.up.direction
            case (false, false):
                return nil
            }
        case .upRight:
            let rightComposant = cameraFrame.maxX < mapSize.width
            let upComposant = cameraFrame.maxY < mapSize.height
            switch (rightComposant, upComposant) {
            case (true, true):
                return self.direction
            case (true, false):
                return ScreenBorderType.right.direction
            case (false, true):
                return ScreenBorderType.up.direction
            case (false, false):
                return nil
            }
        case .downLeft:
            let leftComposant = cameraFrame.minX > 0
            let downComposant = cameraFrame.minY > -1 * uiHeight
            switch (leftComposant, downComposant) {
            case (true, true):
                return self.direction
            case (true, false):
                return ScreenBorderType.left.direction
            case (false, true):
                return ScreenBorderType.down.direction
            case (false, false):
                return nil
            }
        case .downRight:
            let rightComposant = cameraFrame.maxX < mapSize.width
            let downComposant = cameraFrame.minY > -1 * uiHeight
            switch (rightComposant, downComposant) {
            case (true, true):
                return self.direction
            case (true, false):
                return ScreenBorderType.right.direction
            case (false, true):
                return ScreenBorderType.down.direction
            case (false, false):
                return nil
            }
        }
    }
}
