//
//  Template.swift
//  Animaria
//
//  Created by Clément NONN on 26/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

protocol Template: Decodable { }

protocol UnitTemplate: Template {
    var unitType: UnitType { get }
}

protocol BuildableTemplate: Template {
    var requiredToBuild: [Resource: Int] { get }
}
