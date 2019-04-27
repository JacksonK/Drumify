//
//  CustomSequencerCell.swift
//  Drumify
//
//  Created by Jackson Kurtz on 4/12/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

class CustomSequencerCell: UICollectionViewCell {
    
    //var hasSoundLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init( frame : frame)
        //hasSoundLabel.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
        //hasSoundLabel.textAlignment =  .center
        //hasSoundLabel.text = "default"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
