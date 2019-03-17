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

    init(name: String, date: Date, measures: Int, bpm: Int) {
        self.name = name
        self.date = date
        self.measures = measures
        self.bpm = bpm
    }
}
