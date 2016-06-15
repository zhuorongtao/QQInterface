//
//  MLTransitionAnimation.swift
//  QQInterface
//
//  Created by apple on 16/3/9.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

enum MLTransitionAnimationType {
    case Pop
    case Push
}

/// 通常意义上的动画时间
let kMLTransitionConstant_TransitionDuration: Double          = 0.25

/// 左VC移动的长度和其整个宽度的比例
let kMLTransitionConstant_LeftVC_Move_Ratio_Of_Width: CGFloat = 0.29

/// 阴影相关
let kMLTransitionConstant_RightVC_ShadowOffset_Width:CGFloat  = -0.4
/// 阴影相关
let kMLTransitionConstant_RightVC_ShadowRadius: CGFloat       = 3
/// 阴影相关
let kMLTransitionConstant_RightVC_ShadowOpacity: Float        = 0.3

class MLTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var type: MLTransitionAnimationType?
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            RTLog("fromVC为nil")
            return
        }
        guard let toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            RTLog("toVC为nil")
            return
        }
        
        //可以理解为是动画进行中的view容器,当前fromVC.view已经在容器里了,但是toVC.view没有
        let containerView = transitionContext.containerView()
        
        //设置阴影
        var vc: UIViewController? = nil
        if self.type == .Push {
            vc = toVC
        }else {
            vc = fromVC
        }
        
        vc?.view.layer.shadowColor   = UIColor.blackColor().CGColor
        vc?.view.layer.shadowOffset  = CGSizeMake(kMLTransitionConstant_RightVC_ShadowOffset_Width, 0)
        vc?.view.layer.shadowRadius  = kMLTransitionConstant_RightVC_ShadowRadius
        vc?.view.layer.shadowOpacity = kMLTransitionConstant_RightVC_ShadowOpacity
        
        if self.type == .Push {
            //添加到容器View
            containerView?.insertSubview(toVC.view, aboveSubview: fromVC.view)
            //从右边推进来
            toVC.view.transform = CGAffineTransformMakeTranslation(toVC.view.frame.size.width, 0)
        }else {
            //放进容器
            containerView?.insertSubview(toVC.view, belowSubview: fromVC.view)
            //设置初始值
            toVC.view.transform = CGAffineTransformMakeTranslation(-toVC.view.frame.size.width * kMLTransitionConstant_LeftVC_Move_Ratio_Of_Width, 0)
        }
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: .CurveLinear, animations: { () -> Void in
            if self.type == .Push {
                fromVC.view.transform = CGAffineTransformMakeTranslation(-fromVC.view.frame.size.width * kMLTransitionConstant_LeftVC_Move_Ratio_Of_Width, 0) //向左移3/10的宽度位置
            }else {
                fromVC.view.transform = CGAffineTransformMakeTranslation(fromVC.view.frame.size.width, 0)
            }
            toVC.view.transform = CGAffineTransformIdentity
            }) { (finish) -> Void in
                vc?.view.layer.shadowOpacity = 0
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                
                //重置回来, 两个都重置是因为动画可能会被取消
                fromVC.view.transform = CGAffineTransformIdentity
                toVC.view.transform   = CGAffineTransformIdentity
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        //设置一个动画时间
        return kMLTransitionConstant_TransitionDuration
    }

}
