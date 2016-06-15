//
//  UIViewController+MLTransition.swift
//  QQInterface
//
//  Created by apple on 16/3/15.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

enum MLTransitionGestureRecognizerType {
    /// 拖动模式
    case Pan
    /// 边界拖动模式
    case ScreenEdgePan
}

/// 有效的向右拖动的最小速率，即为大于这个速率就认为想返回上一页罢了
let kMLTransitionConstant_Valid_MIN_Velocity: CGFloat = 300

/// 设置一个默认的全局使用的type, 默认是普通拖返模式
var __MLTransitionGestureRecognizerType: MLTransitionGestureRecognizerType = .Pan

/**
 静态方法就交换静态，实例方法就交换实例方法
 
 - parameter c:       类
 - parameter origSEL: 旧方法选择器
 - parameter newSEL:  新方法选择器
 */
func __MLTransition_Swizzle(c: AnyClass, origSEL: Selector, newSEL: Selector) {
    //获取实例方法
    var origMethod: Method? = class_getInstanceMethod(c, origSEL)
    var newMethod: Method? = nil
    if origMethod == nil {
        //获取静态方法
        origMethod = class_getClassMethod(c, origSEL)
        newMethod = class_getClassMethod(c, newSEL)
    }else {
        //获取实例方法
        newMethod = class_getInstanceMethod(c, newSEL)
    }
    
    if origMethod == nil || newMethod == nil {
        return
    }
    
    //自身已经有了就添加不成功, 直接交换即可
    if class_addMethod(c, origSEL, method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!)) {
        //添加成功一般情况是因为，origSEL本身是在c的父类里。这里添加成功了一个继承方法。
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod!), method_getTypeEncoding(origMethod!))
    }else {
        method_exchangeImplementations(origMethod!, newMethod!)
    }
}

//MARK: - extension UIGestureRecognizer扩展
extension UIGestureRecognizer {
    
    private struct GestureTran {
        static var kMLTransition_ViewController_OfPan = "__MLTransition_ViewController_OfPan"
    }
    
    var __MLTransition_ViewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &GestureTran.kMLTransition_ViewController_OfPan) as? UIViewController
        }
        set {
            self.willChangeValueForKey(GestureTran.kMLTransition_ViewController_OfPan)
            objc_setAssociatedObject(self, &GestureTran.kMLTransition_ViewController_OfPan, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.didChangeValueForKey(GestureTran.kMLTransition_ViewController_OfPan)
        }
    }
}

//MARK: - 手势代理类(优化viewController手势)
/// 作为手势的delegate，原因是如果delegate是当前vc则可能产生子类覆盖的情况
class __MLTransistion_Gesture_Delegate_Object: NSObject, UIGestureRecognizerDelegate {
    
    private struct temps {
        static var instance: __MLTransistion_Gesture_Delegate_Object?
        static var myT: dispatch_once_t = 0//标志符
    }
    
    /**
     获取__MLTransistion_Gesture_Delegate_Object单例
     
     - returns: <#return value description#>
     */
    class func shareInstance() -> __MLTransistion_Gesture_Delegate_Object {
        
        dispatch_once(&temps.myT) { () -> Void in
            temps.instance = __MLTransistion_Gesture_Delegate_Object()
        }
        
        return temps.instance!
    }
    
    //直接在这处理的话对性能有好处
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let vc = gestureRecognizer.__MLTransition_ViewController
        if vc == nil {
            return false
        }
        
        if vc?.navigationController == nil || vc!.navigationController!.transitionCoordinator()!.isAnimated() || vc!.navigationController!.viewControllers.count < 2 {
            return false
        }
        
        //普通拖曳模式，如果开始方向不对即不启用
        if __MLTransitionGestureRecognizerType == .Pan && (gestureRecognizer as! UIPanGestureRecognizer).velocityInView(vc?.view).x <= 0 {
            return false
        }
        
        return true
    }
}

//MARK: - extension ViewController的扩展
extension UIViewController: UINavigationControllerDelegate {
    
    private struct temps {
        //static var instance: MLTransistion_Gesture_Delegate_Object?
        static var myT: dispatch_once_t = 0//标志符
    }
    /**
     单例方法(扩展viewcontroller)
     获取MLTransitionGesture实例, 设置手势, 替换相关生命周期的函数
     
     - parameter type: 手势类型
     */
    class func validatePanPackWithMLTransitionGestureRecognizerType(type: MLTransitionGestureRecognizerType) {
        //设置记录type,并且执行hook
        __MLTransitionGestureRecognizerType = type
        
        __MLTransition_Swizzle(self.self, origSEL: "viewDidLoad", newSEL: "__MLTransition_Hook_ViewDidLoad")
        __MLTransition_Swizzle(self, origSEL: "viewDidAppear:", newSEL: "__MLTransition_Hook_ViewDidAppear:")
        __MLTransition_Swizzle(self, origSEL: "viewWillDisappear:", newSEL: "__MLTransition_Hook_ViewWillDisappear:")
        __MLTransition_Swizzle(self, origSEL: "dealloc", newSEL: "__MLTransition_Hook_Dealloc")
    }
    
    
    private struct ViewControTran {
        static var kMLTransition_PercentDrivenInteractivePopTransition = "__MLTransition_PercentDrivenInteractivePopTransition"
        
        static var kMLTransition_GestureRecognizer = "__MLTransition_GestureRecognizer"
    }
    
    var percentDrivenInteractivePopTransition: UIPercentDrivenInteractiveTransition? {
        get {
            return objc_getAssociatedObject(self, &ViewControTran.kMLTransition_PercentDrivenInteractivePopTransition) as? UIPercentDrivenInteractiveTransition
        }
        set {
            self.willChangeValueForKey(ViewControTran.kMLTransition_PercentDrivenInteractivePopTransition)
            //将kMLTransition_PercentDrivenInteractivePopTransition指向UIPercentDrivenInteractiveTransition
            objc_setAssociatedObject(self, &ViewControTran.kMLTransition_PercentDrivenInteractivePopTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.didChangeValueForKey(ViewControTran.kMLTransition_PercentDrivenInteractivePopTransition)
        }
    }
    
    var MLTransition_gestureRecognizer: UIGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &ViewControTran.kMLTransition_GestureRecognizer) as? UIGestureRecognizer
        }
        set {
            self.willChangeValueForKey(ViewControTran.kMLTransition_GestureRecognizer)
            //将kMLTransition_GestureRecognizer指向UIGestureRecognizer
            objc_setAssociatedObject(self, &ViewControTran.kMLTransition_GestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.didChangeValueForKey(ViewControTran.kMLTransition_GestureRecognizer)
        }
    }
    
    //MARK: - delegate代理
    //UINavigationControllerDelegate
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //滑动时调用
        if fromVC == self {
            if operation == .Pop {
                let animationController = MLTransitionAnimation()
                animationController.type = .Pop
                return animationController
            }
//            else{
//                MLTransitionAnimation *animationController = [MLTransitionAnimation new];
//                animationController.type = MLTransitionAnimationTypePush;
//                return animationController;
//            }
//    Push的话，发现自定义的性能可能有点问题，由于这里需求和系统的效果一样，就默认使用系统的吧
        }
        return nil
    }
    
    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        //在交互时调用
        if animationController.isKindOfClass(MLTransitionAnimation.self) && (animationController as! MLTransitionAnimation).type == .Pop {
            return self.percentDrivenInteractivePopTransition
        }
        
        return nil
    }
    
    //MARK: - seletor选择器
    //生命周期
    private func __MLTransition_Hook_ViewDidLoad() {
        self.__MLTransition_Hook_ViewDidLoad()
        
        if self.isKindOfClass(UINavigationController.self) {
            return
        }
        
        if self.MLTransition_gestureRecognizer == nil {
            var gestureRecognizer: UIGestureRecognizer? = nil
            if __MLTransitionGestureRecognizerType == .Pan {
                gestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "__MLTransition_HandlePopRecognizer:")
                (gestureRecognizer as? UIScreenEdgePanGestureRecognizer)?.edges = .Left
            }else {
                gestureRecognizer = UIPanGestureRecognizer(target: self, action: "__MLTransition_HandlePopRecognizer:")
            }
            
            gestureRecognizer?.__MLTransition_ViewController = self
            gestureRecognizer?.delegate = __MLTransistion_Gesture_Delegate_Object.shareInstance()
            
            self.MLTransition_gestureRecognizer = gestureRecognizer
            self.view.addGestureRecognizer(gestureRecognizer!)
        }
    }
    
    func __MLTransition_Hook_ViewDidAppear(animated: Bool) {
        self.__MLTransition_Hook_ViewDidAppear(animated)
        if !self.isKindOfClass(UINavigationController.self) {
            //经过测试，只有delegate是vc的时候vc的title或者navigationItem.titleView才会跟着移动。
            //所以在下并没有使用一个单例一直作为delegate存在，单例的话效果和新版QQ一样，title不会移动，但是也会有fade效果啦。
            self.navigationController?.delegate = self
        }
    }
    
    func __MLTransition_Hook_ViewWillDisappear(animated: Bool) {
        self.__MLTransition_Hook_ViewWillDisappear(animated)
        if !self.isKindOfClass(UINavigationController.self) {
            if (self.navigationController?.delegate as? UIViewController) == self  {
                self.navigationController?.delegate = nil
                print("viewcontroller的代理没移除")
            }
        }
    }
    
    func __MLTransition_Hook_Dealloc() {
        self.MLTransition_gestureRecognizer?.delegate = nil
        self.MLTransition_gestureRecognizer?.__MLTransition_ViewController = nil
        self.__MLTransition_Hook_Dealloc()
    }
    
    //手势控制UIGestureRecognizer handlers
    func __MLTransition_HandlePopRecognizer(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            //建立一个transition的百分比控制对象
            self.percentDrivenInteractivePopTransition = UIPercentDrivenInteractiveTransition()
            self.percentDrivenInteractivePopTransition?.completionCurve = .Linear
            
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        if self.percentDrivenInteractivePopTransition == nil {
            return
        }
        
        /// 滑动百分比
        var progress = recognizer.translationInView(self.view).x / (self.view.bounds.size.width * 1)
        progress = min(1, max(0, progress))
        
        if recognizer.state == .Changed {
            //根据拖动调整transition状态
            self.percentDrivenInteractivePopTransition?.updateInteractiveTransition(progress)
        }else if (recognizer.state == .Ended || recognizer.state == .Cancelled) {
            //结束或者取消了手势, 根据方向和速率来判断应该完成transition还是取消transition
            let velocity = recognizer.velocityInView(self.view).x //只关心x方向的速率
            if velocity > kMLTransitionConstant_Valid_MIN_Velocity {//向右速率太快就完成
                self.percentDrivenInteractivePopTransition?.completionSpeed /= 1.3
                self.percentDrivenInteractivePopTransition?.finishInteractiveTransition()
            }else if velocity < -kMLTransitionConstant_Valid_MIN_Velocity {//向左速率太快就取消
                self.percentDrivenInteractivePopTransition?.completionSpeed /= 1.8
                self.percentDrivenInteractivePopTransition?.cancelInteractiveTransition()
            }else {//速率在(-300, 300)之间
                var isFinished = false
                
                if progress > 0.8 || (progress >= 0.2 && velocity > 0) {
                    isFinished = true
                }
                
                if isFinished {//完成拖动
                    self.percentDrivenInteractivePopTransition?.completionSpeed /= 1.5
                    self.percentDrivenInteractivePopTransition?.finishInteractiveTransition()
                }else {//取消拖动
                    self.percentDrivenInteractivePopTransition?.completionSpeed /= 2
                    self.percentDrivenInteractivePopTransition?.cancelInteractiveTransition()
                }
            }
            
            self.percentDrivenInteractivePopTransition = nil
        }
    }
}


