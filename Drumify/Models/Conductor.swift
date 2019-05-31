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
    
    var player: AKPlayer!
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
        player = AKPlayer()
        players = Array(repeating: AKPlayer(), count: 5 )
        isPlaying = false
    }
    
    func playAudioFile(akfile: AKAudioFile) {
        do
        {
            if (players != nil )
            {
                //for p in players {}
                self.player.stop()
                try AudioKit.stop()
            }
            self.player = AKPlayer(audioFile: akfile)
            player.startTime = getPeakTime(file: akfile)
            player.completionHandler = {
                print( "callback!")
                AKLog("completion callback has been triggered!")
                self.player.stop()
                do {
                    try AudioKit.stop()
                }
                catch {
                    print("failed to stop audiokit after playing")
                }
            }
            AudioKit.output = player
            try AudioKit.start()
            player.play()
        }
        catch
        {
            print( "Failed to play audio file in conductor!")
        }
    }
    
    // sets up player with correct audio file for each lane in sequencer
    func preparePlayers(beat: Beat) {
        if (player != nil )
        {
            self.player.stop()
            try! AudioKit.stop()
        }
        try! AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        
        for (i, lane) in beat.lanes.enumerated() {
            print("CONDUCTOR: attempting to load file #" + "\(i)")
            if let filepath =  lane.recording?.filepath {
                let akAudioFile = try! AKAudioFile(readFileName: filepath, baseDir: .documents)
                
                players[i].load(audioFile: akAudioFile)

                players[i].startTime = getPeakTime(file: akAudioFile )

            }
            else {
                players[i] = AKPlayer()
            }
            print("CONDUCTOR: successfully loaded file #" + "\(i)")

        }
        
        print("CONDUCTOR: Finished loading audio files")
        mixer = AKMixer(players)
        AudioKit.output = mixer
        try! AudioKit.start()
    }

    func getTimePattern(numBeats: Int, tempo: Int) -> [Float] {
        let beat_time = 60 / Float(tempo)
        print("CONDUCTOR: beat_time in getTimePattern: ", beat_time)
        var time_arr = [Float]()
        for i in 0...numBeats {
            let time = beat_time * i
            time_arr.append( Float(time) )
        }
        return time_arr
    }
    
    
    func pauseBeat() {
        timer.invalidate()
        isPlaying = false

    }
    
    func playPattern(beat: Beat, looping: Bool) {
        print("CONDUCTOR: play pattern..." )
        let numBeats = beat.lanes[0].bars[0].count
        let timePattern = getTimePattern(numBeats: numBeats, tempo: beat.bpm)
        
        timeCounter = 0.0
        let rate:Float = 0.1
        var beatIndex = 0
        var repeatNum = 0
        print("CONDUCTOR: starting timer..." )
        let barLength = 60 * numBeats / beat.bpm
        print("barlength: " + "\(barLength)" )
        timer = Timer.scheduledTimer(withTimeInterval: Double(rate), repeats: true, block: { (timer) in
            print("CONDUCTOR:cycling: " + "\(self.timeCounter! )"  )

            let targetTime = timePattern[beatIndex] + (repeatNum * barLength)
            print("target time: " + "\(targetTime)" )
            let diff = abs( targetTime - self.timeCounter )
            //print("diff: " + "\(diff)" )
            
            if( diff <= rate / 2  ) {
                print("playing sound at: " + "\(self.timeCounter! )" )
                
                for (i,lane) in beat.lanes.enumerated() {
                    if( lane.bars[0][beatIndex] ) {
                        self.playLane(index: i)
                    }
                }
                beatIndex += 1
                print("CONDUCTOR: time pattern count: ", timePattern.count)
                if beatIndex >= timePattern.count - 1 {
                    if looping {
                        print("CONDUCTOR: resetting beat index...")
                        beatIndex = 0
                        repeatNum += 1
                    }
                    else {
                        timer.invalidate()

                    }
                }
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
    
    func playSound() {
        player.stop()
        player.play()
    }
    
    func testAKSampler(filepath: String) {

        print("\n\nCONDUCTOR: trying to play file with AKSampler...")
        if(AudioKit.engine.isRunning) {
            try! AudioKit.stop()
        }
        try! AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        AKSettings.playbackWhileMuted = true
        
        //let sampler = AKMIDISampler()
        akSampler = AKSampler()
        audioFile = try! AKAudioFile(readFileName: filepath, baseDir: .documents)
        //try! sampler.loadAudioFile(file)
        
        let desc = AKSampleDescriptor(noteNumber: 60,
                                      noteFrequency: 44100.0/600,
                                      minimumNoteNumber: 0,
                                      maximumNoteNumber: 127,
                                      minimumVelocity: 0,
                                      maximumVelocity: 127,
                                      isLooping: true,
                                      loopStartPoint: 0.0,
                                      loopEndPoint: 1.0,
                                      startPoint: 0.0,
                                      endPoint: 0.0)
        
        akSampler.loadAKAudioFile(from: desc, file: audioFile)
        AudioKit.output = akSampler
        try! AudioKit.start()
        print("before playing sampler...")
        akSampler.play(noteNumber: 60, velocity: 127)
        print("after playing sampler...")
        //sampler.play(noteNumber: 60)
    }
    
    func setupMidiSampler(filepath: String) {
        print("\n\nCONDUCTOR: setting up AKMIDISampler...")
        
        if(AudioKit.engine.isRunning) {
            try? AudioKit.stop()
        }
        
        try! AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        
        midiSampler = AKMIDISampler()
        
        audioFile = try! AKAudioFile(readFileName: filepath, baseDir: .documents)
        //let path = "\(getDirectory().appendingPathComponent(filepath).deletingPathExtension())"
        //print("path from getDirectory(): " + path )
        //try! sampler.loadWav(path)
        try! midiSampler.loadAudioFile(audioFile)
        
        AudioKit.output = midiSampler
        try! AudioKit.start()
    }
    
    func playMidiSampler() {
        print("\n\nCONDUCTOR: trying to play midi sampler with AKMIDISampler...")

        try! midiSampler.play(noteNumber: 60, velocity: 127, channel: 0)

    }
    
    
    func playRecording(filePath: String ) {
        print("CONDUCTOR: attempting to play file with name: ", filePath)
        do
        {
            // player is initialized
            if (player != nil )
            {
                self.player.stop()
                try AudioKit.stop()
            }
            let file = try AKAudioFile(readFileName: filePath, baseDir: .documents)
            
            print("CONDUCTOR: filepath: ",  file.directoryPath )
            print("CONDUCTOR: file name with ext: " , file.fileNamePlusExtension)
            self.player = AKPlayer(audioFile: file)
            player.startTime = getPeakTime(file: file)
            player.completionHandler = {
                print( "callback!")
                AKLog("completion callback has been triggered!")
                self.player.stop()
                do {
                    try AudioKit.stop()
                }
                catch {
                    print("failed to stop audiokit after playing")
                }
            }
            AudioKit.output = player
            try AudioKit.start()
            player.play()
        }
        catch
        {
            print( "Failed to play audio file in conductor!")
        }
    }
    
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
}
