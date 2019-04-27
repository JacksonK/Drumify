//
//  Constants.swift
//  Drumify
//
//  Created by Vernon Chan on 3/13/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import UIKit

struct Constants {
    struct RoundedButton {
        static let cornerRadius:CGFloat = 20
        static let borderWidth:CGFloat = 1
    }
    
    struct Analysis {
        static let TimerRate = 0.008
        static let Offset = 0.01
        static let MaxSnapshots = 4
        static let SampleRate:double_t = 44100
        static let FFTSize = 512

        //[43 86 172 344 689 1378 2756 5512 11025] -> hz values for each of the 9 bins
        static let BassBinLimit = 3 
        static let HatBinLimit = 5
    }
    
    struct Screen {
        static let width = UIScreen.main.fixedCoordinateSpace.bounds.width
        static let height = UIScreen.main.fixedCoordinateSpace.bounds.height
    }
}
