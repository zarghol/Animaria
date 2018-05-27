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

extension Resource: Decodable, Encodable { }
