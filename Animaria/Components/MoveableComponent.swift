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
    private weak var currentSeekGoak: GKGoal?
    private let stopGoal = GKGoal(toReachTargetSpeed: 0.0)

    var destination: CGPoint? {
        didSet {
            if let currentSeekGoak = currentSeekGoak {
                behavior?.remove(currentSeekGoak)
            }

            if let destination = destination {
                let seekGoal = GKGoal(toSeekAgent: TargetAgent(position: destination))

                currentSeekGoak = seekGoal

                behavior?.remove(stopGoal)
                behavior = GKBehavior(goal: seekGoal, weight: 50.0)
            } else {
                behavior?.setWeight(100.0, for: stopGoal)
            }
        }
    }

    private weak var currentAvoidGoal: GKGoal?

    func updateObstacles() {
        if let currentAvoidGoal = currentAvoidGoal {
            self.behavior?.remove(currentAvoidGoal)
        }

        let agents = entityManager.allTextures.map { TargetAgent(position: $0.position) }
        let avoidGoal = GKGoal(toAvoid: agents, maxPredictionTime: 25.0)

        currentAvoidGoal = avoidGoal
        self.behavior?.setWeight(1.0, for: avoidGoal)
    }
    private unowned var entityManager: EntityManager

    init(positionComponent: TextureComponent, speed: Float, acceleration: Float, entityManager: EntityManager) {
        self.entityManager = entityManager
        super.init()
        self.radius = Float(positionComponent.sprite.size.height / 2) // TODO: use pythagore to compute the radius
        self.position = positionComponent.position.vector2_floatValue
        self.delegate = positionComponent
        self.maxSpeed = speed
        self.maxAcceleration = acceleration
        self.mass = 0.1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func checkDestination() {
        guard let destination = destination else { return }
        let currentPosition = self.position.pointValue
        if destination <=> currentPosition <= CGFloat(self.radius * 3) {
            // destination reached
            self.stopMovement()
        }
    }

    func stopMovement() {
        self.destination = nil
    }

    override func update(deltaTime seconds: TimeInterval) {
        self.updateObstacles()
        super.update(deltaTime: seconds)
    }
}
