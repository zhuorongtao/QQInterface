//
//  RectViewForMessage.swift
//  QQInterface
//
//  Created by apple on 16/3/4.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

@objc protocol RectViewForMessageDelegate {
    optional func press(rectView: RectViewForMessage, index nIndex: CGFloat)
}

class RectViewForMessage: UIView {
    
    /// 是否显示该列表选项栏分割线
    private var bSpera: Bool        = false
    /// 创建多少个选项
    private var nSumOfLine: CGFloat = 0
    private var arData: NSArray     = []
    private var bgName: String      = ""
    
    var delegate: RectViewForMessageDelegate?
    
    //MARK: - 初始化函数
    init(frame: CGRect, sumOfLine nSumLine: CGFloat = 0) {
        nSumOfLine = nSumLine + 1
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, ar arData: NSArray, showSpera bSpera: Bool, bg bgName: String) {
        self.arData     = arData
        self.nSumOfLine = CGFloat(arData.count)
        self.bSpera     = bSpera
        self.bgName     = bgName
        super.init(frame: frame)
        self.createLabel()
    }
    
    private func createLabel() {
        self.backgroundColor = UIColor.whiteColor()
        let imageBg          = RTCommonUtil.imageNamed(bgName)
        let imageIVBg        = UIImageView(frame: self.bounds)
        imageIVBg.tag        = 32
        imageIVBg.image      = imageBg
        self.addSubview(imageIVBg)
        
        let nW = self.width / nSumOfLine//每个选项的宽
        let nH = self.height / 6//每个选项的高
        let nIR = min(nW, nH * 3)//每个选项图片的宽与高
        
        //根据数组中的元素分别创建选项
        arData.enumerateObjectsUsingBlock { (obj, idx, _) -> Void in
            let image = RTCommonUtil.imageNamed((obj as! NSArray).objectAtIndex(1) as! String) //获取图片的名称
            let imageIV = UIImageView(frame: CGRectMake(CGFloat(idx) * nW + (nW - nIR) / 2, nH, nIR, nIR))
            imageIV.image = image
            imageIV.tag = idx + 33
            self.addSubview(imageIV)
            
            let t = UILabel(frame: CGRectMake(CGFloat(idx) * nW, imageIV.bottom, nW - 1, nH * 2))
            t.textAlignment = .Center
            t.font = UIFont.systemFontOfSize(13)
            t.text = (obj as! NSArray).objectAtIndex(0) as? String //获取图片标题的名称
            self.addSubview(t)
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if bSpera {
            let nWidth  = self.width / nSumOfLine
            let nHeight = self.height
            for var i: CGFloat = 1; i < nSumOfLine; i++ {
                let context = UIGraphicsGetCurrentContext()
                CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
                let point = UnsafeMutablePointer<CGPoint>(malloc(sizeof(CGPoint) * 2))
                point[0] = CGPointMake(i * nWidth, 0)
                point[1] = CGPointMake(i * nWidth, nHeight)
                CGContextBeginPath(context)
                CGContextAddLines(context, point, 2)
                CGContextClosePath(context)
                CGContextStrokePath(context)
//                point.destroy()
//                point.dealloc(1)
                free(point)
            }
        }
    }

    func reloadMenuImage() {
        if bgName != "" {
            let imageBg = RTCommonUtil.imageNamed(bgName)
            let imageIV = self.viewWithTag(32) as! UIImageView
            imageIV.image = imageBg
        }
        
        //根据数组中的元素分别创建选项
        arData.enumerateObjectsUsingBlock { (obj, idx, _) -> Void in
            let image = RTCommonUtil.imageNamed((obj as! NSArray).objectAtIndex(1) as! String)
            let imageIV = self.viewWithTag(idx + 33) as! UIImageView
            imageIV.image = image
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if let touchLocation = touch?.locationInView(self) {
            let nWidth = self.width / nSumOfLine
            let index = touchLocation.x / nWidth
            delegate?.press?(self, index: index)
        }
    }
}
