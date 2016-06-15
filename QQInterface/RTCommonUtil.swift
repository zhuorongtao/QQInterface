//
//  RTCommonUtil.swift
//  QQInterface
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class RTCommonUtil: NSObject {
    /**
     将view转为image
     
     - parameter view: 需要转换的view
     
     - returns: view转化为image
     */
    static func getImageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
     获取随机颜色
     
     - returns: 随机颜色
     */
    static func getRandomColor() -> UIColor {
        return UIColor(red: CGFloat((1 + arc4random() % 99) / 100), green: CGFloat((1 + arc4random() % 99) / 100), blue: CGFloat((1 + arc4random() % 99) / 100), alpha: CGFloat((1 + arc4random() % 99) / 100))
    }
    
    /**
     根据比例（0...1）在min和max中取值
     
     - parameter percent: 所在范围的百分值
     - parameter nMin:    最小的范围
     - parameter nMax:    最大的范围
     
     - returns: 根据比例(百分比)在在min和max中的值
     */
    static func lerp(percent: Float, min nMin: Float, max nMax: Float) -> Float {
        var result = nMin
        result = nMin + percent * (nMax - nMin)
        return result
    }
    
    /**
     解压zip文件
     
     - parameter fileName: 解压zip的包名
     */
    static func unzipFileToDocument(fileName: String) {
        RTCommonUtil.moveFileToDocument(fileName, type: "zip")
    }
    
    static func moveFileToDocument(fileName: String, type fileType: String) {
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath2 = (documentsDirectory as NSString).stringByAppendingPathComponent((fileName as NSString).stringByAppendingPathExtension(fileType)!)
        let pathFold = (filePath2 as NSString).stringByDeletingPathExtension
        let path = (filePath2 as NSString).stringByDeletingLastPathComponent
        
        let manager = NSFileManager.defaultManager()
        
        if !(manager.fileExistsAtPath(pathFold)) {
            //判断是否移动成功, 这里文件不能存在的
            do {
                try NSFileManager.defaultManager().copyItemAtPath(filePath!, toPath: filePath2)
            }catch let error {
                RTLog("move fail...")
                RTLog("Unable to move file: \(error)")
            }
            
            let archive = ZipArchive()
            if archive.UnzipOpenFile(filePath2) {
                let ret = archive.UnzipFileTo(path, overWrite: true)
                if ret == false {
                    RTLog("unzip Fail")
                }
                archive.UnzipCloseFile()
            }
            do {
                try manager.removeItemAtPath(filePath2)
            }catch let error {
                RTLog("unzip remove faile: \(error)")
            }
        }
    }
    
    /**
     根据图片名获取解压的图片, 若不存在旧选择目录下的图片
     
     - parameter name: 图片名
     
     - returns: 指定的图片
     */
    static func imageNamed(name: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        var image: UIImage?
        let config = RTConfiguredObj.defaultConfigure()
        if (config.themefold != "") && ((config.themefold as NSString).length > 0) {
            let path = ((documentsDirectory as NSString).stringByAppendingPathComponent(config.themefold) as NSString).stringByAppendingPathComponent(name)
            image = UIImage(contentsOfFile: path)
        }
        if image == nil {
            image = UIImage(named: name)
        }
        
        return image
    }
}
