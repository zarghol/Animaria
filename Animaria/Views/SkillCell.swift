//
//  SkillCell.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa

class SkillCell: NSCollectionViewItem {
    
    var image: NSImage? {
        didSet {
            self.imageView?.image = self.image
            print("set imageView image with : \(self.imageView)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
}
