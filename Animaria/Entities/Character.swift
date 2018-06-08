//
//  Character.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

struct CharacterTemplate: Encodable /* Not used, just to synthesize the CodingKeys */ {
    let id: Int
    let maxLife: Double
    let maxEnergy: Double
    let characteristics: [Characteristic: Double]
    let name: String
    let description: String
    let race: Race
    let requiredToBuild: [Resource: Int]
    let skillsIds: [SkillId]
}

extension CharacterTemplate: BuildableTemplate { }

extension CharacterTemplate: UnitTemplate {
    var unitType: UnitType {
        return .character
    }

    init(from decoder: Decoder) throws {
        guard let race = decoder.userInfo[Race.key] as? Race else {
            throw DecodingError.valueNotFound(Race.self, DecodingError.Context(codingPath: [], debugDescription: "race not found in the decoder's userInfo"))
        }
        
        let container = try decoder.container(keyedBy: CharacterTemplate.CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
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
    init(template: CharacterTemplate, camp: Camp, entityManager: EntityManager) {
        super.init(template: template)
        self.addComponent(NamingComponent(name: template.name, description: template.description))
        let texture = SKTexture(imageNamed: "\(template.race)/\(template.name)")
        let textureComponent = TextureComponent(texture: texture, size: texture.size())
        self.addComponent(textureComponent)
        self.addComponent(LifeComponent(maxLife: template.maxLife))
        self.addComponent(CampComponent(camp: camp))
        self.addComponent(MoveableComponent(positionComponent: textureComponent, speed: 300.0, acceleration: 100.0))
        let skills = RaceRepository.all.skills(for: template.race)

        self.addComponent(SkillBookComponent(templates: skills.subset(filterPath: \SkillTemplate.id, values: template.skillsIds), entityManager: entityManager))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
