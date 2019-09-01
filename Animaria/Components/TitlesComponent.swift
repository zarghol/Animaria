//
//  TitlesComponent.swift
//  Animaria
//
//  Created by Clément NONN on 30/08/2019.
//  Copyright © 2019 Clément NONN. All rights reserved.
//

import GameplayKit

class TitlesComponent: GKComponent {
    var titles: [Title]

    var ownedTitles: [Title] {
        return titles.filter { $0.isAcquired }
    }

    init(availableTitles: [TitleTemplate]) {
        self.titles = availableTitles.map { Title(template: $0) }
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let skillbookComponent = self.entity?.component(ofType: SkillBookComponent.self) else {
            return
        }

        for title in titles where !title.isAcquired {
            switch title.template.requirement {
            case .skillLevel(let skillId, let level) where skillbookComponent.skills.contains(where: { $0.template.id == skillId && $0.level >= level }):
                title.isAcquired = true
            default:
                break
            }
        }
    }
}
