//
//  GameScene.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    static let SelectedObjectNotificationName = NSNotification.Name("selectedObject")
    
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
    
    var selectedObject: GKEntity? {
        didSet {
            NotificationCenter.default.post(name: GameScene.SelectedObjectNotificationName, object: self)
        }
    }
    
    weak var entityManager: EntityManager!
    var startPositions = [CGPoint]()
    
    
    func initializeGame() {
        do {
            let pandas = try LoadedRace(race: .panda, provider: XCAssetRaceProvider.self)
            if let mainBuilding = pandas.availableBuildings.first {
                let building = Building(template: mainBuilding, camp: 0, isMain: true)
                
                if let sprite = building.component(ofType: TextureComponent.self)?.sprite {
                    let startPosition = self.startPositions.randomValue ?? CGPoint(x: 1500, y: 1500)
                    sprite.position = startPosition
                }
                self.entityManager.insert(building)
            }
        } catch {
            print(error)
        }
    }
    
//    override func sceneDidLoad() {
//        super.sceneDidLoad()
//        
//        self.initializeGame()
//    }
    
    func updateBorderTracking(on view: NSView) {
        for area in trackingArea {
            view.removeTrackingArea(area)
        }
        let thresholdSize: CGFloat = 20.0
        
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
                        height: thresholdSize),
            .upLeft: NSRect(x: 0,
                            y: view.bounds.size.height - thresholdSize,
                            width: thresholdSize,
                            height: thresholdSize),
            .upRight: NSRect(x: view.bounds.size.width - thresholdSize,
                            y: view.bounds.size.height - thresholdSize,
                            width: thresholdSize,
                            height: thresholdSize),
            .downLeft: NSRect(x: 0,
                            y: 0,
                            width: thresholdSize,
                            height: thresholdSize),
            .downRight: NSRect(x: view.bounds.size.width - thresholdSize,
                             y: 0,
                             width: thresholdSize,
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
        self.initializeGame()
        self.updateBorderTracking(on: view)
    }
    
    override func scrollWheel(with event: NSEvent) {
//        self.debugText = "scrollingDeltaY : \(event.scrollingDeltaY)"
        guard let camera = self.camera else {
            return
        }
        let scale = event.scrollingDeltaY / 10.0
        camera.xScale += scale
        camera.yScale += scale
        
        camera.xScale = camera.xScale.contained(in: 0.1..<1)
        camera.yScale = camera.yScale.contained(in: 0.1..<1)
//        self.debugText = "\(self.camera?.yScale)"
    }
    
    override func mouseUp(with event: NSEvent) {
        guard event.locationInWindow.y > 120 else {
            // click on the interface : if the case, handled by buttons
            return
        }
        
        let location = event.location(in: self)
        let nodes = self.nodes(at: location).filter { $0 is SKSpriteNode }
        if let selectedEntity = nodes.first?.entity {
            self.selectedObject = selectedEntity
        } else {
            self.selectedObject = nil
            self.debugText = "empty location : (x: \(location.x), y : \(location.y))"
        }
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
//        self.debugText = "camera.position = \(camera.position)"
        if let border = self.moveBorder {
            // si la camera touche le bord selon la border, on bouge aps
            let cameraSize = CGSize(width: camera.xScale * self.size.width,
                                    height: camera.yScale * self.size.height)
            let cameraOrigin = CGPoint(x: camera.position.x - cameraSize.width / 2,
                                       y: camera.position.y - cameraSize.height / 2)
            let cameraFrame = CGRect(origin: cameraOrigin, size: cameraSize)
            
            guard let direction = border.directionAvailable(cameraFrame: cameraFrame, mapSize: self.size, uiHeight: 120) else {
                camera.removeAction(forKey: "moveCamera")
                return
            }
            
            if let existingAction = camera.action(forKey: "moveCamera") {
                existingAction.duration += 0.1
            } else {
                let vector = direction * 60.0
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
