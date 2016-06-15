//
//  SelectThemeViewController.swift
//  QQInterface
//
//  Created by apple on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class SelectThemeViewController: RTBasicViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var collectionV: UICollectionView?
    private var arData: NSArray = []
    private var nSelectIndex: Int = 0
    
    func initData() {
        //数组: [[标题, 压缩包名, 图标] ...]
        arData = [
            ["默认", "", "theme_icon.png"],
            ["海洋", "com.skin.1110", "theme_icon_sea.png"],
            ["外星人", "com.skin.1114", "theme_icon_universe.png"],
            ["小黄鸭", "com.skin.1108", "theme_icon_yellowduck.png"],
            ["企鹅", "com.skin.1098", "theme_icon_penguin.png"]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserver()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.createNavWithTitle("主题商场") { (nIndex) -> UIView? in
            if nIndex == 1 {
                let btn = UIButton(type: .Custom)
                btn.frame = CGRectMake(10, (self.navView!.height - 40) / 2, 60, 40)
                btn.addTarget(self, action: "backAction:", forControlEvents: .TouchUpInside)
                let btnL = UILabel(frame: CGRectMake(10, 0, btn.width - 15, btn.height))
                btnL.text = "返回"
                btnL.textColor = UIColor.whiteColor()
                btn.addSubview(btnL)
                return btn
            }
            return nil
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        //主题选项设置
        flowLayout.itemSize = CGSizeMake(self.view.width / 2 - 5, 90)
        flowLayout.minimumInteritemSpacing = 0 //列距
        collectionV = UICollectionView(frame: CGRectMake(0, self.navView!.bottom + 10, self.view.width, self.view.height - self.navView!.bottom - 10), collectionViewLayout: flowLayout)
        collectionV?.registerClass(SelectThemeCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "colletionCell")
        collectionV?.backgroundColor = UIColor.clearColor()
        collectionV?.dataSource = self
        collectionV?.delegate = self
        self.view.addSubview(collectionV!)
        
        self.initData()
        collectionV?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - selector
    //返回按键
    func backAction(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - 代理
    //UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdetify = "colletionCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdetify, forIndexPath: indexPath) as? SelectThemeCollectionViewCell
        
        cell?.setDataForView(arData.objectAtIndex(indexPath.row) as! NSArray, index: indexPath)
        return cell!
    }
    
    //UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let ar = arData.objectAtIndex(indexPath.row)
        RTConfiguredObj.defaultConfigure().nThemeIndex = indexPath.row
        RTConfiguredObj.defaultConfigure().themefold = ar.objectAtIndex(1) as! String
        collectionV?.reloadData()
        if (ar.objectAtIndex(1) as? String) != nil && (ar.objectAtIndex(1) as! String as NSString).length > 0 {
            RTCommonUtil.unzipFileToDocument((ar.objectAtIndex(1) as! String ))
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(RELOADIMAGE, object: nil)
    }
    
    override func reloadImage(notification: NSNotificationCenter) {
        super.reloadImage(notification)
    }
}
