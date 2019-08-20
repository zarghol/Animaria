//
//  MoveableComponent.swift
//  Animaria
//
//  Created by Clément NONN on 08/06/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit

private class TargetAgent: GKAgent2D {
    init(position: CGPoint) {
        super.init()
        self.position = position.vector2_floatValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MoveableComponent: GKAgent2D {
    var destination: CGPoint? {
        didSet {
            if let destination = destination {
                self.behavior?.removeAllGoals()
                let seekGoal = GKGoal(toSeekAgent: TargetAgent(position: destination))
                let agents = entityManager.allTextures.map { TargetAgent(position: $0.position) }
                let avoidGoal = GKGoal(toAvoid: agents, maxPredictionTime: 1.0)
                self.behavior = GKBehavior(weightedGoals: [seekGoal: 0.8, avoidGoal: 1.0])
                self.maxAcceleration = possibleAcceleration
            } else {
                self.behavior?.removeAllGoals()
                self.speed = 0.0
                self.maxAcceleration = 0.0
            }
        }
    }

    private var possibleAcceleration: Float
    private unowned var entityManager: EntityManager

    init(positionComponent: TextureComponent, speed: Float, acceleration: Float, entityManager: EntityManager) {
        self.possibleAcceleration = acceleration
        self.entityManager = entityManager
        super.init()
        self.radius = Float(positionComponent.sprite.size.height / 2) // TODO: use pythagore to compute the radius
        self.position = positionComponent.position.vector2_floatValue
        self.delegate = positionComponent
        self.maxSpeed = speed
        self.maxAcceleration = acceleration
        self.mass = 0.01
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
