//
//  Character.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

enum Race {
    case panda, teddyBear, tiger, koala, sheep
}

struct CharacterTemplate {
    let maxLife: Double
    let maxEnergy: Double
    let characteristics: [Characteristic: Double]
    let name: String
    let race: Race
    let moveSpeed: Double
    let buildingSpeed: Double
    let attackSpeed: Double
    let harvestSpeed: Double
    let requiredToBuild: [Resource: Int]
}



import GameplayKit

class Character: GKEntity {
    
}
