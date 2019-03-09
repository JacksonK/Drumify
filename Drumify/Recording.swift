//
//  Recording.swift
//  Drumify
//
//  Created by Vernon Chan on 3/8/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation

enum DrumType {
    case bass
    case snare
    case hat
    case uncategorized
}

struct Recording {
    var name: String
    var filepath: String
    var duration: Double
    var creation_date: Date
    var category: DrumType
}
