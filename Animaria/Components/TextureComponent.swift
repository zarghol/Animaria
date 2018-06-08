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

    static var minimapRatio: CGFloat = 0.01456 // RealSize / MinimapSize

    var position: CGPoint {
        get {
            return self.sprite.position
        }

        set {
            self.sprite.position = newValue

            self.minMapNode.position = position * TextureComponent.minimapRatio
        }
    }

    let sprite: SKSpriteNode

    let minMapNode: SKSpriteNode
    
    init(texture: SKTexture, size: CGSize) {
        self.sprite = SKSpriteNode(texture: texture, size: size)
        let width = max(size.width * TextureComponent.minimapRatio, 1.5)
        let heigth = max(size.height * TextureComponent.minimapRatio, 1.5)
        self.minMapNode = SKSpriteNode(color: .red, size: CGSize(width: width, height: heigth))
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

extension TextureComponent: GKAgentDelegate {

    func agentWillUpdate(_ agent: GKAgent) {
        if let agent = agent as? GKAgent2D {
            agent.position = self.position.vector2_floatValue
            agent.rotation = Float(self.sprite.zRotation)
        }
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        if let agent = agent as? GKAgent2D {
            self.position = agent.position.pointValue
            self.sprite.zRotation = CGFloat(agent.rotation)
        }
    }
}
