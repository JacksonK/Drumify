//
//  Lane.swift
//  Drumify
//
//  Created by Jackson Kurtz on 4/5/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation
import AudioKit

struct Lane: Codable {
    var recording: Recording?
    var bars = Array(repeating: [Bool](), count: 1)

    init(cellPerRow: Int) {
        for _ in 0...(cellPerRow-1) {
            bars[0].append(false)
        }
    }
    
    mutating func setRecording(recording: Recording) {
        self.recording = recording
    }
    
    //self.recording = nil
    //self.bars = Array(repeating: [Bool](), count: 1)
}
