//
//  Title.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

typealias TitleId = String

struct TitleTemplate: Template {
    let id: TitleId
    let name: String
    let description: String
    let requirement: TitleRequirement
}

enum TitleRequirement: Decodable {
    case skillLevel(SkillId, Int)

    enum CodingKeys: String, CodingKey {
        case skillId, level
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(SkillId.self, forKey: .skillId)
        let level = try container.decode(Int.self, forKey: .level)

        self = .skillLevel(id, level)
    }
}

class Title: NSObject {
    let template: TitleTemplate
    var isAcquired: Bool

    init(template: TitleTemplate) {
        self.template = template
        self.isAcquired = false
    }
}
