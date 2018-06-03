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
//        let reproductionSystem = GKComponentSystem(componentClass: CloningReproductionComponent<Grass>.self)
//        let energyStorageSystem = GKComponentSystem(componentClass: EnergyAccumulatorComponent.self)
//        return [photosynthesisSystem, energyStorageSystem, reproductionSystem]
        return [skillBookSystem]
    }()
    
    var toAdd = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    
    private(set) var entities = Set<GKEntity>()
    let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func insert(_ entity: GKEntity) {
        entities.insert(entity)
        
        for system in self.componentSystems {
            system.addComponent(foundIn: entity)
        }
        
        if let spriteNode = entity.component(ofType: TextureComponent.self)?.sprite {
            scene.addChild(spriteNode)
        }
    }
    
    func remove(_ entity: GKEntity) {
        if let spriteNode = entity.component(ofType: TextureComponent.self)?.sprite {
            spriteNode.removeFromParent()
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
