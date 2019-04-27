//
//  SoundPickerViewController.swift
//  Drumify
//
//  Created by Vernon Chan on 4/12/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit
import AudioKit

class SoundPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var rightOfLaneView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var laneBarView: UIView!
    @IBOutlet weak var leftOfLaneView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var velocityModeButton: UIButton!
    @IBOutlet weak var bpmButton: UIButton!
    
    @IBOutlet weak var sequencerCollectionView: UICollectionView!
    @IBOutlet weak var laneBarCollectionView: UICollectionView!
    
    @IBOutlet weak var soundPickerLeftTable: UITableView!
    @IBOutlet weak var soundPickerRightTable: UITableView!
    @IBOutlet weak var categoryTab: UISegmentedControl!
    
    var recordings:[[Recording]]!

    var beat:Beat!
    var newBeat:Bool=false
    var beatNumber:Int=0
    var sequencer:AKSequencer = AKSequencer()
    
    let laneColors = [UIColor.red,UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
    
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
    
    @IBAction func playBeat(_ sender: Any) {
        if sequencer.isPlaying  {
            beat.stopPlaying(sequencer: sequencer)
            playButton.setTitle("\u{f04b}", for: .normal )

        }
        else {
            beat.startPlaying(sequencer: sequencer)
            playButton.setTitle("\u{f0c8}", for: .normal )
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
            beat.toggleCellActivation(index: indexPath.row, bar: 0)
            sequencerCollectionView.reloadData()
            beat.prepareSequencer(sequencer: sequencer)
        }
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
                cell.backgroundColor = .gray
            }
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "laneCell", for: indexPath) as! CustomSequencerCell
            cell.backgroundColor = .blue
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            return cell
        }
        
    }
    
    
    @IBAction func addLane(_ sender: Any) {
        beat.addLane()
        sequencerCollectionView.reloadData()
        laneBarCollectionView.reloadData()
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
    
    //note: the 617 value for movement is hard-coded to work with iPhone 8 sized screens (for now).
    @objc private func leftSwipeOnLane() {
        print("swiped left")
        
        let height = Constants.Screen.height
        print(height)
        
        
        let laneCurrentPosition = self.laneBarView.layer.position
        let rightCurrentPosition = self.rightOfLaneView.layer.position
        let leftCurrentPosition = self.leftOfLaneView.layer.position
        let topCurrentPosition = self.topView.layer.position
        
        UIView.animate(withDuration: 0.4) { 
            self.laneBarView.layer.position = CGPoint(x: laneCurrentPosition.x - height, y: laneCurrentPosition.y)
            self.rightOfLaneView.layer.position = CGPoint(x: rightCurrentPosition.x - height, y: rightCurrentPosition.y)
            self.leftOfLaneView.layer.position = CGPoint(x: leftCurrentPosition.x - height, y: leftCurrentPosition.y)
            self.topView.layer.position = CGPoint(x: topCurrentPosition.x - (height / 2 - 5), y: topCurrentPosition.y)
            
        }
    }
    
    @objc private func rightSwipeOnLane() {
        print("swiped right")
        
        let height = Constants.Screen.height
        print(height)
        
        
        let laneCurrentPosition = self.laneBarView.layer.position
        let rightCurrentPosition = self.rightOfLaneView.layer.position
        let leftCurrentPosition = self.leftOfLaneView.layer.position
        let topCurrentPosition = self.topView.layer.position
        
        UIView.animate(withDuration: 0.4) { 
            self.laneBarView.layer.position = CGPoint(x: laneCurrentPosition.x + height, y: laneCurrentPosition.y)
            self.rightOfLaneView.layer.position = CGPoint(x: rightCurrentPosition.x + height, y: rightCurrentPosition.y)
            self.leftOfLaneView.layer.position = CGPoint(x: leftCurrentPosition.x + height, y: leftCurrentPosition.y)
            self.topView.layer.position = CGPoint(x: topCurrentPosition.x + (height / 2 - 5), y: topCurrentPosition.y)
            
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
        
        return cell
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        initializeGestures()
        loadRecordings()
       
        sequencerCollectionView?.collectionViewLayout = sequencerColumnLayout
        laneBarCollectionView?.collectionViewLayout = laneBarColumnLayout
        
        bpmButton.setTitle("BPM: " + "\(beat.bpm)", for: .normal)
        titleLabel.text = beat.name
        
        beat.prepareSequencer(sequencer: sequencer)
        beat.printContents()
        //UIViewController.attemptRotationToDeviceOrientation()
        // Do any additional setup after loading the view.
    }

}
