//
//  DataProvider.swift
//  Animaria
//
//  Created by Clément NONN on 03/06/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa

enum DataType: String {
    case buildings, characters, objects, skills
}

protocol DataProvider {
    static func getData(for race: Race, type: DataType) throws -> Data

    static func getBaseData(type: DataType) throws -> Data
}

class XCAssetProvider: DataProvider {
    enum Error: Swift.Error {
        case unableToLoadAsset(assetName: String)
    }

    static func getData(for race: Race, type: DataType) throws -> Data {
        let assetName: NSDataAsset.Name = "\(race.rawValue)/\(type.rawValue)"
        guard let asset = NSDataAsset(name: assetName) else {
            throw Error.unableToLoadAsset(assetName: assetName)
        }
        return asset.data
    }

    static func getBaseData(type: DataType) throws -> Data {
        let assetName: NSDataAsset.Name = type.rawValue
        guard let asset = NSDataAsset(name: assetName) else {
            throw Error.unableToLoadAsset(assetName: assetName)
        }
        return asset.data
    }
}
