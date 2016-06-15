//
//  MainTabViewController.swift
//  QQInterface
//
//  Created by apple on 16/3/4.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class MainTabViewController: RTBasicViewController {
    
    private var tabC: UITabBarController!
    private static var _main = MainTabViewController()
    static var main: MainTabViewController {
        return _main
    }
    static func getMain() -> MainTabViewController {
        return main
    }
    //MARK: - 初始化方法
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserver()
        tabC = UITabBarController()
        tabC.tabBar.backgroundColor = UIColor.clearColor()
        tabC.view.frame = self.view.frame
        self.view.addSubview(tabC.view)
        
        let messageVC  = MessagesViewController()
        let contactsVC = ContactsViewController()
        let dynamicVC  = DynamicViewController()
        
        tabC.viewControllers = [messageVC, contactsVC, dynamicVC]
        
        self.reloadImage()
        
        UITabBarItem.appearance().setTitleTextAttributes(NSDictionary(objects: [RGBA(96, G: 162, B: 222, A: 1)], forKeys: [NSForegroundColorAttributeName]) as? [String : AnyObject], forState: .Selected)
        tabC.selectedIndex = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func reloadImage() {
        super.reloadImage()
        
        var imageName = ""
        
        if isIOS7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1 && RTConfiguredObj.defaultConfigure().nThemeIndex != 0 {
            imageName = "tabbar_bg_ios7.png"
        }else {
            imageName = "tabbar_bg.png"
        }
        
        tabC.tabBar.backgroundImage = RTCommonUtil.imageNamed(imageName)
        
        let ar = NSMutableArray()
        ar.addObjectsFromArray(tabC.viewControllers!)
        
        var arData = [UIViewController]()
        ar.enumerateObjectsUsingBlock({ ( viewController, idx, _) -> Void in
            var item: UITabBarItem? = nil
            
            switch idx {
            case 0:
                item = UITabBarItem(
                    title:
                        "消息",
                    image:
                        RTCommonUtil.imageNamed("tab_recent_nor.png")?.imageWithRenderingMode(.AlwaysOriginal),
                    selectedImage:
                        RTCommonUtil.imageNamed("tab_recent_press.png")?.imageWithRenderingMode(.AlwaysOriginal)
                    )
            case 1:
                item = UITabBarItem(title: "联系人", image: nil, tag: 1)
                item?.image = RTCommonUtil.imageNamed("tab_buddy_nor.png")?.imageWithRenderingMode(.AlwaysOriginal)
                item?.selectedImage = RTCommonUtil.imageNamed("tab_buddy_press.png")?.imageWithRenderingMode(.AlwaysOriginal)
            case 2:
                item = UITabBarItem(title: "动态", image: nil, tag: 1)
                item?.image = RTCommonUtil.imageNamed("tab_qworld_nor.png")?.imageWithRenderingMode(.AlwaysOriginal)
                item?.selectedImage = RTCommonUtil.imageNamed("tab_qworld_press.png")?.imageWithRenderingMode(.AlwaysOriginal)
            default:
                break
            }
            (viewController as? UIViewController)?.tabBarItem = item
            arData.append(viewController as! UIViewController)
        })
        tabC.viewControllers = arData
    }

}
