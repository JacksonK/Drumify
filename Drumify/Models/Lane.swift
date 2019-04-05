//
//  Lane.swift
//  Drumify
//
//  Created by Jackson Kurtz on 4/5/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation

struct Lane: Codable {
    var recording: Recording?
    var bars = Array(repeating: [Bool](), count: 1)

    init() {
    }
    //self.recording = nil
    //self.bars = Array(repeating: [Bool](), count: 1)
}
