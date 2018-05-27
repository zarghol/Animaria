//
//  LifeComponent.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit

class LifeComponent: GKComponent {
    var maxLife: Double
    var currentLife: Double
    
    init(maxLife: Double) {
        self.maxLife = maxLife
        self.currentLife = maxLife
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
