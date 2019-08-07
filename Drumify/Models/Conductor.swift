//
//  Conductor.swift
//  Drumify
//
//  Created by Jackson Kurtz on 5/12/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation
import AudioKit

class Conductor {
    
    //var player: AKPlayer!
    var midiSampler: AKMIDISampler!
    var audioFile: AKAudioFile!
    var players: [AKPlayer]!
    var mixer: AKMixer!
    var isPlaying: Bool
    
    var timer:  Timer!
    var timeCounter:Float!
    
    //aksampler
    var akSampler: AKSampler!

    init() {
        //player = AKPlayer()
        //players = Array(repeating: AKPlayer(), count: 5 )
        players = [AKPlayer]()
        for _ in 0...4 {
            let player = AKPlayer()
            players.append(player)
        }
        isPlaying = false
    }
    
    // sets up player with correct audio file for each lane in sequencer
    func preparePlayers(beat: Beat) {
        if (AudioKit.engine.isRunning )
        {
            try! AudioKit.stop()
        }
        try! AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        
        for (i, lane) in beat.lanes.enumerated() {
            print("\nCONDUCTOR: attempting to load file #" + "\(i)")
            if let filepath =  lane.recording?.filepath {
                print("CONDUCTOR: Loading file with name: " + filepath)

                let akAudioFile = try! AKAudioFile(readFileName: filepath, baseDir: .documents)
                
                players[i].load(audioFile: akAudioFile)

                players[i].startTime = getPeakTime(file: akAudioFile )
                print("CONDUCTOR: player[0] has file: " + (players[0].audioFile?.fileNamePlusExtension ?? "<NOFILE>"))
                
                print("CONDUCTOR: player[1] has file: " + (players[1].audioFile?.fileNamePlusExtension ?? "<NOFILE>"))
                
                print("CONDUCTOR: player[2] has file: " + (players[2].audioFile?.fileNamePlusExtension ?? "<NOFILE>"))
            }
            else {
                print("CONDUCTOR: loading empty player for #" + "\(i)")

                players[i] = AKPlayer()
            }
            //print("CONDUCTOR: successfully loaded file #" + "\(i)")

        }
        
        print("\nCONDUCTOR: Finished loading audio files")
        print("CONDUCTOR: player[0] has file: " + (players[0].audioFile?.fileNamePlusExtension ?? "<NOFILE>"))

        print("CONDUCTOR: player[1] has file: " + (players[1].audioFile?.fileNamePlusExtension ?? "<NOFILE>"))

        print("CONDUCTOR: player[2] has file: " + (players[2].audioFile?.fileNamePlusExtension ?? "<NOFILE>"))
        mixer = AKMixer(players)
        AudioKit.output = mixer
        try! AudioKit.start()
    }

    func getTimePattern(numBeats: Int, tempo: Int) -> [Float] {
        let beat_time = 60 / Float(tempo * 2)
        print("CONDUCTOR: beat_time in getTimePattern: ", beat_time)
        var time_arr = [Float]()
        for i in 0...numBeats {
            let time = beat_time * i
            time_arr.append( Float(time) )
        }
        return time_arr
    }
    
    
    func pauseBeat(cursorConstraint: NSLayoutConstraint) {
        cursorConstraint.constant = 0
        timer.invalidate()
        for player in players {
            player.stop()
        }
        isPlaying = false
    }
    
    func playPattern(beat: Beat, looping: Bool, cursorConstraint: NSLayoutConstraint, sequencerWidth: CGFloat) {
        print("CONDUCTOR: play pattern..." )
        let numBeats = beat.lanes[0].bars[0].count
        let timePattern = getTimePattern(numBeats: numBeats, tempo: beat.bpm)
        
        timeCounter = 0.0
        let rate:Float = 0.001
        var beatIndex = 0
        var repeatNum = 0
        print("CONDUCTOR: starting timer..." )
        let barLength = 60 * numBeats / (beat.bpm * 2 )
        print("barlength: " + "\(barLength)" )
        timer = Timer.scheduledTimer(withTimeInterval: Double(rate), repeats: true, block: { (timer) in
            print("CONDUCTOR:cycling: " + "\(self.timeCounter! )"  )
            cursorConstraint.constant = sequencerWidth * CGFloat((self.timeCounter - (repeatNum * barLength)) / barLength)
            let targetTime = timePattern[beatIndex] + (repeatNum * barLength)
            print("target time: " + "\(targetTime)" )
            let diff = abs( targetTime - self.timeCounter )
            //print("diff: " + "\(diff)" )
            
            if( diff <= rate / 2  ) {
                if beatIndex >= timePattern.count - 1 {
                    if looping {
                        print("CONDUCTOR: resetting beat index...")
                        beatIndex = 0
                        repeatNum += 1
                        cursorConstraint.constant = 0
                    }
                    else {
                        timer.invalidate()
                        
                    }
                }
                
                print("playing sound at: " + "\(self.timeCounter! )" )
                
                for (i,lane) in beat.lanes.enumerated() {
                    //print("Beat index before call: ", beatIndex)

                    if( lane.bars[0][beatIndex] ) {
                        self.playLane(index: i)
                    }
                }
                beatIndex += 1
                print("CONDUCTOR: time pattern count: ", timePattern.count)
                
            }
            self.timeCounter += rate

        })
        isPlaying = true
    }
    
    func playLane(index: Int) {
        print("CONDUCTOR: attempting to play sound in lane #", index)
        print("CONDUCTOR: number of players in list: ", players.count)

        if players[index].audioFile != nil {
            players[index].stop()
            players[index].play()
        }
    }

}
