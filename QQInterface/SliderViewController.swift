//
//  SliderViewController.swift
//  QQInterface
//
//  Created by apple on 16/2/26.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

typealias SliderViewControllerCallBack = (sca: CGFloat, transX: CGFloat) -> Void

enum RMoveDirection: Int {
    case Left, Right
}

class SliderViewController1: UIViewController, UIGestureRecognizerDelegate {

    /// 左视图控制器
    var LeftVC:                                  UIViewController?
    ///                                          右视图控制器
    var RinghtVC:                                UIViewController?
    ///                                          主视图控制器
    var MainVC:                                  UIViewController?

    var controllersDict: NSMutableDictionary =   NSMutableDictionary()

    ///                                          往左滑动的偏移量
    var LeftSContentOffset:                      CGFloat
    var LeftContentViewSContentOffset: CGFloat = 0

    ///                                          往右滑动的偏移量
    var RightSContentOffset:                     CGFloat

    ///                                          往左滑动时的缩放量
    var LeftSContentScale:                       CGFloat
    ///                                          往左滑动时的缩放量
    var RightSContentScale:                      CGFloat

    var LeftSJudgeOffset:                        CGFloat
    var RightSJudgeOffset:                       CGFloat

    var LeftSOpenDuration:                       Float
    var RightSOpenDuration:                      Float

    var LeftSCloseDuration:                      Float
    var RightSCloseDuration:                     Float

    var canShowLeft:                             Bool
    var canShowRight:                            Bool

    var changeLeftView:                          SliderViewControllerCallBack?

    private var mainContentView:                 UIView!
    private var leftSideView:                    UIView!
    private var rightSideView:                   UIView!

    private var tapGestureRec:                   UITapGestureRecognizer?
    private var panGestureRec:                   UIPanGestureRecognizer?
    
    private var showingLeft: Bool  = false
    private var showingRight: Bool = false
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        self.initSubViews()
        
        self.initChildControllers(LeftVC, rightVC: RinghtVC)
        
        self.showContentControllerWithModel(MainVC != nil ? NSStringFromClass(MainVC!.classForCoder) : "MainViewController")
        
        tapGestureRec = UITapGestureRecognizer(target: self, action: "closeSideBar")
        tapGestureRec?.delegate = self
        mainContentView.addGestureRecognizer(tapGestureRec!)
        tapGestureRec?.enabled = false
        
        panGestureRec = UIPanGestureRecognizer(target: self, action: "moveViewWithGesture:")
        mainContentView.addGestureRecognizer(panGestureRec!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 初始化的函数
    init () {
        LeftSContentOffset = 160
        RightSContentOffset = 160
        
        LeftSContentScale = 0.85
        RightSContentScale = 0.85
        
        LeftSJudgeOffset = 100
        RightSJudgeOffset = 100
        
        LeftSOpenDuration = 0.4
        RightSOpenDuration = 0.4
        
        LeftSCloseDuration = 0.3
        RightSCloseDuration = 0.3
        
        canShowLeft = true
        canShowRight = true
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews() {
        rightSideView = UIView(frame: self.view.bounds)
        self.view.addSubview(rightSideView!)
        
        leftSideView = UIView(frame: self.view.bounds)
        self.view.addSubview(leftSideView!)
        
        mainContentView = UIView(frame: self.view.bounds)
        self.view.addSubview(mainContentView!)
    }
    
    /**
     初始化左右抽屉的子视图
     
     - parameter leftVC:  左视图
     - parameter rightVC: 右视图
     
     - returns: nil
     */
    private func initChildControllers(leftVC: UIViewController?, rightVC: UIViewController?) {
        if let rightVC = rightVC {
            if canShowRight {
                self.addChildViewController(rightVC)
                rightVC.view.frame = CGRectMake(0, 0, rightVC.view.frame.size.width, rightVC.view.frame.size.height)
                rightSideView.addSubview(rightVC.view)
            }
        }
        
        if let leftVC = leftVC {
            if canShowLeft {
                self.addChildViewController(leftVC)
                leftVC.view.frame = CGRectMake(0, 0, leftVC.view.frame.width, leftVC.view.frame.size.height)
                leftSideView.addSubview(leftVC.view)
            }
        }
    }
    
    //MARK: - Action, 视图显示
    func showContentControllerWithModel(className: String) {
        self.closeSideBar()
        
        var controller = controllersDict[className]
        
        //根据class名获取对应类
        if controller == nil {
            if let c: AnyObject.Type = NSClassFromString(className) {
                let obj = c as! NSObject.Type
                let vc = obj.init()
                if let vc = vc as? UIViewController {
                    controller = vc
                    controllersDict.setObject(vc, forKey: className)
                }
            }
        }
        
        if mainContentView.subviews.count > 0 {
            let view = mainContentView.subviews.first
            view?.removeFromSuperview()
        }
        
        if let vc = controller as? UIViewController {
            vc.view.frame = mainContentView.frame
            mainContentView.addSubview(vc.view)
            self.MainVC = vc
        }else {
            RTLog("VC转换失败")
        }
        
    }
    
    func showLeftViewController() {
        if showingLeft {
            self.closeSideBar()
            return
        }
        
        if !canShowLeft || LeftVC == nil {
            return
        }
        
        let conT = self.transformWithDirection(.Right)//往右滑动
        self.view.sendSubviewToBack(rightSideView)
        self.configureViewShadowWithDirection(.Right)
        
        UIView.animateWithDuration(Double(LeftSOpenDuration), animations: { () -> Void in
                self.mainContentView.transform = conT
            }) { (finished) -> Void in
                self.tapGestureRec?.enabled = true
                self.showingLeft = true
                self.MainVC?.view.userInteractionEnabled = false
        }
    }
    
    func showRightViewController() {
        if showingRight {
            self.closeSideBar()
            return
        }
        if !canShowRight || RinghtVC == nil {
            return
        }
        
        let conT = self.transformWithDirection(.Left)
        self.view.sendSubviewToBack(leftSideView)
        self.configureViewShadowWithDirection(.Left)
        
        UIView.animateWithDuration(Double(RightSOpenDuration), animations: { () -> Void in
                self.mainContentView.transform = conT
            }) { (finished) -> Void in
                self.tapGestureRec?.enabled = true
                self.showingRight = true
                self.MainVC?.view.userInteractionEnabled = false
        }
    }
    
    //MARK: - selector
    //手势
    func closeSideBar() {
        self.closeSideBarWithAnimate(true) { (finished) -> Void in
        }
    }
    
    func closeSideBarWithAnimate(animate: Bool, complete: (finished: Bool) -> Void) {
        let oriT = CGAffineTransformIdentity
        if animate {
            if let mainContentView = mainContentView {
            UIView.animateWithDuration(mainContentView.transform.tx == CGFloat(LeftSContentOffset) ? Double(LeftSCloseDuration) : Double(RightSCloseDuration), animations: { () -> Void in
                    mainContentView.transform = oriT
                }, completion: { (finished) -> Void in
                    self.tapGestureRec?.enabled = false
                    self.showingRight = false
                    self.showingLeft = false
                    self.MainVC?.view.userInteractionEnabled = true //是主视图可以交互
                    complete(finished: finished)
                })
            }
        }else {
            mainContentView.transform = oriT
            tapGestureRec?.enabled = false
            showingLeft = false
            showingRight = false
            MainVC?.view.userInteractionEnabled = true
            complete(finished: true)
        }
    }
    
    struct Constant {
        static var CurrentTranslateX: CGFloat = 0
    }
    
    func moveViewWithGesture(sender: UIPanGestureRecognizer) {
        
        if sender.state == .Began {
            Constant.CurrentTranslateX = mainContentView.transform.tx
        }
        if sender.state == .Changed {
            var transX = sender.translationInView(mainContentView).x
            transX += Constant.CurrentTranslateX
            var sca: CGFloat = 0
            var ltransX = (transX - LeftSContentOffset) / LeftSContentOffset * LeftContentViewSContentOffset
            var lsca: CGFloat = 1
            
            if transX > 0 {
                if !canShowLeft || LeftVC == nil {
                    return
                }
                self.view.sendSubviewToBack(rightSideView)
                self.configureViewShadowWithDirection(.Right)
                
                if mainContentView.frame.origin.x < LeftSContentOffset {
                    sca = 1 - (mainContentView.frame.origin.x / LeftSContentOffset) * (1 - LeftSContentScale)
                    lsca = 1 - sca + LeftSContentScale
                }else {
                    sca = LeftSContentScale
                    lsca = 1
                    ltransX = 0
                }
                self.changeLeftView?(sca: lsca, transX: ltransX)
            }else { //transX < 0
                if !canShowRight || RinghtVC == nil {
                    return
                }
                
                self.view.sendSubviewToBack(leftSideView)
                self.configureViewShadowWithDirection(.Left)
                if mainContentView.frame.origin.x > -RightSContentOffset {
                    sca = 1 - (-mainContentView.frame.origin.x / RightSContentOffset) * (1 - RightSContentScale)
                }else {
                    sca = RightSContentScale
                }
            }
            
            let transS = CGAffineTransformMakeScale(sca, sca)
            let transT = CGAffineTransformMakeTranslation(transX, 0)
            let conT = CGAffineTransformConcat(transT, transS)
            mainContentView.transform = conT
        }else if sender.state == .Ended {
            let panX = sender.translationInView(mainContentView).x
            let finalX = Constant.CurrentTranslateX + panX
            if finalX > LeftSJudgeOffset { // 显示left界面
                if !canShowLeft || LeftVC == nil {
                    return
                }
                
                let conT = self.transformWithDirection(.Right)
                UIView.beginAnimations(nil, context: nil)
                mainContentView.transform = conT
                UIView.commitAnimations()
                
                showingLeft = true
                MainVC?.view.userInteractionEnabled = false
                tapGestureRec?.enabled = true
                
                self.showLeft(true)
                
                return
            }
            if finalX < -RightSJudgeOffset {//显示right界面
                if !canShowRight || RinghtVC == nil {
                    return
                }
                
                let conT = self.transformWithDirection(.Left)
                UIView.beginAnimations(nil, context: nil)
                mainContentView.transform = conT
                UIView.commitAnimations()
                
                showingRight = true
                MainVC?.view.userInteractionEnabled = false
                
                tapGestureRec?.enabled = true
                
                return
            }else {//显示main界面
                let oriT = CGAffineTransformIdentity
                UIView.beginAnimations(nil, context: nil)
                mainContentView.transform = oriT
                UIView.commitAnimations()
                
                self.showLeft(false)
                
                showingRight = false
                showingLeft = false
                MainVC?.view.userInteractionEnabled = true
                tapGestureRec?.enabled = false
            }
        }
    }
    
    //MARK: - 本类方法
    func configureViewShadowWithDirection(direction: RMoveDirection) {
        if self.deviceWithNumString().hasPrefix("iPhone") && (Float(self.deviceWithNumString().stringByReplacingOccurrencesOfString("iPhone", withString: "")) < 40) {//不支持小于iPhone4
            return
        }
        
        if self.deviceWithNumString().hasPrefix("iPod") && (Float(self.deviceWithNumString().stringByReplacingOccurrencesOfString("iPod", withString: "")) < 40) {//不支持小于iPod4
            return
        }
        
        if self.deviceWithNumString().hasPrefix("iPad") && (Float(self.deviceWithNumString().stringByReplacingOccurrencesOfString("iPad", withString: "")) < 25) {//不支持小于iPad2
            return
        }
        
        var shadow: CGFloat
        switch direction {
        case .Left:
            shadow = 2.0
        case .Right:
            shadow = -2.0
        }
        mainContentView.layer.shadowOffset = CGSizeMake(shadow, 1)
        mainContentView.layer.shadowColor = UIColor.blackColor().CGColor
        mainContentView.layer.shadowOpacity = 0.8
    }
    
    /**
     根据方向进行滑动
     
     - parameter direction: 滑动方向
     
     - returns: 滑动的位移
     */
    func transformWithDirection(direction: RMoveDirection) -> CGAffineTransform {
        var translateX: CGFloat = 0
        var transclae: CGFloat = 0
        switch direction {
        case .Left:
            translateX = -RightSContentOffset
            transclae = RightSContentScale
        case .Right:
            translateX = LeftSContentOffset
            transclae = LeftSContentScale
        }
        
        //设置偏移
        let transT = CGAffineTransformMakeTranslation(translateX, 0)
        //设置缩放
        let scaleT = CGAffineTransformMakeScale(transclae, transclae)
        //通过两个已经存在的放射矩阵生成一个新的矩阵t' = t1 * t2
        let conT = CGAffineTransformConcat(transT, scaleT)
        return conT
    }
    
    func showLeft(bShow: Bool) {
        if bShow {
            UIView.beginAnimations(nil, context: nil)
            self.changeLeftView?(sca: 1, transX: 0)
            UIView.commitAnimations()
        }else {
            UIView.beginAnimations(nil, context: nil)
            self.changeLeftView?(sca: LeftSContentScale, transX: -LeftContentViewSContentOffset)
            UIView.commitAnimations()
        }
    }
    
    func deviceWithNumString() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        let deviceString = identifier.stringByReplacingOccurrencesOfString(",", withString: "")
        return deviceString
    }
    
    private struct temps {
        static var instance: SliderViewController?
        static var myT: dispatch_once_t = 0//标志符
    }
    /**
     滑动界面单例
     
     - returns: 返回单例
     */
    class func sharedSliderController() -> SliderViewController {
        
        dispatch_once(&temps.myT) { () -> Void in
            temps.instance = SliderViewController()
        }
        
        return temps.instance!
    }
    
    //MARK: - 手势代理
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view {
            if NSStringFromClass(touchView.classForCoder) == "UITableViewCellContentView" {
                return false
            }
        }
        return true
    }
}
