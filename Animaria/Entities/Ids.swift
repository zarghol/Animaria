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
    /// Panda Home
    case panda_1

    // MARK: -
    var race: Race? {
        switch self {
        case .base_0, .base_1, .base_2:
            return nil
        case .panda_0, .panda_1:
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
