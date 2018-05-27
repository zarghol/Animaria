//
//  CampComponent.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit

class CampComponent: GKComponent {
    let camp: Int
    
    init(camp: Int) {
        self.camp = camp
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
