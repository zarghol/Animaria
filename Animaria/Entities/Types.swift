//
//  Types.swift
//  Animaria
//
//  Created by Clément NONN on 03/06/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

enum UnitType: String, Codable {
    case building, character, object
}

enum SkillType: Decodable {
    enum CodingKeys: String, CodingKey {
        case type, characteristics, unitType, id
    }

    case direct([Characteristic: Double])
    case duration([Characteristic: Double])
    case building(type: UnitType, id: Int) // ??
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
                let unitType = try innerContainer.decode(UnitType.self, forKey: .unitType)
                let id = try innerContainer.decode(Int.self, forKey: .id)

                self = .building(type: unitType, id: id)
                return
            default:
                throw DecodingError.valueNotFound(SkillType.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value for this key : \(typeString)"))
            }
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
