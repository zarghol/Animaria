//
//  Ids.swift
//  Animaria
//
//  Created by Clément NONN on 03/06/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

enum SkillId: String, Codable {
    case base_0, base_1, base_2
    case panda_0, panda_1

    var race: Race? {
        switch self {
        case .base_0, .base_1, .base_2:
            return nil
        case .panda_0, .panda_1:
            return .panda

        }
    }
}
