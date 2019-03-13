//
//  AddRecordingModalViewController.swift
//  Drumify
//
//  Created by Vernon Chan on 3/12/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class AddRecordingModalViewController: UIViewController {
    var recording: Recording!
    var callerInstance: ViewController!
    var recordingTitle: String = "default"
    
    @IBAction func renameFinished(_ sender: UITextField) {
        recordingTitle = sender.text!
        print (sender.text!)
    }
    
    @IBAction func choseDrumCategory(_ sender: UISegmentedControl) {
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
