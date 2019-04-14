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
    var cellPerRow: Int

    init(name: String, cellPerRow: Int) {
        self.name = name
        self.date = Date()
        self.measures = 1
        self.bpm = 120
        self.cellPerRow = cellPerRow
        self.lanes = [
            Lane(cellPerRow: self.cellPerRow),
            Lane(cellPerRow: self.cellPerRow),
            Lane(cellPerRow: self.cellPerRow)
        ]
    }
    
    func isCellActive(index: Int, bar: Int) -> Bool {
        let lane = index / (self.cellPerRow)
        let cellNum = index % (self.cellPerRow)
        print("cell per row: ", self.cellPerRow)

        print("lane: ", lane)
        print("cellNum: ", cellNum)


        return self.lanes[lane].bars[bar][cellNum]
    }
    
    mutating func toggleCellActivation( index: Int, bar: Int ) {
        print("test activate")
        print("index: ", index)
        let lane = index / (self.cellPerRow)
        let cellNum = index % (self.cellPerRow)
        
        print("lane: ", lane)
        print("cellNum: ", cellNum)


        if self.lanes[lane].bars[bar][cellNum] {
           self.lanes[lane].bars[bar][cellNum] = false
        }
        else {
            self.lanes[lane].bars[bar][cellNum] = true
        }
    }
    
    mutating func addLane() {
        if(lanes.count < 8) {
            lanes.append( Lane(cellPerRow: self.cellPerRow))
        }
    }
    
    mutating func removeLane(index: Int) {
        if(lanes.count > 1) {
            lanes.remove(at: index)
        }
    }
}
