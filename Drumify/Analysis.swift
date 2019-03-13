//
//  Analysis.swift
//  NewDrumAnalysis
//
//  Created by Jackson Kurtz on 3/9/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation
import AudioKit


var player: AKPlayer!
var fftTap: AKFFTTap?
var timer:  Timer!
let FFT_SIZE = 512
let sampleRate:double_t = 44100
let timeInterval = 0.01
var timeCounter:Double = 0
//var freqMatrix = Array<Any>(repeating: Array<Double>(), count: 9 )
var freqMatrix = Array(repeating: [Double](), count: 9)

//finds list of 9 amplitude values for the frequency spectrum of audio file, with equal separation on a log scale
//updates table with analysis in handler
func getDrumCategory(fname: String, view: ViewController) {
    print("getting drum category")
    var ampProfile = [Double]()
    var selectedFreqs: [Int] = []
    for i in 0...10 {
        selectedFreqs.append(Int(pow(Float(2), Float(i))))
    }
    print(selectedFreqs)
    if let drum = try? AKAudioFile(readFileName: fname, baseDir: .documents) {
        //var norm_drum:AKAudioFile
        /*do {
            norm_drum = try drum.normalized(baseDir: .temp, name: "tempNormalized", newMaxLevel: -4)
            player = AKPlayer(audioFile: norm_drum)
            player.startTime = getPeakTime(file: norm_drum)
        }
        catch {
            print("normalization error")
        }*/
        player = AKPlayer(audioFile: drum)
        player.startTime = getPeakTime(file: drum)
        player.completionHandler = {
            timer.invalidate()
            player.stop()
            do {
                try AudioKit.stop()
            }
            catch {
               print("failed to stop audiokit after categorization")
            }
            Swift.print("completion callback has been triggered!")
            for index in 0...freqMatrix.count-1 {
                //print("num values: ", self.freqMatrix[index].count)
                ampProfile.append(freqMatrix[index].reduce(0, +)/freqMatrix[index].count)
                //print("average amplitudes: ", ampProfile)
            }
            let drum_type = categorizeProfile(profile: ampProfile)
            view.currentCategory = drum_type
            print(ampProfile)
            print("category found: ", drum_type)
        }
        player.isLooping = false
        player.buffering = .always
        
        //get peak time to start audio analysis on
        //let peakTime = (Double(floats.index( of: cmax! )!)/Double(file.samplesCount)) * file.duration
        
        fftTap = AKFFTTap.init(player)
        AudioKit.output = player
        do {
            try AudioKit.start()
            
            player.play()
            print("running audiokit")
        }
        catch {print("failed to run audiokit")}
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            timeCounter += timeInterval
            if (freqMatrix.last?.count)! > 6 {
                timer.invalidate()
            }
            //print("freq response at ", timeCounter, " seconds")
            
            for i in 0...FFT_SIZE-2{
                
                if(selectedFreqs.contains(i)) {
                    let re = fftTap!.fftData[i]
                    //print(self.fftTap!.fftData.count)
                    //print(self.fftTap!.fftData[i])
                    let im = fftTap!.fftData[i + 1]
                    let normBinMag = 2.0 * sqrt(re * re + im * im)/FFT_SIZE
                    let amplitude = (20.0 * log10(normBinMag))
                    let freqIndex = selectedFreqs.firstIndex(of: i)!
                    if amplitude.isFinite {
                        freqMatrix[freqIndex].append(amplitude)
                    }
                    //print("bin: \(i/2) \t freq: \(self.sampleRate*0.5*i/self.FFT_SIZE)\t ampl.: \(amplitude)")
                    //print("bin#: \(freqIndex + 1) \t freq: \(sampleRate*0.5*i/FFT_SIZE)\t ampl.: \(amplitude)")
                    
                }
            }
            print( "\n")
        })
    }
    else {
        print("failed to read file while getting drum category!")
    }
}

func categorizeProfile(profile: [Double]) -> DrumType {
    var category = DrumType.uncategorized
    let max_index = profile.firstIndex(of: profile.max()!)
    if max_index == nil {
        return category
    }
    else {
        print("max freq index: ", max_index!)
        if max_index! < 2 {
            category = DrumType.bass
        }
        else if max_index! > 6 {
            category = DrumType.hat
            
        }
        else {
            category = DrumType.snare
        }
        return category
    }
    
}
