//
//  Title.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

typealias TitleId = String

struct TitleTemplate: Template {
    let id: TitleId
    let name: String
    let description: String
}
