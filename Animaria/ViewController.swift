//
//  ViewController.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
//                sceneNode.entities = scene.entities
//                sceneNode.graphs = scene.graphs
//                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.skView {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        guard let scene = self.skView.scene as? GameScene else {
            return
        }
        self.view.window?.delegate = scene
    }
}

extension NSTouchBarItem.Identifier {
    static let positionLabel = NSTouchBarItem.Identifier(rawValue: "positionLabel")
}

extension NSTouchBar.CustomizationIdentifier {
    static let debugBar = NSTouchBar.CustomizationIdentifier(rawValue: "debugBar")
}

@available(OSX 10.12.1, *)
extension ViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        // 1
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        // 2
        touchBar.customizationIdentifier = .debugBar
        // 3
        touchBar.defaultItemIdentifiers = [.positionLabel]
        
        touchBar.principalItemIdentifier = .positionLabel
        // 4
        touchBar.customizationAllowedItemIdentifiers = [.positionLabel]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .positionLabel:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            customViewItem.view = NSTextField(labelWithString: "Debug Label")
            customViewItem.view.bind(NSBindingName(rawValue: "stringValue"), to: self.skView.scene, withKeyPath: #keyPath(GameScene.debugText), options: nil)
            return customViewItem
        default:
            return nil
        }
    }
}

