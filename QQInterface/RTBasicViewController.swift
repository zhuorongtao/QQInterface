//
//  RTBasicViewController.swift
//  QQInterface
//
//  Created by apple on 16/2/28.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class RTBasicViewController: UIViewController {
    var statusBarView: UIImageView?
    var navView: UIView?
    var nMutiple: Int = 0
    var arParams = []
    var rightV: UIView?
    
    private var nSpaceNavY: CGFloat = 0

    //MARK: - 初始化函数
    init(frame: CGRect, param arParams: NSArray) {
        self.arParams = arParams
        super.init(nibName: nil, bundle: nil)
        self.view.frame = frame
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = RGBA(236, G: 236, B: 236, A: 1)
        statusBarView = UIImageView(frame: CGRectMake(0, 0, 320, 0))
        nSpaceNavY = 20
        if isIos7() >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1 {
            statusBarView?.frame = CGRectMake(statusBarView!.frame.origin.x, statusBarView!.frame.origin.y, statusBarView!.frame.size.width, 20)
            statusBarView?.backgroundColor = UIColor.clearColor()
            self.view.addSubview(statusBarView!)
            nSpaceNavY = 0
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - 本类方法
    /**
    创建导航栏样式, title为""则为nil
    
    - parameter szTitle:  导航栏标题
    - parameter menuItem: 导航栏左右按钮
    */
    func createNavWithTitle(szTitle: String, createMenuItem menuItem: (nIndex: Int) -> UIView?) {
        let navIV = UIImageView(frame: CGRectMake(0, nSpaceNavY, self.view.width, 64 - nSpaceNavY))
        navIV.tag = 98
        self.view.addSubview(navIV)
        self.reloadImage()
        
        //导航条
        navView = UIImageView(frame: CGRectMake(0, statusbarSize, 320, 44))
        navView?.backgroundColor = UIColor.clearColor()
        self.view.addSubview(navView!)
        navView?.userInteractionEnabled = true
        
        if szTitle != "" {
            let titleLabel = UILabel(frame: CGRectMake((navView!.width - 200) / 2, (navView!.height - 40) / 2, 200, 40))
            titleLabel.text = szTitle
            titleLabel.textAlignment = .Center
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.font = UIFont.boldSystemFontOfSize(18)
            titleLabel.backgroundColor = UIColor.clearColor()
            navView?.addSubview(titleLabel)
        }
        
        let item1 = menuItem(nIndex: 0)
        if item1 != nil {
            navView?.addSubview(item1!)
        }
        let item2 = menuItem(nIndex: 1)
        if item2 != nil {
            rightV = item2
            navView?.addSubview(item2!)
        }
    }
    
    /**
    注册通知, 更新导航栏图片
     */
    func addObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "observerReloadImage:", name: RELOADIMAGE, object: nil)
    }
    
    func reloadImage() {
        var imageName: String = ""
        if isIos7() >= 7 && (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1) {
            imageName = "header_bg_ios7"
        }else {
            imageName = "header_bg"
        }
        let image = RTCommonUtil.imageNamed(imageName)
        let navIV = self.view.viewWithTag(98) as? UIImageView
        navIV?.image = image
    }
    
    func reloadImage(notification: NSNotificationCenter) {
        self.reloadImage()
    }
    
    //MARK: - selector定义
    func observerReloadImage(notification: NSNotificationCenter) {
        self.reloadImage(notification)
    }
    
    
}
