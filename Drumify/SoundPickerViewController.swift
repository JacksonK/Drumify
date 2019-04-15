//
//  SoundPickerViewController.swift
//  Drumify
//
//  Created by Vernon Chan on 4/12/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class SoundPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var velocityModeButton: UIButton!
    @IBOutlet weak var bpmButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var laneBarView: UIView!
    @IBOutlet weak var rightOfLaneView: UIView!
    @IBOutlet weak var leftOfLaneView: UIView!
    
    @IBOutlet weak var sequencerCollectionView: UICollectionView!
    var beat:Beat!
    var newBeat:Bool=false
    var beatNumber:Int=0
    
    let laneColors = [UIColor.red,UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 8,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    //somehow setting this to true correctly forces the view to be landscape only, idk why.
    
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //let cell = collectionView.cellForItem(at: indexPath)
        
        beat.toggleCellActivation(index: indexPath.row, bar: 0)
        sequencerCollectionView.reloadData()
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beat.lanes.count * beat.cellPerRow
    }
    
    @IBAction func addLane(_ sender: Any) {
        beat.addLane()
        sequencerCollectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomSequencerCell
        print("index path: ", indexPath)
        
        
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
        
        let laneCurrentPosition = self.laneBarView.layer.position
        let rightCurrentPosition = self.rightOfLaneView.layer.position
        let leftCurrentPosition = self.leftOfLaneView.layer.position
        
        UIView.animate(withDuration: 0.4) { 
            self.laneBarView.layer.position = CGPoint(x: laneCurrentPosition.x - 617, y: laneCurrentPosition.y)
            self.rightOfLaneView.layer.position = CGPoint(x: rightCurrentPosition.x - 617, y: rightCurrentPosition.y)
            self.leftOfLaneView.layer.position = CGPoint(x: leftCurrentPosition.x - 617, y: leftCurrentPosition.y)
            
        }
    }
    
    @objc private func rightSwipeOnLane() {
        print("swiped right")
        
        let laneCurrentPosition = self.laneBarView.layer.position
        let rightCurrentPosition = self.rightOfLaneView.layer.position
        let leftCurrentPosition = self.leftOfLaneView.layer.position
        
        UIView.animate(withDuration: 0.4) { 
            self.laneBarView.layer.position = CGPoint(x: laneCurrentPosition.x + 617, y: laneCurrentPosition.y)
            self.rightOfLaneView.layer.position = CGPoint(x: rightCurrentPosition.x + 617, y: rightCurrentPosition.y)
            self.leftOfLaneView.layer.position = CGPoint(x: leftCurrentPosition.x + 617, y: leftCurrentPosition.y)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        initializeGestures()
        
        sequencerCollectionView?.collectionViewLayout = columnLayout
        
        bpmButton.setTitle("BPM: " + "\(beat.bpm)", for: .normal)
        titleLabel.text = beat.name
        //UIViewController.attemptRotationToDeviceOrientation()
        // Do any additional setup after loading the view.
    }

}
