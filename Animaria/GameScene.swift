//
//  GameScene.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import SpriteKit
import GameplayKit


extension CGVector {
    static func * (left: CGVector, right: CGFloat) -> CGVector {
        var newVector = left
        newVector.dx *= right
        newVector.dy *= right
        return newVector
    }
}

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
    
    func cameraCanMove(cameraFrame: CGRect, mapSize: CGSize) -> Bool {
        switch self {
        case .up:
            return cameraFrame.maxY < mapSize.height
        case .down:
            return cameraFrame.minY > 0
        case .left:
            return cameraFrame.minX > 0
        case .right:
            return cameraFrame.maxX < mapSize.width
        case .upLeft:
            return cameraFrame.maxY < mapSize.height && cameraFrame.minX > 0
        case .upRight:
            return cameraFrame.maxY < mapSize.height && cameraFrame.maxX < mapSize.width
        case .downLeft:
            return cameraFrame.minY > 0 && cameraFrame.minX > 0
        case .downRight:
            return cameraFrame.minY > 0 && cameraFrame.maxX < mapSize.width
        }
    }
}

class GameScene: SKScene {
    
    @objc var debugText: String = "Debug Label" {
        willSet {
            willChangeValue(forKey: "debugText")
        }
        
        didSet {
            didChangeValue(forKey: "debugText")
        }
    }
    
    var lastUpdateTime: TimeInterval = 0
    
    var moveBorder: ScreenBorderType?
    
    var trackingArea = [NSTrackingArea]()
    
//    override func sceneDidLoad() {
//        super.sceneDidLoad()
//        if let cameraNode = self.childNode(withName: "camera") as? SKCameraNode {
//            self.camera = cameraNode
//        }
//    }
    
    func updateBorderTracking(on view: NSView) {
        for area in trackingArea {
            view.removeTrackingArea(area)
        }
        let thresholdSize: CGFloat = 30.0
        
        let rects: [ScreenBorderType: NSRect] = [
            .left: NSRect(x: 0,
                          y: thresholdSize,
                          width: thresholdSize,
                          height: view.bounds.size.height - 2 * thresholdSize),
            .right: NSRect(x: view.bounds.size.width - thresholdSize,
                           y: thresholdSize,
                           width: thresholdSize,
                           height: view.bounds.size.height - 2 * thresholdSize),
            .up: NSRect(x: thresholdSize,
                        y: view.bounds.size.height - thresholdSize,
                        width: view.bounds.size.width - 2 * thresholdSize,
                        height: thresholdSize),
            .down: NSRect(x: thresholdSize,
                        y: 0,
                        width: view.bounds.size.width - 2 * thresholdSize,
                        height: thresholdSize)
        ]
        
        for (type, rect) in rects {
            let area = NSTrackingArea(rect: rect, options: [.activeWhenFirstResponder, .enabledDuringMouseDrag, .mouseEnteredAndExited], owner: self, userInfo: ["border": type])
            self.trackingArea.append(area)
            view.addTrackingArea(area)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        self.updateBorderTracking(on: view)
    }
    
    override func scrollWheel(with event: NSEvent) {
        self.debugText = "deltaZ = \(event.deltaZ), scrollingDeltaY : \(event.scrollingDeltaY)"
//        event.deltaZ
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        self.debugText = "Mouse Up : (x: \(location.x), y : \(location.y))"
//        self.camera?.position = location
    }
    
    override func mouseMoved(with event: NSEvent) {
        let location = event.location(in: self)
        self.debugText = "Move : (x: \(location.x), y : \(location.y))"
    }
    
    override func mouseEntered(with event: NSEvent) {
        guard let data = event.trackingArea?.userInfo,
              let borderType = data["border"] as? ScreenBorderType else {
            return
        }
        
        self.moveBorder = borderType
//        self.debugText = "borderType : \(borderType)"
    }
    
    override func mouseExited(with event: NSEvent) {
//        self.debugText = "mouseExited"
        self.moveBorder = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }

        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        self.updateCameraPosition()
        
//        // Update entities
//        for entity in self.entities {
//            entity.update(deltaTime: dt)
//        }
//        
        self.lastUpdateTime = currentTime
    }
    
    func updateCameraPosition() {
        guard let camera = self.camera else {
            return
        }
        self.debugText = "camera.position = \(camera.position)"
        if let border = self.moveBorder {
            // si la camera touche le bord selon la border, on bouge aps
            let cameraSize = CGSize(width: camera.xScale * self.size.width,
                                    height: camera.yScale * self.size.height)
            let cameraOrigin = CGPoint(x: camera.position.x - cameraSize.width / 2,
                                       y: camera.position.y - cameraSize.height / 2)
            let cameraFrame = CGRect(origin: cameraOrigin, size: cameraSize)
            
            guard border.cameraCanMove(cameraFrame: cameraFrame, mapSize: self.size) else {
                camera.removeAction(forKey: "moveCamera")
                return
            }
            
            if let existingAction = camera.action(forKey: "moveCamera") {
                existingAction.duration += 0.1
            } else {
                let vector = border.direction * 60.0
                let moveCamera = SKAction.move(by: vector, duration: 0.1)
                camera.run(moveCamera, withKey: "moveCamera")
            }
        } else {
            camera.removeAction(forKey: "moveCamera")
        }
    }
}

extension GameScene: NSWindowDelegate {
    func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              let view = window.contentView as? SKView else {
            return
        }
        self.updateBorderTracking(on: view)
    }
}
