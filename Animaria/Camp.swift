//
//  Camp.swift
//  Animaria
//
//  Created by Clément NONN on 03/06/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa

class Camp: NSObject {
    let id: Int
    let templates: LoadedRace
    private(set) var availableResources: [Resource: (current: Int, max: Int)]  {
        didSet {
            resourcesDidChanges = true
        }
    }

    @objc var resourcesDidChanges: Bool = false {
        willSet {
            willChangeValue(for: \.resourcesDidChanges)
        }
        didSet {
            resourcesDidChanges = false
            print("resourcesChanges")
            didChangeValue(for: \.resourcesDidChanges)
        }
    }

    init(id: Int, race: LoadedRace) {
        self.id = id
        self.templates = race
        self.availableResources = [Resource: (Int, Int)](uniqueKeysWithValues: Resource.allCases.map { ($0, (0, 200)) })
    }

    func collect(_ resource: Resource, quantity: Int) {
        let vals = self.availableResources[resource] ?? (0, 0)
        let newValue = min(vals.current + quantity, vals.max)
        self.availableResources[resource] = (newValue, vals.max)
    }

    func removeResources(_ resources: [Resource: Int]) {
        for (resource, amount) in resources {
            if let (currentAmount, maxAmount) = self.availableResources[resource] {
                self.availableResources[resource] = (currentAmount - amount, maxAmount)
            }
        }
    }
}
