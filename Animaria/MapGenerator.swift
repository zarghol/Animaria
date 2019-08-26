//
//  MapGenerator.swift
//  Animaria
//
//  Created by Clément NONN on 25/08/2019.
//  Copyright © 2019 Clément NONN. All rights reserved.
//

import SpriteKit
import GameplayKit

class MapGenerator {
    enum Error: Swift.Error {
        case resourcesNotLoaded
    }
    
    func preview() -> SKScene {
        let seed = Int32.random(in: 0...Int32.max)
        print("seed for terrain : \(seed)")
        let noiseSource = GKPerlinNoiseSource()

        let noise = GKNoise(noiseSource)

        let map = GKNoiseMap(
            noise,
            size: vector_double2(1, 1),
            origin: vector_double2(0, 0),
            sampleCount: vector_int2(100, 100),
            seamless: true
        )

        let texture = SKTexture(noiseMap: map)
        let node = SKSpriteNode(texture: texture)
        let testScene = SKScene(size: texture.size())

        testScene.addChild(node)
        return testScene
    }

    func load(tileCount: Int, tileSize: Int = 125) throws -> GameScene {
        let seed = Int32.random(in: 0...Int32.max)
        print("seed for terrain : \(seed)")
        let noiseSource = GKPerlinNoiseSource(frequency: 1, octaveCount: 10, persistence: 0.7, lacunarity: 1.5, seed: seed)

        let noise = GKNoise(noiseSource)

        let map = GKNoiseMap(
            noise,
            size: vector_double2(1, 1),
            origin: vector_double2(0, 0),
            sampleCount: vector_int2(Int32(tileCount), Int32(tileCount)),
            seamless: true
        )

        guard let set = SKTileSet(named: "Sample Grid Tile Set") else { throw Error.resourcesNotLoaded }

        let tileSize = CGSize(width: 125, height: 125)
        let sceneSize = tileSize * CGFloat(tileCount)

        let nodes = SKTileMapNode.tileMapNodes(
            tileSet: set,
            columns: tileCount,
            rows: tileCount,
            tileSize: tileSize,
            from: map,
            tileTypeNoiseMapThresholds: [-0.8, -0.5, 0.5]
        )
        
        let scene = GameScene(size: sceneSize)
        for node in nodes {
            node.anchorPoint = .zero
            scene.addChild(node)
        }

        let cameraNode = SKCameraNode()
        cameraNode.xScale = 0.2
        cameraNode.yScale = 0.2

        scene.addChild(cameraNode)
        scene.camera = cameraNode

        // now determine the starting position with the rules :
        //   - should be in grass
        //   - near wood source (todo : not in the noise map for now)

//        scene.startPositions = []
        return scene
    }
}
