//
//  CustomLaneBarCell.swift
//  Drumify
//
//  Created by Jackson Kurtz on 4/28/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class CustomLaneBarCell: UICollectionViewCell {
    
    
    @IBOutlet weak var hasSoundLabel: UILabel!
    override init(frame: CGRect) {
        super.init( frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
