//
//  Beat.swift
//  Drumify
//
//  Created by Jackson Kurtz on 3/16/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation
import AudioKit

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
        //print("cell per row: ", self.cellPerRow)

        //print("lane: ", lane)
        //print("cellNum: ", cellNum)


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
    
    mutating func setSound(laneIndex: Int, recording: Recording) {
        lanes[laneIndex].setRecording(recording: recording)
    }
    
    func getBeatTimes() -> [Double] {
        var beatTimes:[Double]?
        let timeBetweenNotes = (60/bpm)/2
        for n in 0...7 {
            beatTimes?.append(Double(n)*timeBetweenNotes)
        }
        return beatTimes!
    }
    
    func playSound(player: AKPlayer) {
    
        if( player.isPlaying ) {
            player.stop()

        }
        player.play()
    }
    
    func stripFileExtension ( _ filename: String ) -> String {
        var components = filename.components(separatedBy: ".")
        guard components.count > 1 else { return filename }
        components.removeLast()
        return components.joined(separator: ".")
    }
    
    func prepareSequencer(sequencer: AKSequencer) {
        
        if( sequencer.tracks.count != lanes.count) {
            print("error, number of tracks in sequencer does not match lanes")
        }
        
        
        if(AudioKit.engine.isRunning) {
            try? AudioKit.stop()
        }
        
        if sequencer.isPlaying {
            sequencer.stop()
        }
        
        var tracks:[AKMIDISampler] = []
        print("tracks before delete: ", sequencer.trackCount)
        if sequencer.tracks.count > 0 {
            for i in 0...sequencer.tracks.count-1 {
                sequencer.deleteTrack(trackIndex: i)
            }
        }
        print("tracks after delete: ", sequencer.trackCount)

        for (i, lane) in lanes.enumerated() {
            let track = sequencer.newTrack()
            let sampler = AKMIDISampler()
            if let filepath = lane.recording?.filepath {
                //try! sampler.loadWav(filepath)
                print("recording filepath in lane #", i, " filepath: ", filepath)

                if let audioFilePath = Bundle.main.path(forResource: filepath, ofType: "wav", inDirectory: "AudioPresetFiles") {
                    print("path with bundle path in lane #", i, " path: ", audioFilePath)
                    let newPath = stripFileExtension(audioFilePath)
                    print("new path: ", newPath )
                    //try! sampler.loadWav( newPath )
                }
                else {
                    print("couldn't find file using bundle.path...")
                }

                //let file = try! AKAudioFile(readFileName: filepath, baseDir: .documents)
                //try! sampler.loadAudioFile(file)
                print("audio files in sampler #", i, " : ", sampler.audioFiles.count)
                //print( sampler.audioFiles[0].fileName
                //try load path:
            }
            else {
                print("no recording found in lane #", i)

                try! sampler.loadAudioFile(AKAudioFile.silent(samples: 10))
            }
            track?.setMIDIOutput(sampler.midiIn)
            for (ind, seqUnit) in lane.bars[0].enumerated() {
                if seqUnit {
                    let position = Double(ind)/2.0
                    //print("position value: " + String(position))
                    track?.add(noteNumber: 60, velocity: 100, position: AKDuration(beats: position), duration: AKDuration(beats: 0.5))
                }
            }
            tracks.append(sampler)
        }
        sequencer.setLength(AKDuration(beats: 4.0))
        sequencer.enableLooping()
        sequencer.setTempo(Double(self.bpm))
        
        let mixer = AKMixer(tracks)
        AudioKit.output = mixer
        print("tracks before play: ", sequencer.trackCount)

        do {
            print( "PREPARE SEQUENCER: starting audiokit...")

            if !AudioKit.engine.isRunning {
                try AudioKit.start()
            }
        }
        catch {
            print( "PREPARE SEQUENCER: error playing audio in sequencer")
        }
    }
    
    //triggers beat playback
    func startPlaying(sequencer: AKSequencer) {
        if AudioKit.engine.isRunning {
            sequencer.rewind()
            sequencer.play()
        }
        else {
            print( "ERROR, tried to play sequencer when AudioKit was not running!")
        }
    }
    
    func stopPlaying(sequencer: AKSequencer) {
        if sequencer.isPlaying {
            sequencer.stop()
            //try? AudioKit.stop()
        }
        else {
            print( "ERROR: tried to stop sequencer when it was already stopped")
        }
        
    }
    
    
    func printContents() {
        print("Beat contents:")
        for (i, lane) in lanes.enumerated() {
            print("lane #" + String(i))
            for seqUnit in lane.bars[0] {
                print("\(seqUnit) ", terminator: "" )
            }
            print("")
        }
    }
}
