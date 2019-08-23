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
    
    struct AppColors {
        static let red = UIColor(red: 225/255, green: 98/255, blue: 98/255, alpha: 1.0) //#e16262   red
        static let yellow = UIColor(red: 229/255, green: 168/255, blue: 78/255, alpha: 1.0) //#e5a84e   yellow
        static let green = UIColor(red: 58/255, green: 150/255, blue: 121/255, alpha: 1.0) //#3a9679   green
        static let blue =  UIColor(red: 83/255, green: 120/255, blue: 232/255, alpha: 1.0) //#5378e8   blue
        static let purple = UIColor(red: 229/255, green: 168/255, blue: 78/255, alpha: 1.0) //#853baf   purple
    }
}
