//
//  SkillCell.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa

class SkillCell: NSCollectionViewItem {

    var progressObservation: NSKeyValueObservation?

    @IBOutlet weak var experienceBar: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }

    func setup(image: NSImage?, name: String, level: Int, progress: Double, progressMax: Double) {
        self.imageView?.image = image
        self.textField?.stringValue = "\(name) - \(level)"
        self.experienceBar?.maxValue = progressMax
        self.experienceBar?.doubleValue = progress
    }
}
