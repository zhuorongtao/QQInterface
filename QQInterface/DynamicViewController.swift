//
//  DynamicViewController.swift
//  QQInterface
//
//  Created by apple on 16/3/9.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class DynamicViewController: RTBasicViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableV: UITableView?
    /// [[String]]
    private var arData: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addObserver()
        
        self.createNavWithTitle("动态") { (nIndex) -> UIView? in
            return nil
        }
        
        tableV = UITableView(frame: CGRectMake(0, CGRectGetMaxY(self.navView!.frame), CGRectGetWidth(self.view.frame), self.view.height - self.navView!.bottom - self.tabBarController!.tabBar.height), style: .Grouped)
        tableV?.delegate   = self
        tableV?.dataSource = self
        
        self.initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - 本类方法
    func initData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let ar1 = ["好友动态"]
            let ar2 = ["游戏", "福利", "阅读"]
            let ar3 = ["文件/照片 助手", "吃喝玩乐", "扫一扫", "热门活动", "腾讯新闻"]
            let ar4 = ["附近的人", "附近的群", "兴趣部落"]

            self.arData.addObject(ar1)
            self.arData.addObject(ar2)
            self.arData.addObject(ar3)
            self.arData.addObject(ar4)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableV?.reloadData()
            })
        }
    }
    
    //MARK: - 代理
    //UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return arData.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = (arData.objectAtIndex(section) as? [String])?.count {
            return count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: identifier)
            cell?.accessoryType = .DisclosureIndicator
        }
        
        cell?.textLabel?.text = (arData.objectAtIndex(indexPath.section) as? NSArray)?.objectAtIndex(indexPath.row) as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 19
        }
        return 18
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
