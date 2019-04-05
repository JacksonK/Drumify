//
//  Beat.swift
//  Drumify
//
//  Created by Jackson Kurtz on 3/16/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation

struct Beat: Codable {
    var name: String
    var date: Date
    var measures: Int
    var bpm: Int
    var lanes: [Lane]

    init(name: String) {
        self.name = name
        self.date = Date()
        self.measures = 1
        self.bpm = 120
        self.lanes = [Lane()]
    }
}
