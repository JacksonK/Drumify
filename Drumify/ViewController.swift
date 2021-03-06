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
    var playbackTimer:Timer!

    
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
    
    //somehow setting this to true correctly forces the view to be landscape only, idk why.
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //cell spacing stuff
    let cellSpacingHeight: CGFloat = Constants.TableCell.cellSpacingHeight
    
    //new akrecorder stuff
    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var recPlayer: AKPlayer!
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var mainMixer: AKMixer!
    
    let mic = AKMicrophone()
    
    var state = State.readyToRecord
    
    enum State {
        case readyToRecord
        case recording
    }
    var conductor = Conductor()
    
    //end of akrecorder stuff
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var categoryTab: UISegmentedControl!
    
    @IBOutlet weak var recordToolbar: UIToolbar!
    @IBAction func changedTab(_ sender: UISegmentedControl) {
        myTableView.reloadData()
    }
    
    func createRecording(new_name: String, filepath: String) {
        //check if categorization was successful
        print("CREATERECORDING(): creating recording with filepath: ", filepath )
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
    
    
    func oldRecord() {
        //Check if we have active recorder
        if audioRecorder == nil
        {
            
            currentUID = UUID().uuidString
            print("OLDRECORD: created UID: ", currentUID ?? "bad UID")
            //let numberOfRecords = recordings.count + 1
            //currentRecording = TempRecording(filepath: "\(numberOfRecords).m4a", creation_date: Date())
            setupRecSession()
            
            print("OLDRECORD: getting filename...")
            let file = currentUID + ".m4a"
            let filename = getDirectory().appendingPathComponent(file)
            print("OLDRECORD: saving file with name: ", filename)
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            
            //Start audio recording
            do
            {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
                let start_status = audioRecorder.record()
                
                print("recording status: ", start_status)
                print("recording during status: ", audioRecorder.isRecording)
                
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
            let stop_status = audioRecorder.isRecording
            print("recording stop status: ", stop_status)
            audioRecorder = nil
            
            let filename = currentUID + ".m4a"
            
            print("categorization filepath: ", filename)
            
            //starts analysis of recorded file, segue occurs on completion
            getDrumCategory(fname: filename, view: self)
            currentUID = nil
            buttonLabel.setTitle("\u{f111}", for: .normal)
            /*
            */
        }
    }
    
    func newRecord() {
        print("pressed record button in state: " + "\(state)")

        switch state {
        case .readyToRecord :
            setupAKRecSession()
            buttonLabel.setTitle("\u{f04d}", for: .normal)
            print("started recording")
            
            state = .recording
            // microphone will be monitored while recording
            // only if headphones are plugged
            if AKSettings.headPhonesPlugged {
                micBooster.gain = 1
            }
            do {
                try recorder.record()
            } catch { AKLog("Errored recording.") }
            
        case .recording :
            // Microphone monitoring is muted
            //micBooster.gain = 0
            print("attempting to get tape...")
            tape = recorder.audioFile!
            print("after get tape...")
            //player.load(audioFile: tape)
            
            if let _ = tape?.duration {
                print("attempting to stop recorder...")
                recorder.stop()
                let filename = UUID().uuidString + ".wav"
                print("attempting to export new file: " + filename)
                tape.exportAsynchronously(name: filename,
                                          baseDir: .documents,
                                          exportFormat: .wav) {_, exportError in
                                            if let error = exportError {
                                                AKLog("Export Failed \(error)")
                                            } else {
                                                AKLog("Export succeeded")
                                                try! AudioKit.stop()
                                                //self.conductor.playRecording(filePath: filename)
                                                //getDrumCategory(fname: filename, view: self)
                                                
                                                self.performSegue(withIdentifier: "showAddRecordingModal", sender: filename)
                                            }
                }
                self.state = .readyToRecord
                buttonLabel.setTitle("\u{f111}", for: .normal)

                //setupUIForPlaying()
            }
        }
    }
    
    // from https://stackoverflow.com/questions/35738133/ios-code-to-convert-m4a-to-wav
    func convertAudio(_ url: URL, outputURL: URL) {
        var error : OSStatus = noErr
        var destinationFile: ExtAudioFileRef? = nil
        var sourceFile : ExtAudioFileRef? = nil
        
        var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        var dstFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        
        ExtAudioFileOpenURL(url as CFURL, &sourceFile)
        
        var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))
        
        ExtAudioFileGetProperty(sourceFile!,
                                kExtAudioFileProperty_FileDataFormat,
                                &thePropertySize, &srcFormat)
        
        dstFormat.mSampleRate = 44100  //Set sample rate
        dstFormat.mFormatID = kAudioFormatLinearPCM
        dstFormat.mChannelsPerFrame = 1
        dstFormat.mBitsPerChannel = 16
        dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mFramesPerPacket = 1
        dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked |
        kAudioFormatFlagIsSignedInteger
        
        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            kAudioFileWAVEType,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &destinationFile)
        print("Error 1 in convertAudio: \(error.description)")
        
        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 2 in convertAudio: \(error.description)")
        
        error = ExtAudioFileSetProperty(destinationFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 3 in convertAudio: \(error.description)")
        
        let bufferByteSize : UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: 32768)
        var sourceFrameOffset : ULONG = 0
        
        while(true){
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: 2,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames : UInt32 = 0
            
            if(dstFormat.mBytesPerFrame > 0){
                numFrames = bufferByteSize / dstFormat.mBytesPerFrame
            }
            
            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
            print("Error 4 in convertAudio: \(error.description)")
            
            if(numFrames == 0){
                error = noErr;
                break;
            }
            
            sourceFrameOffset += numFrames
            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            print("Error 5 in convertAudio: \(error.description)")
        }
        
        error = ExtAudioFileDispose(destinationFile!)
        print("Error 6 in convertAudio: \(error.description)")
        error = ExtAudioFileDispose(sourceFile!)
        print("Error 7 in convertAudio: \(error.description)")
    }
    
    @IBAction func record(_ sender: Any) {
        oldRecord()
    }
    
    //send this ViewController instance to the modal which pops up when recording ends
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddRecordingModal" {
            if let destinationVC = segue.destination as? AddRecordingModalViewController {
                destinationVC.modalPresentationStyle = UIModalPresentationStyle.popover
                destinationVC.popoverPresentationController!.delegate = self
                
                if let filepathString = sender as! String? {
                    destinationVC.filepath = filepathString
                    destinationVC.suggested_category = currentCategory
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
    
    //the function runs right before the popover appears.
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        UIView.animate(withDuration: 0.5) { 
            self.view.alpha = 0.8
        }
    }
    
    //this function runs when the user taps outside of the popover to dismiss it
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        UIView.animate(withDuration: 0.5) { 
            self.view.alpha = 1.0
            self.recordToolbar.alpha = 1.0
        }
    }
    
    
    //user pressed save in the popover
    @IBAction func unwindFromSavedRecording(sender: UIStoryboardSegue) {
        print("begin unwind...")
        UIView.animate(withDuration: 0.5) { 
            self.recordToolbar.alpha = 1.0
            self.view.alpha = 1.0
        }
        if let senderVC = sender.source as? AddRecordingModalViewController {            
            //if UITextFieldDelegate is implemented in Add Recording Modal,
            //should work with just this one line
            //createRecording(new_name: senderVC.filename, filepath: senderVC.filepath)
            print("before placeholder")
            var filename: String = senderVC.filenameTextField.placeholder!
            currentCategory = senderVC.chosen_category
            if senderVC.filenameTextField.text != nil {
                print("before filename count")
                if (senderVC.filenameTextField.text?.count)! > 0 {
                    print("before filename text")

                    filename = senderVC.filenameTextField.text!
                }
            }
            createRecording(new_name: filename, filepath: senderVC.filepath)
            do {
                try recordingSession.setActive(false)
            }
            catch {
                AKLog("UNWINDMODAL: failed to stop recording session")
            }
        }
    }
    
    //user pressed delete in the popover
    @IBAction func unwindFromDeletedRecording(sender: UIStoryboardSegue) {
        UIView.animate(withDuration: 0.5) { 
            self.recordToolbar.alpha = 1.0
            self.view.alpha = 1.0
        }
//        if sender.source is AddRecordingModalViewController {
//            if let senderVC = sender.source as? AddRecordingModalViewController {
//                print("ugh")
//            }
//        }
    }
    
    func setupRecSession() {
        print("OLDRECORD: setting up rec session...")
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord,
                                             mode: AVAudioSession.Mode.default,
                                             policy: AVAudioSession.RouteSharingPolicy.default,
                                             options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try recordingSession.setActive(true)
            print("OLDRECORD: successfully setup rec session.")
        }
        catch {
            print("failed to load recording session")
        }
    }
    


    //Function that returns ppath to directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //Function that displays an alert
    func displayAlert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil   ))
        present(alert, animated: true, completion: nil)
    }
   
    //displays message if table is empty, called upon table reload
    func tableEmptyCheck(recordings: [Recording], categoryIndex: Int) {

        if recordings.count != 0 {
            myTableView.separatorStyle = .singleLine
            myTableView.backgroundView = nil
            myTableView.backgroundColor = Constants.AppColors.red
        }
        else {
            let emptyTableLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: myTableView.bounds.size.width, height: myTableView.bounds.size.height))
            if categoryIndex == 0 {
                emptyTableLabel.text = "No saved bass drum recordings"
            }
            else if  categoryIndex == 1{
                emptyTableLabel.text = "No saved snare drum recordings"
            }
            else {
                emptyTableLabel.text = "No saved hi-hat recordings"
            }
            emptyTableLabel.textColor = UIColor.white
            emptyTableLabel.textAlignment = .center
            myTableView.backgroundColor = UIColor.darkGray
            myTableView.backgroundView = emptyTableLabel
            myTableView.separatorStyle = .none
        }
    }
    
    //Table view setup
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let categoryIndex = categoryTab.selectedSegmentIndex
        if categoryIndex == 0 {
            tableEmptyCheck(recordings: bassRecordings, categoryIndex: categoryIndex)
            return bassRecordings.count
            
        }
        else if categoryIndex == 1 {
            tableEmptyCheck(recordings: snareRecordings, categoryIndex: categoryIndex)
            return snareRecordings.count
        }
        else {
            tableEmptyCheck(recordings: hatRecordings, categoryIndex: categoryIndex)
            return hatRecordings.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryIndex = categoryTab.selectedSegmentIndex
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingTableViewCell", for: indexPath) as! RecordingTableViewCell
        cell.playButtonBottom.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        cell.playButtonRight.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(self.deleteRecordingFromCell(sender:)), for: .touchUpInside)
        cell.currTimeLabel.text = "0.00"
        cell.selectionStyle = .none
        cell.layer.cornerRadius = Constants.TableCell.cornerRadius
        cell.playbackProgressView.progressTintColor = Constants.AppColors.red
        //cell.recordingName?.text = "Audio File " +  String(indexPath.row+1)
        if categoryIndex == 0 {
            cell.recordingName?.text = bassRecordings![indexPath.section].name
            cell.durationLabel?.text = "\(bassRecordings![indexPath.section].duration)"
        }
        else if categoryIndex == 1 {
            cell.recordingName?.text = snareRecordings![indexPath.section].name
            cell.durationLabel?.text = "\(snareRecordings![indexPath.section].duration)"


        }
        else {
            cell.recordingName?.text = hatRecordings![indexPath.section].name
            cell.durationLabel?.text = "\(hatRecordings![indexPath.section].duration)"


        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section) {
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
            deleteRecording(at: indexPath)
        }
    }
    
    @objc func deleteRecordingFromCell(sender: UIButton) {
        let cell = sender.superview?.superview
        let indexPath = myTableView.indexPath(for: cell as! UITableViewCell)
        
        deleteRecording(at: indexPath!)
    }
    
    func deleteRecording(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Are you sure you want to delete this recording?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
            let categoryIndex = self.categoryTab.selectedSegmentIndex
            if categoryIndex == 0 {
                self.bassRecordings.remove(at: indexPath.section)
            }
            else if categoryIndex == 1 {
                self.snareRecordings.remove(at: indexPath.section)
            }
            else {
                self.hatRecordings.remove(at: indexPath.section)
            }
            self.saveRecordingDataChange()
            self.myTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        //myTableView.cellForRow(at: selectedIndexPath)?.recordingName?.text = "Audio File " +  String(indexPathCurrentlyPlaying.row+1)
    }
    
    //handles user tapping any play button attatched to a table view cell
    @objc func tappedPlayButton(sender: UIButton) {
        let cell = sender.superview?.superview
        let recording_cell = cell as! RecordingTableViewCell
        let indexPath = myTableView.indexPath(for: cell as! UITableViewCell)
        if categoryTab.selectedSegmentIndex == 0 && indexPath!.section < bassRecordings.count{
            let bassRec = bassRecordings[indexPath!.section]
            updateProgressView(cell: recording_cell, rec: bassRec)
            playRecording(filePath: bassRec.filepath, indexPath: indexPath!)
        }
        else if categoryTab.selectedSegmentIndex == 1 && indexPath!.section < snareRecordings.count{
            let snareRec = snareRecordings![indexPath!.section]
            updateProgressView(cell: recording_cell, rec: snareRec)
            playRecording(filePath: snareRec.filepath, indexPath: indexPath!)

        }
        else if categoryTab.selectedSegmentIndex == 2 && indexPath!.section < hatRecordings.count{
            let hatRec = hatRecordings![indexPath!.section]
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
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { (timer) in
            let currTime = self.player.currentTime - rec.start_time
            cell.playbackProgressView.progress = Float(currTime / rec.duration)
            cell.currTimeLabel.text = "\(Double(round(100*currTime)/100))"
            //print("progress view time: ", currTime)
            if !self.player.isPlaying || self.player.currentTime < 0 {
                self.playbackTimer.invalidate()
                cell.currTimeLabel.text = "0.00"
            }
        })
    }
    
    //plays audio of given file
    func playRecording(filePath: String, indexPath: IndexPath) {
        
        print("PlayRecording(): is audiokit running?:", AudioKit.engine.isRunning )
        
        let path = getDirectory().appendingPathComponent(filePath)
        print("PlayRecording(): attempting to play file with name: ", path)
        do
        {
            if( AudioKit.engine.isRunning ) {
                try AudioKit.stop()
            }
            // player is initialized
            if (player != nil )
            {
                self.player.stop()
            }
            
            print("PlayRecording(): overriding audio port...")
            try! AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)

            selectedIndexPath = indexPath
            
            print("PlayRecording(): reading file...")

            let file = try AKAudioFile(readFileName: filePath, baseDir: .documents)
            
            print("PlayRecording(): filelength: ", file.length)
            player = AKPlayer(audioFile: file)
            print("PlayRecording(): player initialized")

            player.startTime = getPeakTime(file: file)
            player.completionHandler = {
                print( "callback!")
                AKLog("completion callback has been triggered!")
                self.player.stop()
                do {
                    try AudioKit.stop()
                    print("Sucessfully stopped audiokit after playing")
                }
                catch {
                    print("failed to stop audiokit after playing")
                }
            }
            print("PlayRecording(): setting output")

            AudioKit.output = player
            print("PlayRecording(): starting player...")

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
    
    func setupAKRecSession() {
        print("setupAKRecSession(): setting up...")
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .medium
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            print("setupAKRecSession(): successfully setup playAndRecord Session.")
        } catch {
            AKLog("setupAKRecSession(): Could not set session category.")
        }
        AKSettings.defaultToSpeaker = true

        // Patching
        let monoToStereo = AKStereoFieldLimiter(mic, amount: 1)
        micMixer = AKMixer(monoToStereo)
        //micBooster = AKBooster(micMixer)
        
        // Will set the level of microphone monitoring
        //micBooster.gain = 0
        do {
            recorder = try AKNodeRecorder(node: micMixer)
            print("setupAKRecSession(): successfully initialized AKNodeRecorder.")
        }
        catch {
            AKLog("setupAKRecSession(): failed to initialize AKNodeRecorder.")
        }
        /*if let file = recorder.audioFile {
            recPlayer = AKPlayer(audioFile: file)
        }
        recPlayer.isLooping = true
        //player.completionHandler = playingEnded
        
        moogLadder = AKMoogLadder(recPlayer)
        
        mainMixer = AKMixer(moogLadder, micBooster)
        
        AudioKit.output = mainMixer
         */
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
    
    func setupSegmentController() {
        print("VDL: setting up segment controller..." )
        let font = UIFont(name: "Avenir-Heavy", size: 22)
        categoryTab.setTitleTextAttributes([NSAttributedString.Key.font: font!], for: .normal)
        //categoryTab.backgroundColor = Constants.AppColors.red
        categoryTab.layer.cornerRadius = 4.0;
        categoryTab.clipsToBounds = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        AKSettings.playbackWhileMuted = true

        currentCategory = nil
        currentUID = nil
        
        // Method below forces audio to playback through speakers instead of earpiece,
        // based on https://stackoverflow.com/q/1022992
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
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
        
        //sample file to test audio player
        /*
        self.currentCategory = DrumType.snare
        FileUtilities.copyFileToDocuments(resource: "snare", type: ".m4a")
        createRecording(new_name: "new test snare", filepath: "snare.m4a")
        self.currentCategory = nil
         */

        /*
        recordingSession.requestRecordPermission{(hasPermission) in
            if hasPermission
            {
                print("ACCEPTED")
            }
        }*/
        
        //setupRecSession()
        
        //setupAKRecSession()
        
        myTableView.dataSource = self;
        //myTableView.backgroundColor = .black
        myTableView.tableFooterView = UIView()
        setupSegmentController()
        
        
    }
    
}

