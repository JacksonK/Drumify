//
//  SoundPickerViewController.swift
//  Drumify
//
//  Created by Vernon Chan on 4/12/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class SoundPickerViewController: UIViewController {

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
    
    @IBOutlet weak var laneBarView: UIView!
    @IBOutlet weak var rightOfLaneView: UIView!
    @IBOutlet weak var leftOfLaneView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        initializeGestures()
        
        //UIViewController.attemptRotationToDeviceOrientation()
        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
