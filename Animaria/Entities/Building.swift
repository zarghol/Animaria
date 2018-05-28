//
//  Building.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit

struct BuildingTemplate: Encodable /* Not used, just to synthesize the CodingKeys */ {
    let name: String
    let description: String
    
    let race: Race
    let maxLife: Double
    let characteristics: [Characteristic: Double]
    let requiredToBuild: [Resource: Int]
    
    let skillsIds: [SkillId]
}

extension BuildingTemplate: Template {
    init(from decoder: Decoder) throws {
        guard let race = decoder.userInfo[Race.key] as? Race else {
            throw DecodingError.valueNotFound(Race.self, DecodingError.Context(codingPath: [], debugDescription: "race not found in the decoder's userInfo"))
        }

        let container = try decoder.container(keyedBy: BuildingTemplate.CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)

        self.race = race
        self.maxLife = try container.decode(Double.self, forKey: .maxLife)
        let characteristicsDictionary = try container.decode([String: Double].self, forKey: .characteristics)
        self.characteristics = try characteristicsDictionary.map { tuple in
            guard let key = Characteristic(rawValue: tuple.key) else {
                throw DecodingError.valueNotFound(
                    Characteristic.self,
                    DecodingError.Context(codingPath: [BuildingTemplate.CodingKeys.characteristics], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                )
            }
            return (key, tuple.value)
        }
        let requiredToBuildDictionary = try container.decode([String: Int].self, forKey: .requiredToBuild)
        self.requiredToBuild = try requiredToBuildDictionary.map { tuple in
            guard let key = Resource(rawValue: tuple.key) else {
                throw DecodingError.valueNotFound(
                    Resource.self,
                    DecodingError.Context(codingPath: [BuildingTemplate.CodingKeys.requiredToBuild], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                )
            }
            return (key, tuple.value)
        }
        self.skillsIds = try container.decode([SkillId].self, forKey: .skillsIds)
    }
}

class Building: TempletableEntity<BuildingTemplate> {
    init(template: BuildingTemplate, camp: Int, isMain: Bool) {
        super.init(template: template)
        
        self.addComponent(NamingComponent(name: template.name, description: template.description))
        let texture = SKTexture(imageNamed: "\(template.race)/\(template.name)")
        self.addComponent(TextureComponent(texture: texture, size: texture.size()))
        self.addComponent(LifeComponent(maxLife: template.maxLife))
        self.addComponent(CampComponent(camp: camp))
        
        let buildingsSkills = RaceRepository.all.skills(for: template.race)
        
        self.addComponent(SkillBookComponent(templates: buildingsSkills.subset(filterPath: \SkillTemplate.id, values: template.skillsIds)))
        if isMain {
            self.addComponent(MainEntityComponent())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
