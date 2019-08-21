//
//  Resource.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

enum Resource: String {
    case crystal, metal, wood, time
}

extension Resource {
    static var allCases: [Resource] {
        return [.crystal, .metal, wood]
    }
}

extension Resource {
    var description: String {
        switch self {
        case .crystal:
            return "Une resource magique pour stocker l'énergie"
        case .metal:
            return "Une resource utile pour fabriquer des armes et des équipements avancés"
        case .wood:
            return "Une resource de base pour construire les premiers batiments et équipements"
        case .time:
            return "Le temps nécessaire pour la construction ou la réalisation"
        @unknown default:
            return "Resource inconnue"
        }
    }
}

extension Resource: Decodable, Encodable { }
