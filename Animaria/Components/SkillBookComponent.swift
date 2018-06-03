//
//  SkillBookComponent.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import GameplayKit

class SkillBookComponent: GKComponent {
    let skills: [Skill]
    var currentSkill: Skill?

    unowned var entityManager: EntityManager

    init(templates: [SkillTemplate], entityManager: EntityManager) {
        self.skills = templates.map { Skill(template: $0) }
        self.entityManager = entityManager
        super.init()
    }
    
    func execute(_ skill: Skill) {
        guard skill.template.id != .base_0 else { // stop
            self.stopCurrentSkill()
            return
        }
        guard self.currentSkill == nil else {
            return
        }
//        guard let entity = self.entity else {
//            return
//        }

//        skill.execute(with: entity)
        switch skill.template.type {
        case .basic:
            break
        case .building(_, _):
            self.currentSkill = skill
            skill.currentTime = 0.0
            do {
                try self.checkBuilding(for: skill)
            } catch {
                self.currentSkill = nil
            }

        case .direct(_):
            break
        case .duration(_):
            break
        }
    }
    
    func stopCurrentSkill() {
        currentSkill?.currentTime = 0.0
        currentSkill = nil
    }
    
    private func ensureResources(time: TimeInterval, requiredResources: [Resource: Int]) -> Bool {
//        guard let camp = self.entity?.component(ofType: CampComponent.self)?.camp else {
//            return false
//        }
        
        let availableResources = [Resource: Int]()
        // TODO: get the resources of camps
        // use subset to get only the needed resources
        
        for (resource, amount) in requiredResources {
            if resource == .time && time < TimeInterval(amount) { // pour mutualiser : -time > -amount ???
                return false
            } else if let availableAmount = availableResources[resource], amount > availableAmount {
                return false
            }
        }
        
        return true
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if let currentSkill = self.currentSkill {
            currentSkill.currentTime += seconds
            print("progress : \(currentSkill.progress)")
            do {
                try self.checkBuilding(for: currentSkill)
            } catch {
                print("checkBuild not succeed : \(error)")
                self.currentSkill = nil
            }
        }
    }

    func checkBuilding(for skill: Skill) throws {
        guard let race = skill.template.id.race,
              let template = RaceRepository.all[race]?.getBuildableUnitTemplate(for: skill) else {
            return
        }

        if self.ensureResources(time: skill.currentTime, requiredResources: template.requiredToBuild) {
            let entity: GKEntity
            switch template.unitType {
            case .building:
                entity = Building(template: template as! BuildingTemplate, camp: 0, isMain: false, entityManager: entityManager)
            case .character:
                entity = Character(template: template as! CharacterTemplate, camp: 0, entityManager: entityManager)
            case .object:
                entity = Object(template: template as! ObjectTemplate)
            }

            let positionToBuild: CGPoint
            if let builderFrame = self.entity?.component(ofType: TextureComponent.self)?.sprite.frame {
                positionToBuild = CGPoint(x: builderFrame.midX, y: builderFrame.minY)
            } else {
                positionToBuild = .zero
            }

            if let positionComponent = entity.component(ofType: TextureComponent.self) {
                positionComponent.sprite.position = positionToBuild.applying(CGAffineTransform(translationX: 0.0, y: -1 * positionComponent.sprite.size.height / 2))
            }
            self.entityManager.insert(entity)
            self.stopCurrentSkill()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
