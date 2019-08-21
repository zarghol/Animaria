//
//  ResourceComponent.swift
//  Animaria
//
//  Created by Clément NONN on 20/06/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit

class ResourceComponent: GKComponent {
    let amount: Int
    let resourceType: Resource

    init(amount: Int, resource: Resource) {
        self.amount = amount
        self.resourceType = resource

        super.init()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
