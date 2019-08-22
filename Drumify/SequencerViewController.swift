//
//  SoundPickerViewController.swift
//  Drumify
//
//  Created by Vernon Chan on 4/12/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit
import AudioKit

class SequencerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var rightOfLaneView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var laneBarView: UIView!
    @IBOutlet weak var leftOfLaneView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var velocityModeButton: UIButton!
    @IBOutlet weak var bpmButton: UIButton!
    @IBOutlet weak var playCursor: UIView!
    @IBOutlet weak var playCursorX: NSLayoutConstraint!
    
    @IBOutlet weak var presetSoundsButton: UIButton!
    @IBOutlet weak var sequencerCollectionView: UICollectionView!
    @IBOutlet weak var laneBarCollectionView: UICollectionView!
    @IBOutlet weak var soundChoiceCollectionView: UICollectionView!
    
    @IBOutlet weak var soundPickerLeftTable: UITableView!
    @IBOutlet weak var categoryTab: UISegmentedControl!
                   var soundPickerLeftTableSelectedIndex:IndexPath? = nil
                   var selectedRecording:Recording? = nil
    
    var recordings:[[Recording]]!

    var beat:Beat!
    var newBeat:Bool=false
    var beatNumber:Int=0
    var sequencer:AKSequencer = AKSequencer()
    var conductor = Conductor()
    var samplers: [AKMIDISampler] = []
    
    let laneColors =   [UIColor(red: 225/255, green: 98/255, blue: 98/255, alpha: 1.0),     //#e16262   red
                        UIColor(red: 229/255, green: 168/255, blue: 78/255, alpha: 1.0),    //#e5a84e   yellow
                        UIColor(red: 58/255, green: 150/255, blue: 121/255, alpha: 1.0),    //#3a9679   green
                        UIColor(red: 83/255, green: 120/255, blue: 232/255, alpha: 1.0),    //#5378e8   blue
                        UIColor(red: 133/255, green: 59/255, blue: 175/255, alpha: 1.0),    //#853baf   purple
                       ]
    
    let sequencerColumnLayout = ColumnFlowLayout(
        cellsPerRow: 8,
        cellsPerColumn: 5,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    let laneBarColumnLayout = ColumnFlowLayout(
        cellsPerRow: 1,
        cellsPerColumn: 5,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    )
    
    let soundChoiceColumnLayout = ColumnFlowLayout(
        cellsPerRow: 1,
        cellsPerColumn: 5,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    //somehow setting this to true correctly forces the view to be landscape only, idk why.
    
    @IBAction func changedTab(_ sender: Any) {
        soundPickerLeftTable.reloadData()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    @IBAction func AddPresetSounds(_ sender: Any) {
        let presetKick = Recording(filepath: "bass.m4a", creation_date: Date(), name: "kick preset", duration: 10, start_time: 0, category: DrumType.bass)
        let presetSnare = Recording(filepath: "snare.m4a", creation_date: Date(), name: "snare preset", duration: 10, start_time: 0, category: DrumType.snare)
        let presetHat = Recording(filepath: "hat.m4a", creation_date: Date(), name: "hat preset", duration: 10, start_time: 0, category: DrumType.hat)
        
        beat.setSound(laneIndex: 0, recording: presetKick)
        beat.setSound(laneIndex: 1, recording: presetSnare)
        beat.setSound(laneIndex: 2, recording: presetHat)
        
        soundChoiceCollectionView.reloadData()
        laneBarCollectionView.reloadData()
        //samplers = beat.prepareSequencer(sequencer: sequencer)

    }
    @IBAction func playBeat(_ sender: Any) {
        if conductor.isPlaying == true  {
            print("pausing beat...")
            conductor.pauseBeat(cursorConstraint: playCursorX)
            //beat.stopPlaying(sequencer: sequencer)
            playButton.setTitle("\u{f144}", for: .normal )

        }
        else {
            print("playing beat...")
            //beat.startPlaying(sequencer: sequencer)
            /*UIView.animate( withDuration: 4.0) {
                self.playCursorX.constant += 200
            }*/
            print("sequencer width: ", sequencerCollectionView.frame.size.width)
            
            print("starting cursor constraint: ", playCursorX.constant)
            conductor.playPattern(beat: beat, looping: true, cursorConstraint: playCursorX, sequencerWidth: sequencerCollectionView.frame.size.width)
            playButton.setTitle("\u{f28b}", for: .normal )
        }
    }
    
    
    @IBAction func changeBPM(_ sender: Any) {
        let alert = UIAlertController(title: "Change BPM", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "\(self.beat.bpm)"
        }
        
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak alert] (_) in
            if let newBPM = Int(alert?.textFields?.first?.text ?? "120") {
                self.beat.bpm = newBPM
                self.bpmButton.setTitle("BPM: " + "\(newBPM)", for: .normal)
            }
                
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func returnClick(_ sender: Any) {
        if newBeat {
            let alert = UIAlertController(title: "Name your beat", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = "new beat"
            }
            
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
                self.beat.name = alert?.textFields?.first?.text ?? "new beat"
                self.performSegue(withIdentifier: "unwindSave", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
          performSegue(withIdentifier: "unwindSave", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == sequencerCollectionView {
            if(!conductor.isPlaying) {
                beat.toggleCellActivation(index: indexPath.row, bar: 0)
                sequencerCollectionView.reloadData()
            }
        }
        if collectionView == soundChoiceCollectionView {
            if selectedRecording != nil {
                beat.lanes[indexPath.row].setRecording(recording: selectedRecording!)
                conductor.preparePlayers(beat: beat)
                soundChoiceCollectionView.reloadData()
                laneBarCollectionView.reloadData()
            }
        }
        if collectionView == laneBarCollectionView {
            conductor.playLane(index: indexPath.row)
        }
    }
    
    func printFileDescription(file: AKAudioFile) {
        print("name: ", file.fileName)
        print("duration: ", file.duration)
        print("ext: ", file.fileExt)
        print("url: ", file.url)

        print("debug desc: ", file.debugDescription)

        print("Export format: ", file.fileFormat)
        print("Format settings: ", file.fileFormat.settings)
        print("is standard: ", file.fileFormat.isStandard)


    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sequencerCollectionView  {
            return beat.lanes.count * beat.cellPerRow
        }
        else {
            return beat.lanes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == sequencerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomSequencerCell
            //print("index path: ", indexPath)
            
            if beat.isCellActive(index: indexPath.row, bar: 0){
                cell.backgroundColor = laneColors[ indexPath.row / (beat.cellPerRow) ]
            }
            else {
                cell.backgroundColor = (laneColors[ indexPath.row / (beat.cellPerRow) ]).withAlphaComponent(0.15)
                //cell.backgroundColor = .lightGray
            }
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            return cell
        }
        else if collectionView == laneBarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "laneCell", for: indexPath) as! CustomLaneBarCell
            cell.backgroundColor =  laneColors[ indexPath.row ]
            if beat.lanes[indexPath.row].recording != nil {
                cell.hasSoundLabel.text = "\u{f1c7}"
            }
            else {
                cell.hasSoundLabel.text = "\u{f146}"
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pickedSoundCell", for: indexPath) as! CustomLaneBarCell
            if beat.lanes[indexPath.row].recording != nil {
                cell.backgroundColor = laneColors[ indexPath.row ]
                cell.hasSoundLabel.text = beat.lanes[indexPath.row].recording!.name
                //conductor.setupMidiSampler(filepath: samplers[indexPath.row].audioFiles[0].fileNamePlusExtension)
                //samplers[indexPath.row].audioFiles[0]
            } else {
                cell.backgroundColor = (laneColors[ indexPath.row ]).withAlphaComponent(0.15)
                cell.hasSoundLabel.text = "No recording selected"
                cell.hasSoundLabel.textColor = .white
            }
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            return cell
        }
        
    }
    
    
    @IBAction func addLane(_ sender: Any) {
        beat.addLane()
        sequencerCollectionView.reloadData()
        laneBarCollectionView.reloadData()
        soundChoiceCollectionView.reloadData()
    }
    private func initializeGestures() {
        //code from tutorial https://www.codevscolor.com/ios-adding-swipe-gesture-to-a-view-in-swift-4/
        let left = UISwipeGestureRecognizer(target : self, action : #selector(self.leftSwipeOnLane))
        left.direction = .left
        self.laneBarView.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(self.rightSwipeOnLane))
        right.direction = .right
        self.laneBarView.addGestureRecognizer(right)
        
    }
    
    @objc private func leftSwipeOnLane() {
        print("swiped left")
        let toMove = Constants.Screen.safeHeight - self.laneBarView.frame.width
        //print(toMove)
        
        let laneCurrentPosition = self.laneBarView.layer.position
        let rightCurrentPosition = self.rightOfLaneView.layer.position
        let leftCurrentPosition = self.leftOfLaneView.layer.position
        let topCurrentPosition = self.topView.layer.position
        
        UIView.animate(withDuration: 0.4, animations: {
            self.laneBarView.layer.position = CGPoint(x: laneCurrentPosition.x - toMove, y: laneCurrentPosition.y)
            self.rightOfLaneView.layer.position = CGPoint(x: rightCurrentPosition.x - toMove, y: rightCurrentPosition.y)
            //
            self.leftOfLaneView.layer.position = CGPoint(x: leftCurrentPosition.x - toMove, y: leftCurrentPosition.y)
            //
            self.topView.layer.position = CGPoint(x: topCurrentPosition.x - (toMove / 2), y: topCurrentPosition.y)
            self.view.layoutIfNeeded()
        }, completion: {finished in
            self.playCursor.isHidden = false
        })
    }
    
    @objc private func rightSwipeOnLane() {
        print("swiped right")
        playCursor.isHidden = true
        
        let toMove = Constants.Screen.safeHeight - self.laneBarView.frame.width
        //print(toMove)
        
        
        let laneCurrentPosition = self.laneBarView.layer.position
        let rightCurrentPosition = self.rightOfLaneView.layer.position
        let leftCurrentPosition = self.leftOfLaneView.layer.position
        let topCurrentPosition = self.topView.layer.position
        
        UIView.animate(withDuration: 0.4) { 
            self.laneBarView.layer.position = CGPoint(x: laneCurrentPosition.x + toMove, y: laneCurrentPosition.y)
            self.rightOfLaneView.layer.position = CGPoint(x: rightCurrentPosition.x + toMove, y: rightCurrentPosition.y)
            
            //to change back animation so that the left view slides in instead of being static,
            //uncomment the line below and the same line in leftSwipeOnLane()
            //and change the constraint in Main.storyboard. It does have the bug where the left
            //table's cell labels are misaligned but it's not a big deal.
//            
            self.leftOfLaneView.layer.position = CGPoint(x: leftCurrentPosition.x + toMove, y: leftCurrentPosition.y)
//            
            self.topView.layer.position = CGPoint(x: topCurrentPosition.x + (toMove / 2), y: topCurrentPosition.y)
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == soundPickerLeftTable  {
            let categoryIndex = categoryTab.selectedSegmentIndex
            return recordings[categoryIndex].count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryIndex = categoryTab.selectedSegmentIndex
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell", for: indexPath) as! RecordingTableViewCell
        //cell.playButtonRight.addTarget(self, action: #selector(self.tappedPlayButton(sender:)), for: .touchUpInside)
        
        cell.recordingName?.text = recordings[categoryIndex][indexPath.row].name
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
//        selectedIndexPath = indexPath
//        let cell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
//        cell.playButtonRight.isHidden = true;
//        myTableView.beginUpdates()
//        myTableView.endUpdates()
        
        
        if tableView == soundPickerLeftTable {
            let categoryIndex = categoryTab.selectedSegmentIndex
            //let cell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
//            soundPickerLeftTableSelectedIndex = indexPath
//            cell.backgroundColor = UIColor.yellow
            
            selectedRecording = recordings[categoryIndex][indexPath.row]
            print("selected recording: " + (selectedRecording?.name ?? "uh oh nil selectedRecording"))
            
            //play audio of recording
            print("attempting to play recording")
            //conductor.playRecording(filePath: recordings[categoryIndex][indexPath.row].filepath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
//        cell.playButtonRight.isHidden = false;
//        myTableView.beginUpdates()
//        myTableView.endUpdates()
        
        if tableView == soundPickerLeftTable {
//            let categoryIndex = categoryTab.selectedSegmentIndex
            //let cell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
//            soundPickerLeftTableSelectedIndex = nil
//            cell.backgroundColor = UIColor.white
            print("deselected recording: " + (selectedRecording?.name ?? "uh oh nil deselectedRecording"))
            selectedRecording = nil

        }
    }
    
    @objc func tappedPlayButton(sender: UIButton) {

        }
    
    
    func loadRecordings () {
        var bassRecordings:[Recording]!
        var snareRecordings:[Recording]!
        var hatRecordings:[Recording]!
        
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
        
        recordings = [bassRecordings, snareRecordings, hatRecordings]
    }


//    override var prefersHomeIndicatorAutoHidden: Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load called...")
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        initializeGestures()
        loadRecordings()
       
        sequencerCollectionView?.collectionViewLayout = sequencerColumnLayout
        laneBarCollectionView?.collectionViewLayout = laneBarColumnLayout
        soundChoiceCollectionView?.collectionViewLayout = soundChoiceColumnLayout
        
        laneBarCollectionView.layer.borderWidth = 5.0;
        laneBarCollectionView.layer.borderColor = UIColor.darkGray.cgColor
        
        bpmButton.setTitle("BPM: " + "\(beat.bpm)", for: .normal)
        titleLabel.text = beat.name
        
        soundPickerLeftTable.backgroundColor = .darkGray
        soundPickerLeftTable.tableFooterView = UIView()
        
        //samplers = beat.prepareSequencer(sequencer: sequencer)
        
        print("preparing to copy files to documents folder...")

        //copy presets to documents folder
        FileUtilities.copyFileToDocuments(resource: "bass", type: ".m4a")
        FileUtilities.copyFileToDocuments(resource: "snare", type: ".m4a")
        FileUtilities.copyFileToDocuments(resource: "hat", type: ".m4a")

        
        print("preparing to print documents files...")
        
        let fileManager = FileManager.default

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(fileURLs)
            // process files
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        print("conductor number of players: ", conductor.players.count)
        conductor.preparePlayers(beat: beat)
        //print("beat rec #1: ", beat.lanes[0].recording?.name)
        //print("beat rec #2: ", beat.lanes[1].recording?.name)
        //print("beat rec #3: ", beat.lanes[2].recording?.name)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (newBeat) {
            rightSwipeOnLane()
        }
    }

}
