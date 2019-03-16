//
//  RecordingTableViewCell.swift
//  Drumify
//
//  Created by Vernon Chan on 2/19/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recordingName: UILabel!
    @IBOutlet weak var playbackProgressView: UIProgressView!
    @IBOutlet weak var playButtonBottom: UIButton!
    @IBOutlet weak var playButtonRight: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
