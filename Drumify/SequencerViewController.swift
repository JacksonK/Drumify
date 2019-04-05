//
//  SequencerViewController.swift
//  
//
//  Created by Jackson Kurtz on 4/5/19.
//

import UIKit

class SequencerViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var beat:Beat!
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        beat = Beat(name: "test")
        titleLabel.text = beat.name
    }
}
