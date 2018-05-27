//
//  Race.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa

enum Race: String {
    case panda, teddyBear, tiger, koala, sheep
    
    static var allCases: [Race] {
        return [.panda, .teddyBear, .tiger, .koala, .sheep]
    }
}
extension Race: Codable { }

struct LoadedRace {
    private static let jsonDecoder = JSONDecoder()
    
    let availableBuildings: [BuildingTemplate]
    let availableCharacters: [CharacterTemplate]
    let buildableObjects: [ObjectTemplate]
}

extension LoadedRace {
    init<T: RaceProvider>(race: Race, provider: T.Type) throws {
        let buildingsData = try provider.getData(for: race, type: .buildings)
        let charactersData = try provider.getData(for: race, type: .characters)
        let objectsData = try provider.getData(for: race, type: .objects)
        
        self.availableBuildings = try LoadedRace.jsonDecoder.decode([BuildingTemplate].self, from: buildingsData)
        self.availableCharacters = try LoadedRace.jsonDecoder.decode([CharacterTemplate].self, from: charactersData)
        self.buildableObjects = try LoadedRace.jsonDecoder.decode([ObjectTemplate].self, from: objectsData)
    }
}

enum RaceDataType: String {
    case buildings, characters, objects
}

protocol RaceProvider {
    static func getData(for race: Race, type: RaceDataType) throws -> Data
}

class XCAssetRaceProvider: RaceProvider {
    enum Error: Swift.Error {
        case unableToLoadAsset(assetName: String)
    }
    
    static func getData(for race: Race, type: RaceDataType) throws -> Data {
        let assetName = NSDataAsset.Name(rawValue:type.rawValue/*"\(race.rawValue)/\(type.rawValue)"*/)
        guard let asset = NSDataAsset(name: assetName) else {
            throw Error.unableToLoadAsset(assetName: assetName.rawValue)
        }
        return asset.data
    }
}
