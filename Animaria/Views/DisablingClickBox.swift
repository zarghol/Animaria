//
//  DisablingClickBox.swift
//  Animaria
//
//  Created by Clément NONN on 27/05/2018.
//  Copyright © 2018 Clément NONN. All rights reserved.
//

import Cocoa

class DisablingClickBox: NSBox {
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func mouseUp(with event: NSEvent) { } // disable this event for UI
}
