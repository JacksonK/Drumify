//
//  Recording.swift
//  Drumify
//
//  Created by Vernon Chan on 3/8/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation

enum DrumType: String, Codable {
    case bass
    case snare
    case hat
    case uncategorized
}

struct Recording: Codable {
    var name: String
    var filepath: String
    var duration: Double
    var start_time: Double
    var creation_date: Date
    var category: DrumType
    
    init(filepath: String, creation_date: Date, name: String, duration: Double, start_time: Double, category: DrumType) {
        self.name = name
        self.filepath = filepath
        self.creation_date = creation_date
        self.duration = duration
        self.start_time = start_time
        self.category = category
    }
}
