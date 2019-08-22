//
//  Race.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa

enum Race: String, CaseIterable {
    static let key = CodingUserInfoKey(rawValue: "race")!
    
    case panda, teddyBear, tiger, koala, sheep
}
extension Race: Codable { }

struct LoadedRace {
    let availableBuildings: [BuildingTemplate]
    let availableCharacters: [CharacterTemplate]
    let buildableObjects: [ObjectTemplate]
    let availableSkills: [SkillTemplate]
}

extension LoadedRace {
    init<T: DataProvider>(race: Race, provider: T.Type) throws {
        let buildingsData = try provider.getData(for: race, type: .buildings)
        let charactersData = try provider.getData(for: race, type: .characters)
        let objectsData = try provider.getData(for: race, type: .objects)
        let skillsData = try provider.getData(for: race, type: .skills)
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.userInfo[Race.key] = race
        self.availableBuildings = try jsonDecoder.decode([BuildingTemplate].self, from: buildingsData)
        self.availableCharacters = try jsonDecoder.decode([CharacterTemplate].self, from: charactersData)
        self.buildableObjects = try jsonDecoder.decode([ObjectTemplate].self, from: objectsData)
        self.availableSkills = try jsonDecoder.decode([SkillTemplate].self, from: skillsData)
    }
}

extension LoadedRace {
    func getTemplate(unitType: UnitType, id: Int) -> Template? {
        switch unitType {
        case .building:
            return self.availableBuildings.first { $0.id == id }
        case .character:
            return self.availableCharacters.first { $0.id == id }
        case .object:
            return self.buildableObjects.first { $0.id == id }
        }
    }

    func getBuildableUnitTemplate(for skill: Skill) -> (UnitTemplate & BuildableTemplate)? {
        guard case .building(let type, let id) = skill.template.type,
              let template = self.getTemplate(unitType: type, id: id) as? UnitTemplate & BuildableTemplate else {
                return nil
        }
        return template
    }
}

struct RaceRepository {
    static let all = RaceRepository(races: Race.allCases, provider: XCAssetProvider.self)
    
    private var races: [Race: LoadedRace]
    private let baseSkills: [SkillTemplate]
    
    init<T: DataProvider>(races: [Race], provider: T.Type) {
        do {
            let jsonDecoder = JSONDecoder()
            let baseSkillsData = try provider.getBaseData(type: .skills)
            self.baseSkills = try jsonDecoder.decode([SkillTemplate].self, from: baseSkillsData)
        } catch {
            print("unable to get bases skills definition : \(error)")
            self.baseSkills = []
        }
        
        self.races = [:]
        for race in races {
            do {
                self.races[race] = try LoadedRace(race: race, provider: provider.self)
            } catch {
                print("unable to load \(race) : \(error)")
            }
        }
    }
    
    func skills(for race: Race) -> [SkillTemplate] {
        var allSkills = self.races[race]?.availableSkills ?? []
        allSkills.append(contentsOf: self.baseSkills)
        return allSkills
    }
    
    subscript(_ race: Race) -> LoadedRace? {
        return self.races[race]
    }
}
