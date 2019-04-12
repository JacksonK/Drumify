//
//  BeatViewController.swift
//  Drumify
//
//  Created by Jackson Kurtz on 3/16/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class BeatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var beatTableView: UITableView!
    
    var beats:[Beat]!

    //somehow setting this to true correctly forces the view to be landscape only, idk why.
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "beatCell", for: indexPath) as! BeatTableViewCell
        cell.nameLabel?.text = beats[indexPath.row].name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.dateLabel?.text = dateFormatter.string(from: beats[indexPath.row].date)
        cell.measuresLabel?.text = "\(beats[indexPath.row].measures)"
        cell.bpmLabel?.text = "\(beats[indexPath.row].bpm)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        beats = []
        //beats.append(Beat(name:"Hip-Hop Beat", date:Date(), measures:32, bpm:90))
        //beats.append(Beat(name:"Lo-fi House Beat", date:Date(), measures:64, bpm:110))
        //beats.append(Beat(name:"All Hand Sounds Beat", date:Date(), measures:16, bpm:100))
        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindFromSoundPicker (_ sender: UIStoryboardSegue) {
    
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
