//
//  EntityManager.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation
import GameplayKit


class EntityManager {
    lazy var componentSystems: [GKComponentSystem] = {
        let skillBookSystem = GKComponentSystem(componentClass: SkillBookComponent.self)
        let moveSystem = GKComponentSystem(componentClass: MoveableComponent.self)
//        let energyStorageSystem = GKComponentSystem(componentClass: EnergyAccumulatorComponent.self)
//        return [photosynthesisSystem, energyStorageSystem, reproductionSystem]
        return [skillBookSystem, moveSystem]
    }()
    
    var toAdd = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    
    private(set) var entities = Set<GKEntity>()
    unowned let scene: SKScene
    unowned let minimapScene: SKScene
    
    init(scene: SKScene, minimapScene: SKScene) {
        self.scene = scene
        self.minimapScene = minimapScene
    }
    
    func insert(_ entity: GKEntity) {
        entities.insert(entity)
        
        for system in self.componentSystems {
            system.addComponent(foundIn: entity)
        }
        
        if let textureComponent = entity.component(ofType: TextureComponent.self) {
            scene.addChild(textureComponent.sprite)
            minimapScene.addChild(textureComponent.minMapNode)
        }
    }
    
    func remove(_ entity: GKEntity) {
        if let textureComponent = entity.component(ofType: TextureComponent.self) {
            textureComponent.sprite.removeFromParent()
            textureComponent.minMapNode.removeFromParent()
        }
        
        entities.remove(entity)
        toRemove.insert(entity)
    }

//    func createEntity<EntityType: GKEntity>(type: EntityType.Type, _ initialize: @escaping (EntityType) -> Void) {
//        let newEntity = EntityType()
//        initialize(newEntity)
//        self.toAdd.insert(newEntity)
//    }
    
    func update(deltaTime seconds: TimeInterval) {
        self.componentSystems.forEach { $0.update(deltaTime: seconds) }
        
        for entity in self.toRemove {
            for system in self.componentSystems {
                system.removeComponent(foundIn: entity)
            }
        }
        toRemove.removeAll()
        
        self.toAdd.forEach { self.insert($0) }
        
        toAdd.removeAll()
    }
}
