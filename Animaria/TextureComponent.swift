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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
