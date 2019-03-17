//
//  AddRecordingModalViewController.swift
//  Drumify
//
//  Created by Vernon Chan on 3/12/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class AddRecordingModalViewController: UIViewController/*, UITextFieldDelegate*/ {
    var recording: Recording!
    var callerInstance: ViewController!
    var filepath: String!
    var filename: String!
    var suggested_category:DrumType!
    var chosen_category:DrumType?
    /*
    @IBAction func renameFinished(_ sender: UITextField) {
        recordingTitle = sender.text!
        print (sender.text!)
    }
    */
    @IBOutlet weak var filenameTextField: UITextField!
    @IBOutlet weak var drumCategorySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        filenameTextField.placeholder = "recording " + getTodayString()
        filename = filenameTextField.placeholder
                
        saveButton.layer.cornerRadius = saveButton.frame.height/2
        
        deleteButton.layer.cornerRadius = deleteButton.frame.height/2
        deleteButton.layer.borderWidth = Constants.RoundedButton.borderWidth
        deleteButton.layer.borderColor = UIColor.white.cgColor
        
        //sets selected category to the analysis value
        chosen_category = suggested_category
        
        if DrumType.bass == suggested_category {
            drumCategorySegmentedControl.selectedSegmentIndex = 0
        }
        else if DrumType.snare == suggested_category {
            drumCategorySegmentedControl.selectedSegmentIndex = 1
        }
        else if DrumType.hat == suggested_category {
            drumCategorySegmentedControl.selectedSegmentIndex = 2
        }
        // catorization failed, uncategorized
        else {
            drumCategorySegmentedControl.selectedSegmentIndex = 0
        }
    }
    @IBAction func pickedCategory(_ sender: Any) {
        print("category picked, updating global category variable")
        if drumCategorySegmentedControl.selectedSegmentIndex == 0 {
            chosen_category = DrumType.bass
        }
        else if drumCategorySegmentedControl.selectedSegmentIndex == 1 {
            chosen_category = DrumType.snare
        }
        else if drumCategorySegmentedControl.selectedSegmentIndex == 2 {
            chosen_category = DrumType.hat
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
    
    //function from
    //https://stackoverflow.com/questions/43199635/get-current-time-as-string-swift-3-0
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)

        
        return today_string
        
    }
}

