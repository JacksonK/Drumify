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




class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var player:AKPlayer!
    var playbackTimer:  Timer!

    
    //var recordings:[Recording]!
    var bassRecordings:[Recording]!
    var snareRecordings:[Recording]!
    var hatRecordings:[Recording]!

    var currentCategory:DrumType!
    var currentUID:String!
    //var numberOfRecords:Int = 0
    
    // Storing a copy of the IndexPath when tapping a cell to play, 
    // so that it can be referenced again when its audio clip stops.
    // This allows for that cell to change appearance when playing and pausing.
    var selectedIndexPath:IndexPath? = nil
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var categoryTab: UISegmentedControl!
    
    @IBOutlet weak var recordToolbar: UIToolbar!
    @IBAction func changedTab(_ sender: UISegmentedControl) {
        myTableView.reloadData()
    }
    
    func createRecording(new_name: String, filepath: String) {
        //check if categorization was successful
        if self.currentCategory == nil{
            print("failed to categorize drum sound")
            self.currentCategory = DrumType.uncategorized
        }
        
        //create akaudiofile for duration
        var duration:Double = 0
        var start_time:Double = 0
        do {
            let file = try AKAudioFile(readFileName: filepath, baseDir: .documents)
            start_time = Double(round(100*(getPeakTime(file: file)))/100)
            print( "total duration: ", file.duration)
            duration = Double(round(100*(file.duration - start_time))/100)
        }
        catch {
            print("error creating file to get duration")
        }
        print( "duration: ", duration)
        print( "start_time: ", start_time)
        
        //create new recording structure
        let new_recording = Recording(filepath: filepath, creation_date: Date(), name: new_name, duration: duration, start_time: start_time, category: self.currentCategory!)
        print("category of this sound: ", self.currentCategory!)
        self.currentCategory = nil
        
        //add recording to the correct category array
        if new_recording.category == DrumType.bass {
            self.bassRecordings.append(new_recording)
            self.categoryTab.selectedSegmentIndex = 0
        }
        else if new_recording.category == DrumType.snare  {
            self.snareRecordings.append(new_recording)
            self.categoryTab.selectedSegmentIndex = 1
        }
        else {
            self.hatRecordings.append(new_recording)
            self.categoryTab.selectedSegmentIndex = 2
        }
        
        saveRecordingDataChange()
        self.myTableView.reloadData()
    }
    
    private func saveRecordingDataChange() {
        do {
            let encodedDataBass = try PropertyListEncoder().encode(self.bassRecordings)
            let encodedDataSnare = try PropertyListEncoder().encode(self.snareRecordings)
            let encodedDataHat = try PropertyListEncoder().encode(self.hatRecordings)
            
            UserDefaults.standard.set(encodedDataBass, forKey: "bassRecordings")
            UserDefaults.standard.set(encodedDataSnare, forKey: "snareRecordings")
            UserDefaults.standard.set(encodedDataHat, forKey: "hatRecordings")
        }
        catch {
            print("error encoding recordings data in stop record!")
        }
    }
    
    @IBAction func record(_ sender: Any) {
        //Check if we have active recorder
        if audioRecorder == nil
        {
           
            currentUID = UUID().uuidString
            print("created UID: ", currentUID)
            //let numberOfRecords = recordings.count + 1
            //currentRecording = TempRecording(filepath: "\(numberOfRecords).m4a", creation_date: Date())
            let file = currentUID + ".m4a"
            let filename = getDirectory().appendingPathComponent(file)
            print("saving file with name: ", filename)
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start audio recording
            do
            {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                buttonLabel.setTitle("\u{f04d}", for: .normal)
                print("started recording")
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
            
            let filepath = currentUID + ".m4a"
            currentUID = nil
            
            print("categorization filepath: ", filepath)

            //starts analysis of recorded file
            getDrumCategory(fname: filepath, view: self)

            performSegue(withIdentifier: "showAddRecordingModal", sender: filepath)
            //alert to name new recording
            let alert = UIAlertController(title: "Name your recording:", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = "New Recording"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                print("Text field: \(textField.text ?? "default value")")
                let new_name = textField.text
                self.createRecording(new_name: new_name!, filepath: filepath)
            }))
            self.present(alert, animated: true, completion: nil)
            
            buttonLabel.setTitle("\u{f111}", for: .normal)
        }
    }
    
    //send this ViewController instance to the modal which pops up when recording ends
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddRecordingModal" {
            if let destinationVC = segue.destination as? AddRecordingModalViewController {
                destinationVC.modalPresentationStyle = UIModalPresentationStyle.popover
                destinationVC.popoverPresentationController!.delegate = self
                
                if let filepathString = sender as! String? {
                    destinationVC.filepath = filepathString
                    
                }
            }
        }
        UIView.animate(withDuration: 0.5) { 
            self.recordToolbar.alpha = 0.0
        }
        
//        UIView.animate(withDuration: 2.0, animations: { 
//            //self.recordToolbar.frame.size.height += 100
//            
//            self.recordToolbar.frame = CGRect(x: self.recordToolbar.frame.origin.x,
//                                              y: self.recordToolbar.frame.origin.y + 10,
//                                              width: self.recordToolbar.frame.width, 
//                                              height: self.recordToolbar.frame.height)
//        }, completion: {
//            finished in
//            self.recordToolbar.frame = CGRect(x: self.recordToolbar.frame.origin.x,
//                                              y: self.recordToolbar.frame.origin.y + 10,
//                                              width: self.recordToolbar.frame.width, 
//                                              height: self.recordToolbar.frame.height)
//        })
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        UIView.animate(withDuration: 0.5) { 
            self.view.alpha = 0.8
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        UIView.animate(withDuration: 0.5) { 
            self.view.alpha = 1.0
            self.recordToolbar.alpha = 1.0
        }
    }
    
    
    
    @IBAction func unwindFromSavedRecording(sender: UIStoryboardSegue) {
        UIView.animate(withDuration: 0.5) { 
            self.recordToolbar.alpha = 1.0
            self.view.alpha = 1.0
        }
        if let senderVC = sender.source as? AddRecordingModalViewController {            
            //if UITextFieldDelegate is implemented in Add Recording Modal,
            //should work with just this one line
            //createRecording(new_name: senderVC.filename, filepath: senderVC.filepath)
            var filename: String = senderVC.filenameTextField.placeholder!
            currentCategory = senderVC.chosen_category
            if senderVC.filenameTextField.text != nil {
                if (senderVC.filenameTextField.text?.count)! > 0 {
                    filename = senderVC.filenameTextField.text!
                }
            }
            createRecording(new_name: filename, filepath: senderVC.filepath)
        }
    }
    
    @IBAction func unwindFromDeletedRecording(sender: UIStoryboardSegue) {
        UIView.animate(withDuration: 0.5) { 
            self.recordToolbar.alpha = 1.0
            self.view.alpha = 1.0
        }
        if sender.source is AddRecordingModalViewController {
            if let senderVC = sender.source as? AddRecordingModalViewController {
                print("ugh")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        recordingSession = AVAudioSession.sharedInstance()
        
        currentCategory = nil
        currentUID = nil
        
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
        
        //retrieve recordings data from local storage
        if let bassData = UserDefaults.standard.value(forKey:"bassRecordings") as? Data {
            bassRecordings = try? PropertyListDecoder().decode([Recording].self, from:bassData)
        }
        else { bassRecordings = [] }
        if let snareData = UserDefaults.standard.value(forKey:"snareRecordings") as? Data {
            snareRecordings = try? PropertyListDecoder().decode([Recording].self, from:snareData)
        }
        else { snareRecordings = [] }
        if let hatData = UserDefaults.standard.value(forKey:"hatRecordings") as? Data {
            hatRecordings = try? PropertyListDecoder().decode([Recording].self, from:hatData)
        }
        else { hatRecordings = [] }
        
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
        let categoryIndex = categoryTab.selectedSegmentIndex
        if categoryIndex == 0 {
            return bassRecordings.count
        }
        else if categoryIndex == 1 {
            return snareRecordings.count
        }
        else {
            return hatRecordings.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryIndex = categoryTab.selectedSegmentIndex
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingTableViewCell", for: indexPath) as! RecordingTableViewCell
        cell.playButtonBottom.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        cell.playButtonRight.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        cell.currTimeLabel.text = "0.00"
        //cell.recordingName?.text = "Audio File " +  String(indexPath.row+1)
        if categoryIndex == 0 {
            cell.recordingName?.text = bassRecordings![indexPath.row].name
            cell.durationLabel?.text = "\(bassRecordings![indexPath.row].duration)"
        }
        else if categoryIndex == 1 {
            cell.recordingName?.text = snareRecordings![indexPath.row].name
            cell.durationLabel?.text = "\(snareRecordings![indexPath.row].duration)"


        }
        else {
            cell.recordingName?.text = hatRecordings![indexPath.row].name
            cell.durationLabel?.text = "\(hatRecordings![indexPath.row].duration)"


        }

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
    
    //deleting rows in table view
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alert = UIAlertController(title: "Are you sure you want to delete this recording?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
                let categoryIndex = self.categoryTab.selectedSegmentIndex
                if categoryIndex == 0 {
                    self.bassRecordings.remove(at: indexPath.row)
                }
                else if categoryIndex == 1 {
                    self.snareRecordings.remove(at: indexPath.row)
                }
                else {
                    self.hatRecordings.remove(at: indexPath.row)
                }
                self.saveRecordingDataChange()
                tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        //myTableView.cellForRow(at: selectedIndexPath)?.recordingName?.text = "Audio File " +  String(indexPathCurrentlyPlaying.row+1)
    }
    
    //handles user tapping any play button attatched to a table view cell
    @objc func tappedPlayButton(sender: UIButton) {
        let cell = sender.superview?.superview
        let recording_cell = cell as! RecordingTableViewCell
        let indexPath = myTableView.indexPath(for: cell as! UITableViewCell)
        if categoryTab.selectedSegmentIndex == 0 && indexPath!.row < bassRecordings.count{
            let bassRec = bassRecordings[indexPath!.row]
            updateProgressView(cell: recording_cell, rec: bassRec)
            playRecording(filePath: bassRec.filepath, indexPath: indexPath!)
        }
        else if categoryTab.selectedSegmentIndex == 1 && indexPath!.row < snareRecordings.count{
            let snareRec = snareRecordings![indexPath!.row]
            updateProgressView(cell: recording_cell, rec: snareRec)
            playRecording(filePath: snareRec.filepath, indexPath: indexPath!)

        }
        else if categoryTab.selectedSegmentIndex == 2 && indexPath!.row < hatRecordings.count{
            let hatRec = hatRecordings![indexPath!.row]
            updateProgressView(cell: recording_cell, rec: hatRec)
            playRecording(filePath: hatRec.filepath, indexPath: indexPath!)
        }
        else {
            print("tappedPlayButton: selected cell index is invalid!")
        }
        
    }
    
    //updates progress view in given cell for given file
    func updateProgressView(cell:RecordingTableViewCell, rec:Recording) {
        print("starting to update progress view...")
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            let currTime = self.player.currentTime - rec.start_time
            cell.playbackProgressView.progress = Float(currTime / rec.duration)
            cell.currTimeLabel.text = "\(Double(round(100*currTime)/100))"
            print("progress view time: ", currTime)
            if !self.player.isPlaying || self.player.currentTime < 0 {
                self.playbackTimer.invalidate()
                cell.currTimeLabel.text = "0.00"
            }
        })
    }
    
    //plays audio of given file
    func playRecording(filePath: String, indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent(filePath)
        print("attempting to play file with name: ", path)
        do
        {
            // player is initialized
            if (player != nil )
            {
                let cell = myTableView.cellForRow(at: self.selectedIndexPath!) as! RecordingTableViewCell
                //cell.recordingName.text = "Audio File " +  String(self.selectedIndexPath!.row+1)
                self.player.stop()
                try AudioKit.stop()
            }
            let cell = myTableView.cellForRow(at: indexPath) as! RecordingTableViewCell
            //cell.recordingName?.text = "Audio File " +  String(indexPath.row+1) + " playing"
            selectedIndexPath = indexPath
            
            let file = try AKAudioFile(readFileName: filePath, baseDir: .documents)
            
            player = AKPlayer(audioFile: file)
            player.startTime = getPeakTime(file: file)
            player.completionHandler = {
                print( "callback!")
                AKLog("completion callback has been triggered!")
                let cell = self.myTableView.cellForRow(at: self.selectedIndexPath!) as! RecordingTableViewCell
                //cell.recordingName.text = "Audio File " +  String(self.selectedIndexPath!.row+1)                //self.player.stop()
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
    
    func megaPrint(string: String) {
        print("\n\n\n\n\n" + string + "\n\n\n\n\n")
    }
}

