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
        self.lanes = [Lane(), Lane(), Lane()]
    }
    
    func isCellActive(index: Int, bar: Int) -> Bool {
        let cellPerRow = self.lanes[0].bars[0].count
        let lane = index / cellPerRow
        let cellNum = index % cellPerRow
        return self.lanes[lane].bars[bar][cellNum]
    }
    
    mutating func toggleCellActivation( index: Int, bar: Int ) {
        let cellPerRow = self.lanes[0].bars[0].count
        let lane = index / cellPerRow
        let cellNum = index % cellPerRow
        if self.lanes[lane].bars[bar][cellNum] {
           self.lanes[lane].bars[bar][cellNum] = false
        }
        else {
            self.lanes[lane].bars[bar][cellNum] = true
        }
    }
}
