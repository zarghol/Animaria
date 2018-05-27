//
//  TempletableEntity.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit


class TempletableEntity<T: Template>: GKEntity {
    let template: T
    
    init(template: T) {
        self.template = template
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
