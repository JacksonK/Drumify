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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "existingBeat", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "beatCell", for: indexPath) as! BeatTableViewCell
        cell.nameLabel?.text = beats[indexPath.row].name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.dateLabel?.text = dateFormatter.string(from: beats[indexPath.row].date)
        cell.measuresLabel?.text = "bars: \(beats[indexPath.row].measures)"
        cell.bpmLabel?.text = "bpm: \(beats[indexPath.row].bpm)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func saveBeats() {
        do {
            let encodedBeats = try PropertyListEncoder().encode(self.beats)
            
            UserDefaults.standard.set(encodedBeats, forKey: "beats")
        }
        catch {
            print("error encoding beats in beat view controller!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        beats = []
        
        //decode beat data
        if let beatData = UserDefaults.standard.value(forKey:"beats") as? Data {
            beats = try? PropertyListDecoder().decode([Beat].self, from:beatData)
        }
        else { beats = [] }
        
        //beats.append(Beat(name:"Hip-Hop Beat", date:Date(), measures:32, bpm:90))
        //beats.append(Beat(name:"Lo-fi House Beat", date:Date(), measures:64, bpm:110))
        //beats.append(Beat(name:"All Hand Sounds Beat", date:Date(), measures:16, bpm:100))
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newBeat") {
            let sequencerViewController = segue.destination as! SequencerViewController
            sequencerViewController.newBeat = true
            sequencerViewController.beat = Beat(name: "new beat", cellPerRow: 8)
            
            /*
            //sample recordings
            let testKick = Recording(filepath: "bass", creation_date: Date(), name: "kick", duration: 10, start_time: 0, category: DrumType.bass)
            let testSnare = Recording(filepath: "snare", creation_date: Date(), name: "snare", duration: 10, start_time: 0, category: DrumType.snare)
            let testHat = Recording(filepath: "hat", creation_date: Date(), name: "hat", duration: 10, start_time: 0, category: DrumType.hat)

            sequencerViewController.beat.setSound(laneIndex: 0, recording: testKick)
            sequencerViewController.beat.setSound(laneIndex: 1, recording: testSnare)
            sequencerViewController.beat.setSound(laneIndex: 2, recording: testHat)*/

        }
        if(segue.identifier == "existingBeat") {
            let sequencerViewController = segue.destination as! SequencerViewController
            sequencerViewController.newBeat = false
            let row = (sender as! NSIndexPath).row;
            sequencerViewController.beat = beats[row]
            sequencerViewController.beatNumber = row
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            deleteBeat(at: indexPath)
        }
    }
    
    func deleteBeat(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Are you sure you want to delete this Beat?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
            
            self.beats.remove(at: indexPath.row)
            self.saveBeats()
            self.beatTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindFromSoundPicker (_ sender: UIStoryboardSegue) {
        let sequencerViewController = sender.source as! SequencerViewController
        if sequencerViewController.newBeat {
            beats.append(sequencerViewController.beat)
            
        }
        // if existing beat, update the beat in the table with new changes
        else {
            beats[sequencerViewController.beatNumber] = sequencerViewController.beat
        }
        beatTableView.reloadData()
        saveBeats()
        
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
