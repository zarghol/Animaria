//
//  Character.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

struct CharacterTemplate: Encodable {
    let maxLife: Double
    let maxEnergy: Double
    let characteristics: [Characteristic: Double]
    let name: String
    let race: Race
    let requiredToBuild: [Resource: Int]
    let skillsIds: [SkillId]
}

extension CharacterTemplate: Template {
    init(from decoder: Decoder) throws {
        guard let race = decoder.userInfo[Race.key] as? Race else {
            throw DecodingError.valueNotFound(Race.self, DecodingError.Context(codingPath: [], debugDescription: "race not found in the decoder's userInfo"))
        }
        
        let container = try decoder.container(keyedBy: CharacterTemplate.CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        
//        self.description = try container.decode(String.self, forKey: .description)
        self.maxLife = try container.decode(Double.self, forKey: .maxLife)
        self.maxEnergy = try container.decode(Double.self, forKey: .maxEnergy)
        let characteristicsDictionary = try container.decode([String: Double].self, forKey: .characteristics)
        self.characteristics = try characteristicsDictionary.map { tuple in
            guard let key = Characteristic(rawValue: tuple.key) else {
                throw DecodingError.valueNotFound(
                    Resource.self,
                    DecodingError.Context(codingPath: [CharacterTemplate.CodingKeys.characteristics], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                )
            }
            return (key, tuple.value)
        }
        self.race = race
        let requiredToBuildDictionary = try container.decode([String: Int].self, forKey: .requiredToBuild)
        self.requiredToBuild = try requiredToBuildDictionary.map { tuple in
            guard let key = Resource(rawValue: tuple.key) else {
                throw DecodingError.valueNotFound(
                    Resource.self,
                    DecodingError.Context(codingPath: [CharacterTemplate.CodingKeys.requiredToBuild], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                )
            }
            return (key, tuple.value)
        }
        self.skillsIds = try container.decode([SkillId].self, forKey: .skillsIds)
    }
}



import GameplayKit

class Character: TempletableEntity<CharacterTemplate> {
    
}
