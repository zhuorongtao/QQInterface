//
//  UIView+RTViewExtend.swift
//  QQInterface
//
//  Created by apple on 16/2/28.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

extension UIView {
    /// 设置view的x坐标
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    /// 设置view的y坐标
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    /// 设置view的右坐标
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.width
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }
    
    /// 设置view底边坐标
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }
    
    /// 设置view的中心X坐标
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPointMake(newValue, self.center.y)
        }
    }
    
    /// 设置view的中心Y坐标
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPointMake(self.center.x, newValue)
        }
    }
    
    /// 设置view的width属性
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    /// 设置view的height属性
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
}
