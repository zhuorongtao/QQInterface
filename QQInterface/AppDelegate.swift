//
//  AppDelegate.swift
//  QQInterface
//
//  Created by apple on 16/2/26.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        
        let leftVC = LeftViewController()
        let sliderViewController = SliderViewController.sharedSliderController()
        sliderViewController.LeftVC = leftVC
        sliderViewController.MainVC = MainTabViewController()
        sliderViewController.LeftSContentOffset = 275
        sliderViewController.LeftContentViewSContentOffset = 90
        sliderViewController.LeftSContentScale = 0.77
        sliderViewController.LeftSJudgeOffset = 160
        sliderViewController.changeLeftView = {sca, transX in
            let ltransS = CGAffineTransformMakeScale(sca, sca)
            let ltransT = CGAffineTransformMakeTranslation(transX, 0)
            let lconT = CGAffineTransformConcat(ltransT, ltransS)
            leftVC.contentView.transform = lconT
        }
        
        //手势返回更新为MLBlackTransition
        MLBlackTransition.validatePanPackWithMLBlackTransitionGestureRecognizerType(.Pan)
        
        let naviC = UINavigationController(rootViewController: SliderViewController.sharedSliderController())
        self.window?.rootViewController = naviC
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}

