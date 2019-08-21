//
//  SkillBookComponent.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import GameplayKit

enum SkillError: Error {
    case campNotFound(GKEntity?)
    case unitTemplateNotFound(Skill)
    case needResources([Resource])
    case needTarget
    case skillAlreadyInProgress
}

enum ResourceStatus {
    case ok, needTime, needStockedResources([Resource])
}

enum SkillFilter {
    case all
    case building
    case attacks
    case basic

    func accept(_ skill: Skill) -> Bool {
        switch (self, skill.template.type) {
        case (.all, _):
            return true
        case (.building ,.building(type: _, id: _)):
            return true

        case (.attacks, .direct(_)): // TODO: re-write this filter
            return true

        case (.basic, .basic):
            return true

        default:
            return false
        }
    }
}

class SkillBookComponent: GKComponent {
    private let skills: [Skill]
    var currentSkill: Skill?
    var filter: SkillFilter = .all

    var filteredSkills: [Skill] { self.skills.filter(filter.accept) }

    unowned var entityManager: EntityManager

    init(templates: [SkillTemplate], entityManager: EntityManager) {
        self.skills = templates.map { Skill(template: $0) }
        self.entityManager = entityManager
        super.init()
    }
    
    func execute(_ skill: Skill) throws {
        guard skill.template.id != .base_0 else { // stop
            self.stopCurrentSkill()
            return
        }

        guard self.currentSkill == nil else {
            throw SkillError.skillAlreadyInProgress
        }

        guard skill.isTargetReady else {
            throw SkillError.needTarget
        }

        if let moveComponent = self.entity?.component(ofType: MoveableComponent.self) {
            moveComponent.stopMovement()
        }

//        skill.execute(with: entity)
        switch skill.template.type {
        case .basic:
            break
        case .building(_, _):
            guard let camp = self.entity?.component(ofType: CampComponent.self)?.camp else {
                throw SkillError.campNotFound(self.entity)
            }

            guard let template = camp.templates.getBuildableUnitTemplate(for: skill) else {
                throw SkillError.unitTemplateNotFound(skill)
            }

            let ensureResources = self.ensureResources(time: skill.currentTime, requiredResources: template.requiredToBuild, availableResources: camp.availableResources.map { ($0.key, $0.value.current) })
            if case .needStockedResources(let resources) = ensureResources {
                print("missing resources: \(resources)")
                throw SkillError.needResources(resources)
            }
            camp.removeResources(template.requiredToBuild)
            
            self.currentSkill = skill
            skill.currentTime = 0.0
            do {
                try self.checkBuilding(for: skill)
                //
            } catch {
                self.stopCurrentSkill()
            }

        case .direct(_):
            // TODO: do the stuff of the skill
            skill.earnExperience()

        case .duration(_):
            self.currentSkill = skill
            skill.currentTime = 0.0
            break
        }
    }
    
    func stopCurrentSkill() {
        currentSkill?.currentTime = 0.0
        currentSkill?.target = .none
        currentSkill = nil

        if let moveComponent = self.entity?.component(ofType: MoveableComponent.self) {
            moveComponent.stopMovement()
        }
    }
    
    private func ensureResources(time: TimeInterval, requiredResources: [Resource: Int], availableResources: [Resource: Int]) -> ResourceStatus {
        var missing = [Resource]()
        var needTime = false
        for (resource, amount) in requiredResources {
            if resource == .time && time < TimeInterval(amount) { // pour mutualiser : -time > -amount ???
                needTime = true
            } else if let availableAmount = availableResources[resource], amount > availableAmount {
                missing.append(resource)
            } else if availableResources[resource] == nil {
                missing.append(resource)
            }
        }

        if missing.count > 0 {
            return .needStockedResources(missing)
        } else if needTime {
            return .needTime
        } else {
            return .ok
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if let currentSkill = self.currentSkill {
            currentSkill.currentTime += seconds
            print("progress : \(currentSkill.progress)")
            do {
                try self.checkProcess(for: currentSkill)
                try self.checkBuilding(for: currentSkill)
            } catch {
                print("checkBuild not succeed : \(error)")
                self.currentSkill = nil
            }
        }
    }

    func checkProcess(for skill: Skill) throws {
        guard case SkillType.duration(_) = skill.template.type else { return }

        // TODO: do some stuff

        if skill.progress == 1.0 {
            self.stopCurrentSkill()
        }
    }

    func checkBuilding(for skill: Skill) throws {
        guard case SkillType.building(_, _) = skill.template.type else { return }

        guard let camp = self.entity?.component(ofType: CampComponent.self)?.camp else {
            throw SkillError.campNotFound(self.entity)
        }

        guard let template = camp.templates.getBuildableUnitTemplate(for: skill) else {
            throw SkillError.unitTemplateNotFound(skill)
        }

        if skill.progress == 1.0 {
            let entity: GKEntity
            switch template.unitType {
            case .building:
                entity = Building(template: template as! BuildingTemplate, camp: camp, isMain: false, entityManager: entityManager)
            case .character:
                entity = Character(template: template as! CharacterTemplate, camp: camp, entityManager: entityManager)
            case .object:
                entity = Object(template: template as! ObjectTemplate)
            }

            if let positionComponent = entity.component(ofType: TextureComponent.self) {
                let positionToBuild: CGPoint
                if let builderFrame = self.entity?.component(ofType: TextureComponent.self)?.sprite.frame {
                    positionToBuild = CGPoint(x: builderFrame.midX, y: builderFrame.minY - positionComponent.sprite.size.height / 2)
                } else {
                    positionToBuild = .zero
                }
                positionComponent.position = positionToBuild
            }
            self.entityManager.toAdd.insert(entity)
            self.stopCurrentSkill()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

import Cocoa

extension SkillBookComponent: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? self.filteredSkills.count : 0
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let skill = self.filteredSkills[indexPath.item]

        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SkillCell"), for: indexPath)
        item.imageView?.image = NSImage(named: skill.template.id.rawValue)

        return item
    }
}

extension SkillBookComponent {
    func applyFilter(index: Int) {
        let orderedFilters: [SkillFilter] = [.attacks, .building, .basic, .all]
        let filterToApply: SkillFilter

        defer { self.filter = filterToApply }

        guard index < orderedFilters.count && index >= 0 else {
            filterToApply = .all
            return

        }

        filterToApply = orderedFilters[index]
    }
}
