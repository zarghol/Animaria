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

extension SkillBookComponent: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? self.skills.count : 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let skill = self.skills[indexPath.item]
        
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SkillCell"), for: indexPath)
        
        guard let cell = item as? SkillCell else {
            return item
        }
        let image = NSImage(named: NSImage.Name(rawValue: skill.template.id))
        cell.image = image
        
        return cell
    }
}

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    // MARK: - Interface
    
    @IBOutlet weak var portraitView: NSImageView!
    
    @IBOutlet weak var lifeSlider: NSSlider!
    @IBOutlet weak var energySlider: NSSlider!
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    
    @IBOutlet weak var skillsFilterSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var skillsCollectionView: NSCollectionView!
    @IBOutlet weak var inventoryButton: NSButton!
    @IBOutlet weak var titlesButton: NSButton!
    
    // MARK: -
    
    var entityManager: EntityManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        // Get the SKScene from the loaded GKScene
        guard let scene = GKScene(fileNamed: "GameScene"),
              let sceneNode = scene.rootNode as! GameScene? else {
            return
        }
        let startPositions = scene.entities
            .filter { $0.component(ofType: StartPositionComponent.self) != nil }
            .compactMap { $0.component(ofType: GKSKNodeComponent.self)?.node.position }
        self.entityManager = EntityManager(scene: sceneNode)
        sceneNode.entityManager = self.entityManager
        sceneNode.startPositions = startPositions
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
        self.updateInterface()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: GameScene.SelectedObjectNotificationName, object: sceneNode)
    }
    
    @objc func updateInterface() {
        guard let selectedEntity = (self.skView.scene as? GameScene)?.selectedObject else {
            self.lifeSlider.isEnabled = false
            self.energySlider.isEnabled = false
            self.nameTextField.stringValue = "Aucune sélection"
            self.descriptionTextField.stringValue = "Pas de description"
            self.inventoryButton.isHidden = true
            self.titlesButton.isHidden = true
            self.skillsCollectionView.dataSource = nil
            self.skillsCollectionView.reloadData()
            return
        }
        if let lifeComponent = selectedEntity.component(ofType: LifeComponent.self) {
            self.lifeSlider.isEnabled = true
            self.lifeSlider.maxValue = lifeComponent.maxLife
            self.lifeSlider.doubleValue = lifeComponent.currentLife
        }
        
        self.energySlider.isEnabled = false
        
        if let namingComponent = selectedEntity.component(ofType: NamingComponent.self) {
            self.nameTextField.stringValue = namingComponent.name
            self.descriptionTextField.stringValue = namingComponent.descriptionText
        }
        
        if let skillsComponents = selectedEntity.component(ofType: SkillBookComponent.self) {
            self.skillsCollectionView.dataSource = skillsComponents
        } else {
            self.skillsCollectionView.dataSource = nil
            
        }
        self.skillsCollectionView.reloadData()
        
        self.inventoryButton.isHidden = false
        self.titlesButton.isHidden = false
        
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        guard let scene = self.skView.scene as? GameScene else {
            return
        }
        self.view.window?.delegate = scene
    }
}

extension ViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let first = indexPaths.first, let item = collectionView.item(at: first) as? SkillCell else {
            return
        }
        let image = item.image
        let view = item.imageView
        print(view?.image ?? "no displayed image")
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
        guard let scene = self.skView.scene else {
            return nil
        }
        switch identifier {
        case .positionLabel:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            customViewItem.view = NSTextField(labelWithString: "Debug Label")
            customViewItem.view.bind(NSBindingName(rawValue: "stringValue"), to: scene, withKeyPath: #keyPath(GameScene.debugText), options: nil)
            return customViewItem
        default:
            return nil
        }
    }
}

