//
//  Object.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

struct ObjectTemplate {
    let name: String
    let characteristics: [Characteristic: Double]
    let type: ObjectType
    let location: ObjectLocation
    let requiredToBuild: [Resource: Int]
}

enum ObjectType {
    case weapon, armor
}

enum ObjectLocation {
    case hand, leftHand, rightHand, head, shoulder, body, legs, feet, none
}

enum Characteristic {
    case damages, armor, strength, intellect, wisdom, constitution
}

import GameplayKit

class Object: GKEntity {
    let template: ObjectTemplate
    
    init(template: ObjectTemplate) {
        self.template = template
        // add NamingComponent (name + description)
        // add buildableComponent (resources)
        // add characteristicsComponent (damages, armor, etc...)
        // add positionableComponent (location on space)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
