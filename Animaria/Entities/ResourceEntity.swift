//
//  ResourceEntity.swift
//  Animaria
//
//  Created by Clément NONN on 21/08/2019.
//  Copyright © 2019 Clément NONN. All rights reserved.
//

import Foundation
import GameplayKit

class ResourceEntity: GKEntity {
    init(resource: Resource, amount: Int, entityManager: EntityManager) {
        super.init()

        self.addComponent(NamingComponent(name: "\(resource)", description: resource.description))
        let texture = SKTexture(imageNamed: "holder/\(resource)")
        let textureComponent = TextureComponent(texture: texture, size: texture.size())
        self.addComponent(textureComponent)
        self.addComponent(ResourceComponent(amount: amount, resource: resource, entityManager: entityManager))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
