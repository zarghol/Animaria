//
//  NamingComponent.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit

class NamingComponent: GKComponent {
    let name: String
    let descriptionText: String
    
    init(name: String, description: String) {
        self.name = name
        self.descriptionText = description
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
