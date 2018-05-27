//
//  Skill.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

enum SkillType: Decodable {
    enum CodingKeys: String, CodingKey {
        case type, characteristics, requiredToBuild
    }
    
    case direct([Characteristic: Double])
    case duration([Characteristic: Double])
    case building([Resource: Int]) // ??
    case basic
    
    init(from decoder: Decoder) throws {
        if let singleContainer = try? decoder.singleValueContainer(),
           let typeString = try? singleContainer.decode(String.self) {
            switch typeString {
            case "basic":
                self = .basic
                return
            default:
                throw DecodingError.valueNotFound(SkillType.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value for this key : \(typeString)"))
            }
        } else {
            let innerContainer = try decoder.container(keyedBy: CodingKeys.self)
            let typeString = try innerContainer.decode(String.self, forKey: .type)
            switch typeString {
            case "direct":
                let characteristics: [Characteristic: Double] = try innerContainer.decode([String: Double].self, forKey: .characteristics).map { tuple in
                    if let charac = Characteristic(rawValue: tuple.key) {
                        return (charac, tuple.value)
                    } else {
                        throw DecodingError.valueNotFound(
                            Characteristic.self,
                            DecodingError.Context(codingPath: [SkillType.CodingKeys.characteristics], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                        )
                    }
                }
                self = .direct(characteristics)
                return
            case "duration":
                let characteristics: [Characteristic: Double] = try innerContainer.decode([String: Double].self, forKey: .characteristics).map { tuple in
                    if let charac = Characteristic(rawValue: tuple.key) {
                        return (charac, tuple.value)
                    } else {
                        throw DecodingError.valueNotFound(
                            Characteristic.self,
                            DecodingError.Context(codingPath: [SkillType.CodingKeys.characteristics], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                        )
                    }
                }
                self = .duration(characteristics)
                return
            case "building":
                let resources: [Resource: Int] = try innerContainer.decode([String: Int].self, forKey: .requiredToBuild).map { tuple in
                    if let charac = Resource(rawValue: tuple.key) {
                        return (charac, tuple.value)
                    } else {
                        throw DecodingError.valueNotFound(
                            Resource.self,
                            DecodingError.Context(codingPath: [SkillType.CodingKeys.requiredToBuild], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                        )
                    }
                }
                self = .building(resources)
                return
            default:
                throw DecodingError.valueNotFound(SkillType.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value for this key : \(typeString)"))
            }
        }
    }
}

typealias SkillId = String

struct SkillTemplate: Decodable {
    let id: SkillId
    let name: String
    let description: String
    
    let type: SkillType
    let requiredTitle: TitleId?
    let energyQuantity: Double
    let cooldown: Double
}

import GameplayKit

class Skill { 
    let template: SkillTemplate
    var level: Int
    var experience: Int
    var currentTime: Double // other type ?
    
    init(template: SkillTemplate, level: Int = 0, experience: Int = 0, currentTime: Double = 0.0) {
        self.level = level
        self.template = template
        self.experience = experience
        self.currentTime = currentTime
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
