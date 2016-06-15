//
//  QHConfiguredObj.swift
//  QQInterface
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

let kTHEME_TAG = "selectTheme"
let kTHEMEFOLD_TAG = "selectThemeFold"

class RTConfiguredObj: NSObject {
    private var _nThemeIndex: Int = 0
    private var _themefold = ""
    
    
    var nThemeIndex: Int {
        get {
            return _nThemeIndex
        }
        set {
            _nThemeIndex = newValue
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(int: Int32(newValue)), forKey: kTHEME_TAG)
        }
    }
    
    var themefold: String {
        get {
            return _themefold
        }
        set {
            _themefold = newValue
            NSUserDefaults.standardUserDefaults().setObject(_themefold, forKey: kTHEMEFOLD_TAG)
        }
    }
    
    override init() {
        if let theme =  NSUserDefaults.standardUserDefaults().objectForKey(kTHEME_TAG) {
            if let index = theme as? Int {
                _nThemeIndex = index
            }
        }
        
        if let theme =  NSUserDefaults.standardUserDefaults().objectForKey(kTHEMEFOLD_TAG) {
            if let fold = theme as? String {
                _themefold = fold
            }
        }
        
        super.init()
    }
    
    /**
     获取RTConfiguredObj单例
     
     - returns: RTConfiguredObj单例
     */
    static func defaultConfigure() -> RTConfiguredObj {
        struct temps {
            static var configureObj: RTConfiguredObj?
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&temps.onceToken) { () -> Void in
            temps.configureObj = RTConfiguredObj()
        }
        return temps.configureObj!
    }
}
