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


class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    var recordingSession: AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    var numberOfRecords:Int = 0
    
    var indexOfCurrentlyPlaying:IndexPath = IndexPath.init()
    
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
            tableView.cellForRow(at: indexPath)?.textLabel?.text = "Audio File " +  String(indexPath.row+1) + " playing"
            indexOfCurrentlyPlaying = indexPath
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch
        {
            displayAlert(title: "Playback", message: "Failed to play audio file!")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        myTableView.cellForRow(at: indexOfCurrentlyPlaying)?.textLabel?.text = "Audio File " +  String(indexOfCurrentlyPlaying.row+1)
    }
}

