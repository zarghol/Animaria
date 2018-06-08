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
                let goal = GKGoal(toSeekAgent: TargetAgent(position: destination))
                self.behavior = GKBehavior(weightedGoals: [goal: 1.0])
                self.maxAcceleration = possibleAcceleration
            } else {
                self.behavior?.removeAllGoals()
                self.speed = 0.0
                self.maxAcceleration = 0.0
            }
        }
    }

    private var possibleAcceleration: Float

    init(positionComponent: TextureComponent, speed: Float, acceleration: Float) {
        self.possibleAcceleration = acceleration
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
