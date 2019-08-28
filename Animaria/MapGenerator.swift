//
//  MapGenerator.swift
//  Animaria
//
//  Created by Clément NONN on 25/08/2019.
//  Copyright © 2019 Clément NONN. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Map {
    case centeredLake
    case sea
    case twoLakes

    private var fieldSeed: Int32 {
        switch self {
        case .centeredLake:
            return 591575775
        case .sea:
            return 702990554
        case .twoLakes:
            return 967411119
        }
    }

    private func resourceSeed(for resource: Resource) -> Int32 {
        switch (self, resource) {
        case (.centeredLake, .wood):
            let randomedSeed = Int32.random(in: 0...Int32.max)
            print("randomSeed for \(resource) : \(randomedSeed)")
            return randomedSeed
        case (.centeredLake, .crystal):
            let randomedSeed = Int32.random(in: 0...Int32.max)
            print("randomSeed for \(resource) : \(randomedSeed)")
            return randomedSeed
        case (.centeredLake, .metal):
            let randomedSeed = Int32.random(in: 0...Int32.max)
            print("randomSeed for \(resource) : \(randomedSeed)")
            return randomedSeed

        case (.sea, .wood):
            return 1401611900
        case (.sea, .crystal):
            return 949678528
        case (.sea, .metal):
            let randomedSeed = Int32.random(in: 0...Int32.max)
            print("randomSeed for \(resource) : \(randomedSeed)")
            return randomedSeed

        case (.twoLakes, .wood):
            let randomedSeed = Int32.random(in: 0...Int32.max)
            print("randomSeed for \(resource) : \(randomedSeed)")
            return randomedSeed
        case (.twoLakes, .crystal):
            let randomedSeed = Int32.random(in: 0...Int32.max)
            print("randomSeed for \(resource) : \(randomedSeed)")
            return randomedSeed
        case (.twoLakes, .metal):
            let randomedSeed = Int32.random(in: 0...Int32.max)
            print("randomSeed for \(resource) : \(randomedSeed)")
            return randomedSeed

        case (_, .time):
            return 0
        }
    }

    var startingPosition: [CGPoint] {
        switch self {
        case .centeredLake:
            return []
        case .sea:
            return []
        case .twoLakes:
            return []
        }
    }

    var fieldNoiseSource: GKNoiseSource {
        // These parameters are common to all maps for now but surely not in the future
        return GKPerlinNoiseSource(
            frequency: 1,
            octaveCount: 10,
            persistence: 0.7,
            lacunarity: 1.5,
            seed: fieldSeed
        )
    }

    func resourcesMap(for resource: Resource) -> GKNoiseSource {
//        switch resource {
//        case .wood:
            return GKPerlinNoiseSource(
                frequency: 2,
                octaveCount: 20,
                persistence: 0.7,
                lacunarity: 2.5,
                seed: resourceSeed(for: resource)
            )

//        case .crystal:
//            return GKPerlinNoiseSource(
//                frequency: 1.5,
//                octaveCount: 14,
//                persistence: 0.7,
//                lacunarity: 2.5,
//                seed: resourceSeed(for: resource)
//            )
//        default:
//            return GKPerlinNoiseSource(
//                frequency: 2,
//                octaveCount: 20,
//                persistence: 0.7,
//                lacunarity: 2.5,
//                seed: resourceSeed(for: resource)
//            )
//        }
    }

    func resourceThreshold(for resource: Resource) -> Float {
        switch resource {
        case .wood:
            return 0.5
        case .crystal:
            return 0.8
        case .metal:
            return 0.9
        case .time:
            return 1.0
        }
    }

    /// Use this for generating new map
    static func randomMap() -> GKNoiseSource {
        let seed = Int32.random(in: 0...Int32.max)
        print("seed for terrain : \(seed)")
        return GKPerlinNoiseSource(
            frequency: 1,
            octaveCount: 10,
            persistence: 0.7,
            lacunarity: 1.5,
            seed: seed
        )
    }
}

class MapGenerator {
    struct Configuration {
        let tileCount: Int
        let tileEdgeSize: Int
        let minimapHeight: CGFloat
        let originalMapSize: CGSize
    }

    enum Error: Swift.Error {
        case resourcesNotLoaded
    }

    let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
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

    private func generateField(map: Map) throws -> [SKTileMapNode] {
        guard let set = SKTileSet(named: "Sample Grid Tile Set") else { throw Error.resourcesNotLoaded }

        let noiseSource = map.fieldNoiseSource
        let noise = GKNoise(noiseSource)

        let map = GKNoiseMap(
            noise,
            size: vector_double2(1, 1),
            origin: vector_double2(0, 0),
            sampleCount: vector_int2(Int32(configuration.tileCount), Int32(configuration.tileCount)),
            seamless: true
        )

        let tileSize = CGSize(width: configuration.tileEdgeSize, height: configuration.tileEdgeSize)

        return SKTileMapNode.tileMapNodes(
            tileSet: set,
            columns: configuration.tileCount,
            rows: configuration.tileCount,
            tileSize: tileSize,
            from: map,
            tileTypeNoiseMapThresholds: [-0.8, -0.5, 0.2]
        )
    }

    private func generateResources(map: Map, threshold: Float, entityManager: EntityManager) -> [ResourceEntity] {
        let noiseMaps: [(Resource, GKNoiseMap)] = [Resource.crystal, Resource.wood]// Resource.allCases
            .map {
                let noise = GKNoise(map.resourcesMap(for: $0))
                let noiseMap = GKNoiseMap(
                    noise,
                    size: vector_double2(1, 1),
                    origin: vector_double2(0, 0),
                    sampleCount: vector_int2(Int32(configuration.tileCount), Int32(configuration.tileCount)),
                    seamless: true
                )

                let texture = SKTexture(noiseMap: noiseMap)
                let node = SKSpriteNode(texture: texture)
                return ($0, noiseMap)
        }

        var resourceEntities = [ResourceEntity]()

        for y in 0..<configuration.tileCount {
            for x in 0..<configuration.tileCount {
                let vector = vector_int2(Int32(x), Int32(y))
                let resourcesHere = noiseMaps.filter { $0.1.value(at: vector) > map.resourceThreshold(for: $0.0) }

                if resourcesHere.isEmpty { continue } // no resources here so keep going on the next tile
                let selectedResource: (Resource, GKNoiseMap)
                if noiseMaps.count == 1 {
                    selectedResource = noiseMaps[0]
                } else {
                    selectedResource = noiseMaps.reduce(noiseMaps.first!) { previousResult, newResult in
                        return previousResult.1.value(at: vector) > newResult.1.value(at: vector) ? previousResult : newResult
                    }
                }
                let value = selectedResource.1.value(at: vector)
                let amount = Int((1 + value) * 75)
                let entity = ResourceEntity(
                    resource: selectedResource.0,
                    amount: amount,
                    entityManager: entityManager
                )

                if let component = entity.component(ofType: TextureComponent.self) {
                    component.position = CGPoint(
                        x: (CGFloat(x) + 0.5) * CGFloat(configuration.tileEdgeSize),
                        y: (CGFloat(y) + 0.5) * CGFloat(configuration.tileEdgeSize)
                    )
                }
                resourceEntities.append(entity)
            }
        }

        return resourceEntities
    }

    private func initializeScene(sceneSize: CGSize) -> GameScene {
        let scene = GameScene(size: sceneSize)

        let cameraNode = SKCameraNode()
        cameraNode.xScale = 0.2
        cameraNode.yScale = 0.2

        scene.addChild(cameraNode)
        scene.camera = cameraNode

        return scene
    }

    func load(map: Map) throws -> GameScene {
        let fieldNodes = try generateField(map: map)

        let sceneSize = CGSize(
            width: configuration.tileEdgeSize * configuration.tileCount,
            height: configuration.tileEdgeSize * configuration.tileCount
        )

        let scene = self.initializeScene(sceneSize: sceneSize)

        for node in fieldNodes {
            node.anchorPoint = .zero
            scene.addChild(node)
        }

        scene.startPositions = map.startingPosition

        TextureComponent.minimapRatio = configuration.minimapHeight / scene.size.height

        scene.createMinimap(
            with: Int(configuration.minimapHeight),
            originalMapSize: configuration.originalMapSize
        )

        scene.entityManager = EntityManager(scene: scene, minimapScene: scene.minimapScene)

        let resources = self.generateResources(map: map, threshold: 0.5, entityManager: scene.entityManager).filter {
            let textureComponent = $0.component(ofType: TextureComponent.self)!
            let resourceComponent = $0.component(ofType: ResourceComponent.self)!
            let background = scene.determineBackground(for: textureComponent.position) ?? .grass
            return resourceComponent.resourceType.canBePlaced(on: background)
        }

        scene.entityManager.insert(contentsOf: resources)

        return scene
    }
}
