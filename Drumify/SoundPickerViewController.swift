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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        //UIViewController.attemptRotationToDeviceOrientation()
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
