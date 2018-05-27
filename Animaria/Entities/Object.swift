//
//  Object.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

struct ObjectTemplate: Encodable {
    let name: String
    let characteristics: [Characteristic: Double]
    let type: ObjectType
    let location: ObjectLocation
    let requiredToBuild: [Resource: Int]
}

extension ObjectTemplate: Template {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ObjectTemplate.CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        let characteristicsDictionary = try container.decode([String: Double].self, forKey: .characteristics)
        self.characteristics = try characteristicsDictionary.map { tuple in
            guard let key = Characteristic(rawValue: tuple.key) else {
                throw DecodingError.valueNotFound(
                    Characteristic.self,
                    DecodingError.Context(codingPath: [ObjectTemplate.CodingKeys.characteristics], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                )
            }
            return (key, tuple.value)
        }
        self.type = try container.decode(ObjectType.self, forKey: .type)
        self.location = try container.decode(ObjectLocation.self, forKey: .location)
        let requiredToBuildDictionary = try container.decode([String: Int].self, forKey: .requiredToBuild)
        self.requiredToBuild = try requiredToBuildDictionary.map { tuple in
            guard let key = Resource(rawValue: tuple.key) else {
                throw DecodingError.valueNotFound(
                    Resource.self,
                    DecodingError.Context(codingPath: [ObjectTemplate.CodingKeys.requiredToBuild], debugDescription: "unable to build an enum value with value provided : \(tuple.key)")
                )
            }
            return (key, tuple.value)
        }
    }
}

enum ObjectType: String {
    case weapon, armor
}
extension ObjectType: Decodable, Encodable { }

enum ObjectLocation: String {
    case hand, leftHand, rightHand, twoHand, head, shoulder, body, legs, feet, none
}
extension ObjectLocation: Decodable, Encodable { }

enum Characteristic: String {
    case damages, armor, strength, intellect, endurance, wisdom, constitution, range, attackSpeed
}
extension Characteristic: Decodable, Encodable { }

import GameplayKit

class Object: TempletableEntity<ObjectTemplate> {
    
    override init(template: ObjectTemplate) {
        super.init(template: template)
        
        self.addComponent(NamingComponent(name: template.name, description: ""))
        let texture = SKTexture(imageNamed: "\(template.name)")
        self.addComponent(TextureComponent(texture: texture, size: texture.size()))
        // add buildableComponent (resources)
        // add characteristicsComponent (damages, armor, etc...)
        // add positionableComponent (location on space)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
