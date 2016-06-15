//
//  MLBlackTransition.swift
//  QQInterface
//
//  Created by apple on 16/3/15.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

enum MLBlackTransitionGestureRecognizerType {
    /// 拖动模式
    case Pan
    /// 边界拖动模式
    case ScreenEdgePan
}

var __MLBlackTransitionGestureRecognizerType: MLBlackTransitionGestureRecognizerType = .Pan

/**
 hook: 修改函数入口
 静态方法就交换静态，实例方法就交换实例方法
 
 - parameter c:       类
 - parameter origSEL: 旧方法选择器
 - parameter newSEL:  新方法选择器
 */
func __MLBlackTransition_Swizzle(c: AnyClass, origSEL: Selector, newSEL: Selector) {
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

//MARK: - extension String
extension String {
    func __mlRot13() -> String? {
        let source = UnsafeMutablePointer<CChar>((self as NSString).cStringUsingEncoding(NSASCIIStringEncoding))
        let dest = UnsafeMutablePointer<CChar>(malloc(((self as NSString).length + 1) * sizeof(CChar)))
        
        if dest == nil {
            return nil
        }
        
        var i: Int = 0
        
        let A = "A"
        let Z = "Z"
        let a = "a"
        let z = "z"
        let AChar = A.cStringUsingEncoding(NSASCIIStringEncoding)![0]
        let ZChar = Z.cStringUsingEncoding(NSASCIIStringEncoding)![0]
        let aChar = a.cStringUsingEncoding(NSASCIIStringEncoding)![0]
        let zChar = z.cStringUsingEncoding(NSASCIIStringEncoding)![0]
        print("AChar: \(AChar), ZChar: \(ZChar), aChar: \(aChar), zChar: \(zChar)")
        for ; i < (self as NSString).length; i++ {
            var c = source[i]
            if c >= AChar && c <= ZChar {
                c = (c - AChar + 13) % 26 + AChar
            }else if c >= aChar && c <= zChar {
                c = (c - aChar + 13) % 26 + aChar
            }
            dest[i] = c
        }
        dest[i] = 0
        
        let result = String.fromCString(dest)
        print("字符串为: \(result!)")
        free(dest)
        return result
    }
    
    func __mlEncryptString() -> String? {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        return base64?.__mlRot13()
    }
    
    func __mlDecryptString() -> String? {
        let rot13 = self.__mlRot13()
        RTLog("\(rot13)")
        if let data = NSData(base64EncodedString: rot13!, options: .IgnoreUnknownCharacters) {
            return String(data: data, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
}

//MARK: - extension UIView
extension UIView {
    
    private struct ViewTemp {
        static var kMLBlackTransition_UIView_DisableMLBlackTransition = "__MLBlackTransition_UIView_DisableMLBlackTransition"
    }
    
    var disableMLBlackTransition: Bool {
        get {
            if let disable = objc_getAssociatedObject(self, &ViewTemp.kMLBlackTransition_UIView_DisableMLBlackTransition) {
                return disable.boolValue
            }
            return false
        }
        set {
            self.willChangeValueForKey(ViewTemp.kMLBlackTransition_UIView_DisableMLBlackTransition)
            objc_setAssociatedObject(self, &ViewTemp.kMLBlackTransition_UIView_DisableMLBlackTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)//指定一个关联对象的强引用，不能被原子化使用
            self.didChangeValueForKey(ViewTemp.kMLBlackTransition_UIView_DisableMLBlackTransition)
        }
    }
}

//MARK: - extension UIGestureRecognizer
extension UIGestureRecognizer {
    
    private struct GestureTemp {
        static var kMLBlackTransition_NavController_OfPan = "__MLBlackTransition_NavController_OfPan"
    }
    
    var __MLBlackTransition_NavController: UINavigationController? {
        get {
            return objc_getAssociatedObject(self, &GestureTemp.kMLBlackTransition_NavController_OfPan) as? UIViewController as? UINavigationController
        }
        set {
            self.willChangeValueForKey(GestureTemp.kMLBlackTransition_NavController_OfPan)
            objc_setAssociatedObject(self, &GestureTemp.kMLBlackTransition_NavController_OfPan, newValue, .OBJC_ASSOCIATION_ASSIGN)//指定一个关联对象的弱引用
            self.didChangeValueForKey(GestureTemp.kMLBlackTransition_NavController_OfPan)
        }
    }
}

//MARK: - extension UIPercentDrivenInteractiveTransition
extension UIPercentDrivenInteractiveTransition {
    func handleNavigationTransition(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            //做个样子,也用来防止如果这个api系统改了名字，我们这边还是可用的。
            recognizer.__MLBlackTransition_NavController?.popViewControllerAnimated(true)
        }
    }
}

//MARK: - extension UINavigationController
extension UINavigationController: UIGestureRecognizerDelegate {
    
    private struct NavTemp {
        static var k__MLBlackTransition_GestureRecognizer = "__MLBlackTransition_GestureRecognizer"
    }
    
    /// 为每个导航栏添加一个拖动手势
    var __MLBlackTransition_panGestureRecognizer: UIPanGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &NavTemp.k__MLBlackTransition_GestureRecognizer) as? UIPanGestureRecognizer
        }
        set {
            self.willChangeValueForKey(NavTemp.k__MLBlackTransition_GestureRecognizer)
            objc_setAssociatedObject(self, &NavTemp.k__MLBlackTransition_GestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)//指定一个关联对象的强引用，不能被原子化使用
            self.didChangeValueForKey(NavTemp.k__MLBlackTransition_GestureRecognizer)
        }
    }
    
    /**
     hook ViewDidLoad()
     注意调试
     */
    func __MLBlackTransition_Hook_ViewDidLoad() {
        self.__MLBlackTransition_Hook_ViewDidLoad()
        //初始化手势
        if self.__MLBlackTransition_panGestureRecognizer == nil && self.interactivePopGestureRecognizer!.delegate!.isKindOfClass(UIPercentDrivenInteractiveTransition.self) {
            var gestureRecognizer: UIPanGestureRecognizer? = nil
            let temp = "nTShMTkyGzS2nJquqTyioyElLJ5mnKEco246"
            if let kHandleNavigationTransitionKey = temp.__mlDecryptString() {
                if __MLBlackTransitionGestureRecognizerType == .ScreenEdgePan {
                    gestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self.interactivePopGestureRecognizer?.delegate, action: NSSelectorFromString(kHandleNavigationTransitionKey));
                    (gestureRecognizer as? UIScreenEdgePanGestureRecognizer)?.edges = .Left
                }else {
                    gestureRecognizer = UIPanGestureRecognizer(target: self.interactivePopGestureRecognizer?.delegate, action: NSSelectorFromString(kHandleNavigationTransitionKey))
                }
                
                gestureRecognizer?.delegate = self
                gestureRecognizer?.__MLBlackTransition_NavController = self
                //添加沿屏幕方向滑动的手势
                self.__MLBlackTransition_panGestureRecognizer = gestureRecognizer
                self.interactivePopGestureRecognizer?.enabled = false
            }else {
                RTLog("kHandleNavigationTransitionKey为空")
            }
        }
        
        self.view.addGestureRecognizer(self.__MLBlackTransition_panGestureRecognizer!)
    }
    
    //MARK: - GestureRecognizer代理
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let navVC = self
        if let coord = navVC.transitionCoordinator() {
            if coord.isAnimated() || navVC.viewControllers.count < 2 {
                return false
            }
        }
        
        let view = gestureRecognizer.view
        let loc = gestureRecognizer.locationInView(view)
        if let subView = view?.hitTest(loc, withEvent: nil) {//查找该点上的子视图
            if subView.disableMLBlackTransition {
                return false
            }
        }
        
        //普通拖拽模式, 如果开始方向不对即不启用
        if __MLBlackTransitionGestureRecognizerType == .Pan {
            if let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocityInView(navVC.view) {
                if velocity.x <= 0 {
                    //向左滑动
                    return false
                }
                
                if var translation = (gestureRecognizer as? UIPanGestureRecognizer)?.translationInView(navVC.view) {
                    translation.x = translation.x == 0 ? 0.00001 : translation.x
                    let ratio = fabs(translation.y) / fabs(translation.x)
                    //因为上滑的操作相对比较频繁, 所以角度限制少点
                    if (translation.y > 0 && ratio > 0.618) || (translation.y < 0 && ratio > 0.2) {
                        //右滑角度不在范围内
                        return false
                    }
                }
            }
        }
        return true
    }
}

//MARK: - extension UINavigationController outcall
extension UINavigationController {
    func enabledMLBlackTransition(enable: Bool) {
        self.__MLBlackTransition_panGestureRecognizer?.enabled = enable
    }
}

//MARK: - extension UIScrollView category ，可让scrollView在一个良好的关系下并存
extension UIScrollView {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(self.panGestureRecognizer) {
            //如果此scrollView有横向滚动的可能, 当然就需要忽略了
            if CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(-CGFloat(M_PI) * 0.5), self.transform) || CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(CGFloat(M_PI) * 0.5), self.transform) {
                //            if (self.contentSize.height>self.frame.size.width) {
                //暂时对于这一种比较喜欢直接就不支持拖返吧，感觉体验好点。
                return false;
            }else {
                if self.contentSize.width > self.frame.size.width {
                    return false
                }
            }
            
            if otherGestureRecognizer.__MLBlackTransition_NavController != nil {
                //说明是我们的手势
                return true
            }
        }
        return false
    }
}

class MLBlackTransition: NSObject {
    
    private struct oneTemp {
        static var instance: MLBlackTransition? = nil
        static var oneT: dispatch_once_t = 0
    }
    /**
     获取MLBlackTransition单例
     
     - parameter type: <#type description#>
     */
    class func validatePanPackWithMLBlackTransitionGestureRecognizerType(type: MLBlackTransitionGestureRecognizerType) {
        //iOS7以下不可用
        if Float(UIDevice.currentDevice().systemVersion) < 7.0 {
            return
        }
        
        //启用hook,自动对每个导航器开启拖返功能, 整个程序生命周期只允许执行一次
        dispatch_once(&oneTemp.oneT) { () -> Void in
            //设置记录type, 并且执行hook
            __MLBlackTransitionGestureRecognizerType = type
            
            __MLBlackTransition_Swizzle(UINavigationController.self, origSEL: "viewDidLoad", newSEL: "__MLBlackTransition_Hook_ViewDidLoad")
        }
    }
}
