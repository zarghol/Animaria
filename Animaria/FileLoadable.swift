//
//  FileLoadable.swift
//  Animaria
//
//  Created by Clément NONN on 25/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Foundation

protocol FileLoadable {
    func load(fileName: String) throws
}

enum FileError: Error {
    case unknownError
}
