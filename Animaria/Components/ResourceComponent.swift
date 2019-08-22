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
    var amount: Int
    let resourceType: Resource

    weak var entityManager: EntityManager?

    init(amount: Int, resource: Resource, entityManager: EntityManager) {
        self.amount = amount
        self.resourceType = resource
        self.entityManager = entityManager

        super.init()
    }

    func collect(quantity: Int) -> Int {
        if quantity >= amount {
            amount = 0
            return amount
        } else {
            amount -= quantity
            return quantity
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        if amount <= 0, let entity = self.entity {
            self.entityManager?.remove(entity)
        }
    }
}
