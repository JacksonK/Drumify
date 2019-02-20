//
//  ViewController.swift
//  Drumify
//
//  Created by Jackson Kurtz on 1/27/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

// using Font Awesome:
// 

import UIKit
import AVFoundation
import AudioKit

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    var recordingSession: AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var player:AKPlayer!
    
    var numberOfRecords:Int = 0
    
    // Storing a copy of the IndexPath when tapping a cell to play, 
    // so that it can be referenced again when its audio clip stops.
    // This allows for that cell to change appearance when playing and pausing.
    var indexPathCurrentlyPlaying:IndexPath = IndexPath.init()
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    
    @IBAction func record(_ sender: Any) {
        //Check if we have active recorder
        if audioRecorder == nil
        {
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start audio recording
            do
            {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                buttonLabel.setTitle("\u{f04d}", for: .normal)
            }
            catch
            {
                displayAlert(title: "Recording", message: "failed in recording!")
            }
        }
        else
        {
            //Stopping audio recording
            audioRecorder.stop()
            audioRecorder = nil
            
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            myTableView.reloadData()
            
            buttonLabel.setTitle("\u{f111}", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //AudioKit.output = self.player
        /*do {
            try AudioKit.start()
        }
        catch {
            displayAlert(title: "ViewDidLoad", message: "audiokit start error!")
        }*/
        
        // Do any additional setup after loading the view, typically from a nib.
        recordingSession = AVAudioSession.sharedInstance()
        
        // Method below forces audio to playback through speakers instead of earpiece,
        // based on https://stackoverflow.com/q/1022992
        try! recordingSession.setCategory(AVAudioSession.Category.playAndRecord, 
                                          mode: AVAudioSession.Mode.default, 
                                          policy: AVAudioSession.RouteSharingPolicy.default, 
                                          options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int
        {
            numberOfRecords = number
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission{(hasPermission) in
            if hasPermission
            {
                print("ACCEPTED")
            }
            
        }
    }

    //Function that returns ppath to directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //Function taht displays an alert
    func displayAlert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil   ))
        present(alert, animated: true, completion: nil)
    }
    
    //Table view setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Audio File " +  String(indexPath.row+1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        print( path )
        do
        { 
            // player is initialized and running
            if (player != nil )
            {
                
                self.myTableView.cellForRow(at: self.indexPathCurrentlyPlaying)?.textLabel?.text = "Audio File " +  String(self.indexPathCurrentlyPlaying.row+1)
                self.player.stop()
                try AudioKit.stop()
            }
            tableView.cellForRow(at: indexPath)?.textLabel?.text = "Audio File " +  String(indexPath.row+1) + " playing"
            indexPathCurrentlyPlaying = indexPath
            //audioPlayer = try AVAudioPlayer(contentsOf: path)
            //audioPlayer.delegate = self
            //audioPlayer.play()
            
            
            //play using audiokit
            let file = try AKAudioFile(readFileName: "\(indexPath.row + 1).m4a", baseDir: .documents)
            player = AKPlayer(audioFile: file)
            player.completionHandler = {
                print( "callback!")
                AKLog("completion callback has been triggered!")
                self.myTableView.cellForRow(at: self.indexPathCurrentlyPlaying)?.textLabel?.text = "Audio File " +  String(self.indexPathCurrentlyPlaying.row+1)
                //self.player.stop()
                //try AudioKit.stop()
                }
            AudioKit.output = player
            try AudioKit.start()
            player.play()
        }
        catch
        {
            displayAlert(title: "Playback", message: "Failed to play audio file!")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        myTableView.cellForRow(at: indexPathCurrentlyPlaying)?.textLabel?.text = "Audio File " +  String(indexPathCurrentlyPlaying.row+1)
    }
}

