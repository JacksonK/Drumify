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
    
    var recordings:[Recording]!

    var currentCategory:DrumType!
    //var numberOfRecords:Int = 0
    
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
            let numberOfRecords = recordings.count + 1
            //currentRecording = TempRecording(filepath: "\(numberOfRecords).m4a", creation_date: Date())
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            print("filepath: ", filename)
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
            let filepath = "\(self.recordings.count + 1).m4a"
            getDrumCategory(fname: filepath,view: self)
            print("categorization filepath: ", filepath)

            //alert to name new recording
            let alert = UIAlertController(title: "Name your recording:", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = "recording#" + "\(self.recordings.count)"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                print("Text field: \(textField.text ?? "default value")")
                let new_name = textField.text
                //let filepath = self.getDirectory().appendingPathComponent("\(self.recordings.count + 1)")
                //check if categorization was successful
                if self.currentCategory == nil{
                    print("failed to categorize drum sound")
                    self.currentCategory = DrumType.uncategorized
                }
                let new_recording = Recording(filepath: filepath, creation_date: Date(), name: new_name!, duration: Double(0), category: self.currentCategory!)
                print("category of this sound: ", self.currentCategory!)
                self.currentCategory = nil
                self.recordings.append(new_recording)
                
                do {
                    let encodedData = try PropertyListEncoder().encode(self.recordings)
                    UserDefaults.standard.set(encodedData, forKey: "recordings")
                }
                catch {
                    print("error encoding recordings data in stop record!")
                    
                }
                self.myTableView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
            
            buttonLabel.setTitle("\u{f111}", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        recordingSession = AVAudioSession.sharedInstance()
        
        currentCategory = nil
        
        // Method below forces audio to playback through speakers instead of earpiece,
        // based on https://stackoverflow.com/q/1022992
        try! recordingSession.setCategory(AVAudioSession.Category.playAndRecord, 
                                          mode: AVAudioSession.Mode.default, 
                                          policy: AVAudioSession.RouteSharingPolicy.default, 
                                          options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        /*
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int
        {
            numberOfRecords = number
        }*/
        
        if let data = UserDefaults.standard.value(forKey:"recordings") as? Data {
            recordings = try? PropertyListDecoder().decode([Recording].self, from:data)
        }
        /*
        if let recData:Data = UserDefaults.standard.object(forKey: "recordings") as? Data {
            recordings = (try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [Recording], from: recData)) as? [Recording]
     
        }*/
        else {
            recordings = []
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
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingTableViewCell", for: indexPath) as! RecordingTableViewCell
        cell.playButtonBottom.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        cell.playButtonRight.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        //cell.recordingName?.text = "Audio File " +  String(indexPath.row+1)
        cell.recordingName?.text = recordings![indexPath.row].name

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
        print(path)
        do
        {
            // player is initialized
            if (player != nil )
            {
                let cell = myTableView.cellForRow(at: self.selectedIndexPath!) as! RecordingTableViewCell
                cell.recordingName.text = "Audio File " +  String(self.selectedIndexPath!.row+1)
                self.player.stop()
                try AudioKit.stop()
            }
            let cell = myTableView.cellForRow(at: indexPath) as! RecordingTableViewCell
            cell.recordingName?.text = "Audio File " +  String(indexPath.row+1) + " playing"
            selectedIndexPath = indexPath
            
            let file = try AKAudioFile(readFileName: "\(indexPath.row + 1).m4a", baseDir: .documents)
            let buffer = file.pcmBuffer
            let floats = UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength))
            let cmax = floats.max()

            let peakTime = (Double(floats.index( of: cmax! )!)/Double(file.samplesCount)) * file.duration
            player = AKPlayer(audioFile: file)
            player.startTime = peakTime
            player.completionHandler = {
                print( "callback!")
                AKLog("completion callback has been triggered!")
                let cell = self.myTableView.cellForRow(at: self.selectedIndexPath!) as! RecordingTableViewCell
                cell.recordingName.text = "Audio File " +  String(self.selectedIndexPath!.row+1)                //self.player.stop()
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
}

