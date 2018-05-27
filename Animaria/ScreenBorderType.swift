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
    
    func cameraCanMove(cameraFrame: CGRect, mapSize: CGSize, uiHeight: CGFloat) -> Bool {
        switch self {
        case .up:
            return cameraFrame.maxY < mapSize.height
        case .down:
            return cameraFrame.minY > -1 * uiHeight
        case .left:
            return cameraFrame.minX > 0
        case .right:
            return cameraFrame.maxX < mapSize.width
        case .upLeft:
            return cameraFrame.maxY < mapSize.height && cameraFrame.minX > 0
        case .upRight:
            return cameraFrame.maxY < mapSize.height && cameraFrame.maxX < mapSize.width
        case .downLeft:
            return cameraFrame.minY > -1 * uiHeight && cameraFrame.minX > 0
        case .downRight:
            return cameraFrame.minY > -1 * uiHeight && cameraFrame.maxX < mapSize.width
        }
    }
}
