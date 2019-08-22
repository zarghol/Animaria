//
//  Skill.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation
import GameplayKit

enum SkillTarget {
    case none
    case position(CGPoint)
    case entity(GKEntity)
}

enum SkillTemplateTarget {
    case none
    case position(distance: CGFloat)
    case entity(distance: CGFloat)

    var distance: CGFloat {
        switch self {
        case .none:
            return 0.0
        case .position(let distance):
            return distance
        case .entity(let distance):
            return distance
        }
    }
}

extension SkillTemplateTarget: Decodable {
    var stringValue: String {
        switch self {
            case .none:
                return "none"
            case .position(_):
                return "position"
            case .entity(_):
                return "entity"
        }
    }

    enum CodingKeys: String, CodingKey {
        case type, distance
    }

    init(from decoder: Decoder) throws {
        if let singleContainer = try? decoder.singleValueContainer(),
            let targetString = try? singleContainer.decode(String.self) {
            switch targetString {
            case SkillTemplateTarget.none.stringValue:
                self = .none
                return
            default:
                throw DecodingError.valueNotFound(SkillType.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value for this key : \(targetString)"))
            }
        } else {
            let innerContainer = try decoder.container(keyedBy: CodingKeys.self)
            let targetString = try innerContainer.decode(String.self, forKey: .type)

            let distance = try innerContainer.decode(CGFloat.self, forKey: .distance)
            switch targetString {
            case SkillTemplateTarget.position(distance: 0).stringValue:
                self = .position(distance: distance)
                return
            case SkillTemplateTarget.entity(distance: 0).stringValue:
                self = .entity(distance: distance)
                return
            default:
                throw DecodingError.valueNotFound(SkillTemplateTarget.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value for this key : \(targetString)"))
            }
        }
    }
}

struct SkillTemplate: Decodable {
    let id: SkillId
    let name: String
    let description: String

    let target: SkillTemplateTarget
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

    var target: SkillTarget

    var isTargetReady: Bool {
        switch (self.target, self.template.target) {
        case (.none, .none), (.entity(_), .entity(_)), (.position(_), .position(_)):
            return true
        default:
            return false
        }
    }
    
    init(template: SkillTemplate, level: Int = 1, experience: Int = 0, currentTime: Double = 0.0) {
        self.progress = 1.0
        self.level = level
        self.template = template
        self.experience = experience
        self.currentTime = currentTime
        self.target = .none

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
