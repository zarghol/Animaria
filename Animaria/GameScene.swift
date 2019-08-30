//
//  GameScene.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameError {
    enum Initialization: Error {
        case raceNotFound(Race)
        case resourcesNotInitialized(Error)
        case buildingTemplateNotAvailable
        case noStartPositionsFound
        case cameraNotFound
        case minimapCameraNotFound
    }

    enum ComponentsError: Error {
        case cantGetComponent(GKEntity, GKComponent.Type)
    }
}

extension GKEntity {
    func component<T: GKComponent>(type: T.Type) throws -> T {
        guard let component = self.component(ofType: type) else {
            throw GameError.ComponentsError.cantGetComponent(self, type)
        }
        return component
    }
}

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
    
    var entityManager: EntityManager!
    var waitingSkill: Skill?

    var minimapScene: SKScene!

    var startPositions = [CGPoint]()
    @objc var camps = [Camp]()

    @objc weak var playerCamp: Camp!

    func initializeGame() throws {
        let race = Race.panda
        guard let pandas = RaceRepository.all[race] else {
            throw GameError.Initialization.raceNotFound(race)
        }
        let initialCamp = Camp(id: 0, race: pandas)
        do {
            try initialCamp.collect(.wood, quantity: 100)
            try initialCamp.collect(.metal, quantity: 10)
            try initialCamp.collect(.crystal, quantity: 100)
        } catch {
            throw GameError.Initialization.resourcesNotInitialized(error)
        }

        camps.append(initialCamp)
        self.playerCamp = initialCamp
        guard let mainBuilding = initialCamp.templates.availableBuildings.first else {
            throw GameError.Initialization.buildingTemplateNotAvailable
        }

        let building = Building(template: mainBuilding, camp: initialCamp, isMain: true, entityManager: entityManager)

        guard let startPosition = self.startPositions.randomElement() else {
            throw GameError.Initialization.noStartPositionsFound
        }

        let buildingTextureComponent = try building.component(type: TextureComponent.self)
        buildingTextureComponent.position = startPosition

        self.entityManager.insert(building)

        guard let firstUnit = initialCamp.templates.availableCharacters.first else {
            throw GameError.Initialization.buildingTemplateNotAvailable
        }

        let unit = Character(template: firstUnit, camp: initialCamp, entityManager: entityManager)
        let unitTextureComponent = try unit.component(type: TextureComponent.self)

        let unitStartPosition = startPosition.applying(CGAffineTransform(translationX: 0.0, y: -buildingTextureComponent.sprite.size.height))
        unitTextureComponent.position = unitStartPosition

        self.entityManager.insert(unit)

        guard let camera = self.camera else {
            throw GameError.Initialization.cameraNotFound
        }
        camera.position = startPosition
        guard let cameraMinimap = self.minimapScene.childNode(withName: "cameraRect") else {
            throw GameError.Initialization.minimapCameraNotFound
        }
        let ratio = self.minimapScene.size.height / self.size.height
        cameraMinimap.position = camera.position * ratio
    }

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

        do {
            try self.initializeGame()
        } catch {
            self.debugText = "initializing error : \(error)"
        }

        self.updateBorderTracking(on: view)
    }
    
    override func scrollWheel(with event: NSEvent) {
//        self.debugText = "scrollingDeltaY : \(event.scrollingDeltaY)"
        guard let camera = self.camera else {
            return
        }

        let scale = camera.yScale + event.scrollingDeltaY / 10.0
        self.camera?.setScale(scale.contained(in: 0.2..<1))
//        self.debugText = "\(self.camera?.yScale)"
    }

    // MARK: - Skills
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let nodes = self.nodes(at: location).filter { $0 is SKSpriteNode }
        if let selectedEntity = nodes.first?.entity {
            if let waitingSkill = waitingSkill, case SkillTemplateTarget.entity(_) = waitingSkill.template.target {
                waitingSkill.target = .entity(selectedEntity)
                do {
                    try executeSkill(waitingSkill)
                } catch {
                    print("unable to execute skill to late : \(error)")
                }
            } else {
                waitingSkill = nil
                self.selectedObject = selectedEntity
            }
        } else {
            if let waitingSkill = waitingSkill, case SkillTemplateTarget.position(_) = waitingSkill.template.target {
                waitingSkill.target = .position(location)
                do {
                    try executeSkill(waitingSkill)
                } catch {
                    print("unable to execute skill to late : \(error)")
                }
            } else {
                waitingSkill = nil
                self.selectedObject = nil
                self.debugText = "empty location : \(event.locationInWindow) \(location)"
            }
        }
    }

    override func rightMouseUp(with event: NSEvent) {
        // do the prior action with the selected element
        guard let selectedEntity = self.selectedObject else {
            return
        }

        if waitingSkill != nil {
            waitingSkill = nil
        }

        let location = event.location(in: self)

        if let clickedEntity = self.nodes(at: location).filter ({ $0 is SKSpriteNode }).first?.entity {
            if let resourceComponent = clickedEntity.component(ofType: ResourceComponent.self), resourceComponent.amount > 0 {
                print("go and harvest !")
                do {
                    try selectedEntity.component(ofType: SkillBookComponent.self)?.execute(shortcut: .harvest(target: clickedEntity))
                } catch {
                    print("error when trying to harvest: \(error)")
                }
            } else {
                print("go ? (entity : \(clickedEntity))")
                go(selectedEntity, to: location)
            }
        } else {
            print("go !")
            go(selectedEntity, to: location)
        }
    }

    func go(_ selectedEntity: GKEntity, to location: CGPoint) {
        if let moveComponent = selectedEntity.component(ofType: MoveableComponent.self) {
            moveComponent.destination = location
        }
    }

    func executeSkill(_ skill: Skill) throws {
        guard let selectedEntity = self.selectedObject,
            let skillsComponent = selectedEntity.component(ofType: SkillBookComponent.self) else {
                return
        }

        do {
            try skillsComponent.execute(skill)
            NotificationCenter.default.post(name: GameScene.SelectedObjectNotificationName, object: self)
        } catch SkillError.needTarget {
            self.waitingSkill = skill
            throw SkillError.needTarget
        } catch {
            throw error
        }
    }

    func selectSkill(index: Int) throws {
        guard let selectedEntity = self.selectedObject,
            let skillsComponent = selectedEntity.component(ofType: SkillBookComponent.self) else {
                return
        }
        let skill = skillsComponent.filteredSkills[index]

        try executeSkill(skill)
    }

    // MARK: ----------------------------
    
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
        self.debugText = "borderType : \(borderType)"
    }
    
    override func mouseExited(with event: NSEvent) {
        self.debugText = "mouseExited"
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
        self.entityManager.update(deltaTime: dt)

        self.lastUpdateTime = currentTime
    }
    
    func updateCameraPosition() {
        guard let camera = self.camera, let view = self.view else {
            return
        }
//        self.debugText = "camera.position = \(camera.position)"
        if let border = self.moveBorder {
            // si la camera touche le bord selon la border, on bouge pas
            let cameraWidth = camera.xScale * self.size.width
            let cameraHeight = cameraWidth * view.frame.size.height / view.frame.size.width

            let cameraFrame = CGRect(
                x: camera.position.x - cameraWidth / 2,
                y: camera.position.y - cameraHeight / 2,
                width: cameraWidth,
                height: cameraHeight
            )
            
            if let cameraMinimap = self.minimapScene.childNode(withName: "cameraRect") {
                let ratio = self.minimapScene.size.height / self.size.height
                cameraMinimap.position = camera.position * ratio
            }
            
            let uiHeight = 200.0 * cameraHeight / view.frame.size.height
//            self.debugText = "\(cameraFrame)"
            guard let direction = border.directionAvailable(cameraFrame: cameraFrame, mapSize: self.size, uiHeight: uiHeight) else {
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

    func createMinimap(with viewHeight: Int, originalMapSize: CGSize) {
        let minimapScene = SKScene(size: CGSize(width: viewHeight, height: viewHeight))

        let ratio = self.size.height / CGFloat(viewHeight)
        for index in 0..<(viewHeight * viewHeight) {
            let minimapCoord = CGPoint(x: index % viewHeight, y: index / viewHeight)
            let realCoord = minimapCoord * ratio

            let color = self.determineBackground(for: realCoord)?.color ?? .clear

            let colorNode = SKSpriteNode(color: color, size: CGSize(width: 1, height: 1))
            colorNode.position = minimapCoord
            minimapScene.addChild(colorNode)
        }

        let cameraWidth = camera!.xScale * self.size.width
        let cameraHeight = cameraWidth * originalMapSize.height / originalMapSize.width
        let cameraSize = CGSize(width: cameraWidth, height: cameraHeight)
        let size = cameraSize / ratio
        let cameraRect = SKShapeNode(rectOf: size)
        cameraRect.strokeColor = .black
        cameraRect.fillColor = .clear
        cameraRect.position = .zero
        cameraRect.name = "cameraRect"
        cameraRect.position = camera!.position / ratio
        minimapScene.addChild(cameraRect)

        self.minimapScene = minimapScene
    }

    enum TileType: String, CaseIterable {
        case water, sand, grass, cobblestone

        var color: NSColor {
            switch self {
            case .cobblestone:
                return .gray
            case .grass:
                return .green
            case .sand:
                return .yellow
            case .water:
                return .blue
            }
        }

        var name: String {
            switch self {
            case .cobblestone:
                return "Cobblestone"
            case .grass:
                return "Grass"
            case .sand:
                return "Sand"
            case .water:
                return "Water"
            }
        }
    }

    func determineBackground(for coordinate: CGPoint) -> TileType? {
        let tileNodes = self.children.compactMap { $0 as? SKTileMapNode }
        let names: [String] = tileNodes.compactMap {
            let rowIndex = $0.tileRowIndex(fromPosition: coordinate)
            let columnIndex = $0.tileColumnIndex(fromPosition: coordinate)
            let definition = $0.tileDefinition(atColumn: columnIndex, row: rowIndex)

            return definition?.name
        }

        guard !names.isEmpty else {
            return nil
        }

        let orderedTiles: [TileType] = [.water, .cobblestone, .sand, .grass]
        for type in orderedTiles {
            if names.contains(where: { $0.contains(type.name) }) {
                return type
            }
        }
        return nil
    }
}

extension Resource {
    func canBePlaced(on tile: GameScene.TileType) -> Bool {
        switch (self, tile) {
        case (.wood, .grass):
            return true
        case (.crystal, .grass), (.crystal, .sand):
            return true
        case (.metal, .grass):
            return true
        default:
            return false
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
