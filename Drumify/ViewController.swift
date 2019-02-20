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
    
    // Storing a copy of the IndexPath when tapping a cell to play, 
    // so that it can be referenced again when its audio clip stops.
    // This allows for that cell to change appearance when playing and pausing.
    var selectedIndexPath:IndexPath? = nil
    
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
        
        myTableView.dataSource = self;
        myTableView.tableFooterView = UIView()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingTableViewCell", for: indexPath) as! RecordingTableViewCell
        cell.playButtonBottom.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        cell.playButtonRight.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        cell.recordingName?.text = "Audio File " +  String(indexPath.row+1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (selectedIndexPath != nil && selectedIndexPath!.row == indexPath.row) {
            return 150
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        selectedIndexPath = indexPath
        let cell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
        cell.playButtonRight.isHidden = true;
        myTableView.beginUpdates()
        myTableView.endUpdates()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
        cell.playButtonRight.isHidden = false;
        myTableView.beginUpdates()
        myTableView.endUpdates()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        //myTableView.cellForRow(at: selectedIndexPath)?.recordingName?.text = "Audio File " +  String(indexPathCurrentlyPlaying.row+1)
    }
    
    @objc func tappedPlayButton(sender: UIButton) {
        let cell = sender.superview?.superview
        let indexPath = myTableView.indexPath(for: cell as! UITableViewCell)
        playRecording(indexPath: indexPath!)
    }
    
    func playRecording(indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        do
        {
            //tableView.cellForRow(at: indexPath)?.recordingName?.text = "Audio File " +  String(indexPath.row+1) + " playing"
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch
        {
            displayAlert(title: "Playback", message: "Failed to play audio file!")
        }
    }
}

