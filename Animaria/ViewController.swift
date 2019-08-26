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
    
    // MARK: - Interface

    var uiObservations = [String: NSKeyValueObservation]()
    var resourcesObservation: NSKeyValueObservation!
    
    @IBOutlet weak var portraitView: NSImageView!
    
    @IBOutlet weak var lifeSlider: NSSlider!
    @IBOutlet weak var energySlider: NSSlider!
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    
    @IBOutlet weak var skillsFilterSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var skillsCollectionView: NSCollectionView!
    @IBOutlet weak var inventoryButton: NSButton!
    @IBOutlet weak var titlesButton: NSButton!
    
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var buildingProgressIndicator: NSProgressIndicator!


    @IBOutlet weak var woodProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var woodTextfield: NSTextField!

    @IBOutlet weak var metalProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var metalTextfield: NSTextField!

    @IBOutlet weak var crystalProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var crystalTextfield: NSTextField!

    @IBOutlet weak var minimapView: SKView!
    
    // MARK: -
    
    var entityManager: EntityManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let gen = MapGenerator()
            let generatedScene = try gen.load(tileCount: 100, tileSize: 125)
            TextureComponent.minimapRatio = minimapView.frame.size.height / generatedScene.size.height

            generatedScene.createMinimap(
                with: Int(minimapView.frame.size.height),
                originalMapSize: self.skView.frame.size
            )

            self.entityManager = EntityManager(scene: generatedScene, minimapScene: generatedScene.minimapScene)
            generatedScene.entityManager = self.entityManager

            // Set the scale mode to scale to fit the window
            generatedScene.scaleMode = .aspectFill

            // Present the scene
            if let view = self.skView {
                view.presentScene(generatedScene)
                view.ignoresSiblingOrder = true
            }

            if let minView = self.minimapView {
                minView.presentScene(generatedScene.minimapScene)
            }
            self.updateInterface()

            resourcesObservation = generatedScene.observe(\GameScene.playerCamp.resourcesDidChanges) { (_, _) in
                self.updateResources()
            }
            self.updateResources()

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateInterface),
                name: GameScene.SelectedObjectNotificationName,
                object: generatedScene
            )
        } catch {
            print("error at beginning : \(error)")
        }

//        let startPositions = scene.entities
//            .filter { $0.component(ofType: StartPositionComponent.self) != nil }
//            .compactMap { $0.component(ofType: GKSKNodeComponent.self)?.node.position }

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
            self.uiObservations.removeAll()
            self.informationLabel.isHidden = true
            self.buildingProgressIndicator.isHidden = true
            self.buildingProgressIndicator.doubleValue = 0.0
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
        
        if let skillsComponent = selectedEntity.component(ofType: SkillBookComponent.self) {
            self.skillsCollectionView.dataSource = skillsComponent

            self.checkSkillProgressDisplayed(skillsComponent: skillsComponent)
        } else {
            self.skillsCollectionView.dataSource = nil
            self.uiObservations.removeAll()
            self.informationLabel.isHidden = true
            self.buildingProgressIndicator.isHidden = true
            self.buildingProgressIndicator.doubleValue = 0.0
        }
        self.skillsCollectionView.reloadData()
        
        self.inventoryButton.isHidden = false
        self.titlesButton.isHidden = false
    }

    func updateResources() {
        guard let resources = (self.skView.scene as? GameScene)?.playerCamp.availableResources else {
            return
        }
        if let (value, maxValue) = resources[.wood] {
            self.woodTextfield.stringValue = "\(value) / \(maxValue)"
            self.woodProgressIndicator.maxValue = Double(maxValue)
            self.woodProgressIndicator.doubleValue = Double(value)
        }
        if let (value, maxValue) = resources[.metal] {
            self.metalTextfield.stringValue = "\(value) / \(maxValue)"
            self.metalProgressIndicator.maxValue = Double(maxValue)
            self.metalProgressIndicator.doubleValue = Double(value)
        }
        if let (value, maxValue) = resources[.crystal] {
            self.crystalTextfield.stringValue = "\(value) / \(maxValue)"
            self.crystalProgressIndicator.maxValue = Double(maxValue)
            self.crystalProgressIndicator.doubleValue = Double(value)
        }
    }

    func checkSkillProgressDisplayed(skillsComponent: SkillBookComponent) {
        if let currentSkill = skillsComponent.currentSkill, currentSkill.progress < 1.0 {
            self.informationLabel.isHidden = false
            self.informationLabel.stringValue = "Construction en cours..."
            self.buildingProgressIndicator.isHidden = false
            let observation = currentSkill.observe(\Skill.progress) { (skill, _) in
                self.buildingProgressIndicator.doubleValue = skill.progress
                if skill.progress >= 1.0 {
                    self.informationLabel.isHidden = true
                    self.buildingProgressIndicator.isHidden = true
                    self.uiObservations["skill.progress"] = nil
                }
            }

            uiObservations["skill.progress"] = observation
        } else {
            self.informationLabel.isHidden = true
            self.buildingProgressIndicator.isHidden = true
            self.uiObservations["skill.progress"] = nil
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        guard let scene = self.skView.scene as? GameScene else {
            return
        }
        self.view.window?.delegate = scene
    }

    @IBAction func filterSkills(sender: NSSegmentedControl) {
        guard let skillsDatasource = self.skillsCollectionView.dataSource as? SkillBookComponent else {
            return
        }

        skillsDatasource.applyFilter(index: sender.selectedSegment)
        self.skillsCollectionView.reloadData()
    }
}

extension ViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)

        guard let scene = self.skView.scene as? GameScene,
            let selectedIndexPath = indexPaths.first else {
                return
        }

        do {
            try scene.selectSkill(index: selectedIndexPath.item)
        } catch SkillError.needResources(let resources) {
            self.informationLabel.stringValue = "Resources manquantes : \(resources)"
            self.informationLabel.isHidden = false
        } catch SkillError.needTarget {
            self.informationLabel.stringValue = "Sélectionner une cible"
            self.informationLabel.isHidden = false
        } catch {
            print("unable to cast skill : \(error)")
        }
    }
}

extension NSTouchBarItem.Identifier {
    static let positionLabel = NSTouchBarItem.Identifier(rawValue: "positionLabel")
}

extension NSTouchBar.CustomizationIdentifier {
    static let debugBar: NSTouchBar.CustomizationIdentifier = "debugBar"
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
        guard let scene = self.skView.scene as? GameScene else {
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

//extension NSObject {
//    func bind<T, ValueType, V>(to destinationKeyPath: WritableKeyPath<V, ValueType>, with source: T, sourcePath: KeyPath<T, ValueType>) where V : NSObject {
//        source.observe(sourcePath) { _, change in
//            (self as? V)?[keyPath: destinationKeyPath] = source[keyPath: sourcePath]
//        }
//    }
//}

