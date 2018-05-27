//
//  TextureComponent.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import GameplayKit
import SpriteKit

class TextureComponent: GKComponent {

    let sprite: SKSpriteNode
    
    init(texture: SKTexture, size: CGSize) {
        self.sprite = SKSpriteNode(texture: texture, size: size)
        super.init()
        
    }
    
    override func didAddToEntity() {
        super.didAddToEntity()
        self.sprite.entity = self.entity
    }
    
    override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        self.sprite.entity = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
