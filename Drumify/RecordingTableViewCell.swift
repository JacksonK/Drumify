//
//  RecordingTableViewCell.swift
//  Drumify
//
//  Created by Vernon Chan on 2/19/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var playbackProgressView: UIProgressView!
    
    
    
    @IBAction func playRecording(_ sender: UIButton) {
        /*
        let cell = sender.superview?.superview as! UITableViewCell
        let tableView = cell.superview as! UITableView
        let view = tableView.superview as! UIView
        if let viewController = view.superview! as? ViewController {
            
        }
         */
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}