//
//  Skill.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

struct SkillTemplate: Decodable {
    let id: SkillId
    let name: String
    let description: String
    
    let type: SkillType
    let requiredTitle: TitleId?
    let energyQuantity: Double
    let cooldown: Double
}

class Skill: NSObject {
    let template: SkillTemplate
    var level: Int
    var experience: Int
    var currentTime: Double {
        didSet {
            if let race = self.template.id.race,
               let resources = RaceRepository.all[race]?.getBuildableUnitTemplate(for: self)?.requiredToBuild,
               let neededTime = resources[.time] {
                self.progress = min(self.currentTime / Double(neededTime), 1.0)
            }
        }
    }

    @objc private(set) var progress: Double {
        willSet {
            willChangeValue(forKey: "progress")
        }

        didSet {
            didChangeValue(forKey: "progress")
        }
    }
    
    init(template: SkillTemplate, level: Int = 0, experience: Int = 0, currentTime: Double = 0.0) {
        self.progress = 1.0
        self.level = level
        self.template = template
        self.experience = experience
        self.currentTime = currentTime

        super.init()
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
