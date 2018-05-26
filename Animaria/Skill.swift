//
//  Skill.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

enum SkillType {
    case direct([Characteristic: Double])
    case duration([Characteristic: Double])
    case building([Resource: Int]) // ??
}

struct SkillTemplate {
    let name: String
    let description: String
    
    let type: SkillType
    let requiredTitle: String
    let energyQuantity: Double
    let range: Double
    let size: Double
    let cooldown: Double
}

import GameplayKit

class Skill: GKComponent { // Entity ???
    let template: SkillTemplate
    var level: Int
    var experience: Int
    var currentTime: Double // other type ?
    
    init(template: SkillTemplate, level: Int = 0, experience: Int = 0, currentTime: Double = 0.0) {
        self.level = level
        self.template = template
        self.experience = experience
        self.currentTime = currentTime
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func earnExperience() { // Experience component ???
        let x = Int.random(in: 1..<10)
        let randomXP = x * level
        let cap = 100 * level
        if experience + randomXP < cap {
            experience += randomXP
        } else {
            experience = (experience + randomXP) % cap
            level += 1
        }
    }
}

extension SkillTemplate: FileLoadable {
    func load(fileName: String) throws {
        throw FileError.unknownError
    }
}
