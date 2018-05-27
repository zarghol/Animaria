//
//  SkillBookComponent.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import GameplayKit

class SkillBookComponent: GKComponent {
    let skills: [Skill]
    
    init(templates: [SkillTemplate]) {
        self.skills = templates.map { Skill(template: $0) }
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
