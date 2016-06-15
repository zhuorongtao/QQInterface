//
//  FxGlobal.swift
//  Uber
//
//  Created by apple on 16/1/9.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit

func RTLog(message: String, function: String = __FUNCTION__) {
    //在Build Setting中的Other Swif Flags增加-D DEBUG
//    #if DEBUG
        print("Log: \(message), \(function)")//__FUNCTION__标示哪个函数输出的日志
//    #else
//        
//    #endif
}

func RGBA(R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) -> UIColor {
    return UIColor(red: R / 255, green: G / 255, blue: B / 255, alpha: A)
}

func isIos7() -> Float {
    let version = UIDevice.currentDevice().systemVersion
    RTLog(version)
    return Float(version)!
}

let isIOS7: Float = Float(UIDevice.currentDevice().systemVersion)!

let statusbarSize = CGFloat((isIos7() >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1) ? 20 : 0)

let RELOADIMAGE = "reloadImage"
//func isIPhone5() -> Bool {
//    if screenHeight == 568 {
//        return true
//    }
//    
//    return false
//}
//
//func isSystemLowIOS8() -> Bool {
//    let device = UIDevice.currentDevice()
//    let systemVer = Float(device.systemVersion)
//    if let version = systemVer {
//        if (version - IOSBaseVersion8 < -0.001) {
//            return true;
//        }
//        return false;
//    }else {
//        print("系统版本号\(systemVer)")
//        return false
//    }
//}