//
//  Building.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit

struct BuildingTemplate: Encodable {
    let name: String
    let description: String
    
    let maxLife: Double
    let characteristics: [Characteristic: Double]
    let requiredToBuild: [Resource: Int]
    
    let skillsIds: [SkillId]
}

extension BuildingTemplate: Template {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BuildingTemplate.CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
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
        let texture = SKTexture(imageNamed: "\(template.name)")
        self.addComponent(TextureComponent(texture: texture, size: texture.size()))
        self.addComponent(LifeComponent(maxLife: template.maxLife))
        self.addComponent(CampComponent(camp: camp))
        if isMain {
            self.addComponent(MainEntityComponent())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Dictionary {
    func map<T: Hashable, U>(_ transform: ((key: Key, value: Value)) throws -> (T, U)) rethrows -> [T: U] {
        var result = [T: U]()
        for (key, value) in self {
            let (newKey, newValue) = try transform((key, value))
            result[newKey] = newValue
        }
        return result
    }
}
