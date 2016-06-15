//
//  SelectThemeCollectionViewCell.swift
//  QQInterface
//
//  Created by apple on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class SelectThemeCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.contentView.frame = CGRectMake(5, 0, self.width, self.height)
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.cornerRadius = 6
        self.contentView.layer.borderColor = UIColor.grayColor().CGColor
        
        let w = self.height / 5
        let wIV = w * 4
        
        //主题图片
        let titleIV = UIImageView(frame: CGRectMake(0, 0, self.contentView.width, wIV))
        titleIV.backgroundColor = UIColor.clearColor()
        titleIV.tag = 11
        self.contentView.addSubview(titleIV)
        
        //主题标题
        let titleL = UILabel(frame: CGRectMake(0, titleIV.bottom, self.contentView.width, self.contentView.height - titleIV.bottom))
        titleL.tag = 12
        self.contentView.addSubview(titleL)
        
        //主题被选择的图片
        let i = UIImage(named: "common_green_checkbox")
        let selectIV = UIImageView(frame: CGRectMake(self.contentView.width - titleL.height - 5, titleL.top, titleL.height, titleL.height))//位于主题的右下方
        selectIV.image = i
        selectIV.tag = 13
        self.contentView.addSubview(selectIV)
    }
    
    /**
    改变主题被选中的图标(也就是使被选中的图标selectIV显示而已)
     
     - parameter ar:        标题以及图标名
     - parameter bSelected: 选中的状态
     */
    func setDataForView(ar: NSArray, selected bSelected: Bool) {
        let titleIV = self.contentView.viewWithTag(11) as? UIImageView
        titleIV?.image = UIImage(named: ar[2] as! String)
        
        let titleL = self.contentView.viewWithTag(12) as? UILabel
        titleL?.textAlignment = .Center
        titleL?.text = ar.objectAtIndex(0) as? String
        
        let selectIV = self.contentView.viewWithTag(13) as? UIImageView
        selectIV?.hidden = !bSelected
    }
    
    /**
     改变主题被选中的图标(也就是使被选中的图标selectIV显示而已)
     
     - parameter ar:        标题以及图标名
     - parameter indexPath: 选中的位置
     */
    func setDataForView(ar: NSArray, index indexPath: NSIndexPath) {
        if RTConfiguredObj.defaultConfigure().nThemeIndex == indexPath.row {
            self.setDataForView(ar, selected: true)
        }else {
            self.setDataForView(ar, selected: false)
        }
    }
}
