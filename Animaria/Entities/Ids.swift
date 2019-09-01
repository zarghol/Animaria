//
//  Ids.swift
//  Animaria
//
//  Created by Clément NONN on 03/06/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

enum SkillId: String, Codable {
    // MARK: Basic Skills

    /// Stop
    case base_0
    /// Attack
    case base_1
    /// Harvest
    case base_2

    // MARK: Panda Skills

    /// Basic Panda
    case panda_0
    /// Home
    case panda_1
    /// Laboratory
    case panda_2
    /// Windmill
    case panda_3
    /// Barracks
    case panda_4
    /// Energistic (Defensive Tower)
    case panda_5
    /// Pouf
    case panda_6
    /// Research
    case panda_7
    /// Clone
    case panda_8
    /// Dynamite
    case panda_9

    // MARK: -
    var race: Race? {
        switch self {
        case .base_0, .base_1, .base_2:
            return nil
        case .panda_0, .panda_1, .panda_2, .panda_3, .panda_4, .panda_5, .panda_6, .panda_7, .panda_8, .panda_9:
            return .panda
        }
    }
}

//extension SkillId {
//    func execute() {
//        switch self {
//        case .base_2:
//
//        default:
//            break
//        }
//    }
//}
