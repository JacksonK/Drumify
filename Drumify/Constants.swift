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
//        
//        static let safeHeight = height - 
//            ((UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) * 2) -
//            ((UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) * 2)
        static let window = UIApplication.shared.keyWindow
        static let leftPadding = window?.safeAreaInsets.left ?? 0
        static let rightPadding = window?.safeAreaInsets.right ?? 0
        
        static let safeHeight = height - leftPadding - rightPadding
        
    }
}
