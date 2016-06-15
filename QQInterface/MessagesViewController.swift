//
//  MessagesViewController.swift
//  QQInterface
//
//  Created by apple on 16/3/4.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class MessagesViewController: RTBasicViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, RectViewForMessageDelegate {
    
    private var searchB:           UISearchBar?
    private var tableV:            UITableView?
    private var arData:            NSMutableArray!
    private var selectTypeSegment: UISegmentedControl?
    private var searchDisplayC:    UISearchDisplayController?
    private var maskV: UIView?     //模糊背景
    private var menuV:             RectViewForMessage?
    private var arMenu = []
    
    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserver()
        self.createNavWithTitle("消息") { (nIndex) -> UIView? in
            if nIndex == 1 {
                let btn = UIButton(type: UIButtonType.Custom)
                let image = RTCommonUtil.imageNamed("menu_icon_bulb.png")
                btn.setImage(image, forState: .Normal)
                btn.frame = CGRectMake(self.navView!.width - image!.size.width - 10, (self.navView!.height - image!.size.height) / 2, image!.size.width, image!.size.height)
                btn.tag = 989
                btn.addTarget(self, action: "showMenu:", forControlEvents: .TouchUpInside)
                return btn
            }
            return nil
        }
        
        searchB = UISearchBar(frame: CGRectMake(0, self.navView!.bottom, self.view.width, 44))
        searchB?.placeholder = "搜索"
        searchB?.searchBarStyle = .Default
        
        self.tableV = UITableView(frame: CGRectMake(0, searchB!.bottom, CGRectGetWidth(self.view.frame), self.view.height - searchB!.bottom - self.tabBarController!.tabBar.height), style: .Plain)
        tableV?.dataSource = self
        tableV?.delegate = self
        self.view.addSubview(tableV!)
        
        searchDisplayC = UISearchDisplayController(searchBar: searchB!, contentsController: self)
        searchDisplayC?.active = false
        searchDisplayC?.delegate = self
        searchDisplayC?.searchResultsDelegate = self
        searchDisplayC?.searchResultsDataSource = self
        self.view.addSubview(searchDisplayC!.searchBar)
        
        maskV = UIView(frame: CGRectMake(0, self.navView!.bottom, self.view.width, self.view.height - self.navView!.height - self.tabBarController!.tabBar.height))
        maskV?.clipsToBounds = true
        self.view.addSubview(maskV!)
        maskV?.hidden = true
        
        let bg = UIView(frame: maskV!.bounds)
        bg.backgroundColor = UIColor.blackColor()
        bg.alpha = 0.5
        maskV?.addSubview(bg)
        
        let tSM = UITapGestureRecognizer(target: self, action: "showMenuByTap:")
        bg.addGestureRecognizer(tSM)
        
        arMenu = [
            ["建讨论组","menu_icon_createDiscuss.png"],
            ["多人通话", "menu_icon_groupaudio.png"],
            ["共享图片", "menu_icon_camera.png"],
            ["扫一扫", "menu_icon_QR.png"]
        ]
        menuV = RectViewForMessage(frame: CGRectMake(0, -75, self.view.width, 75), ar: arMenu, showSpera: false, bg: "menu_bg_pressed.png")
        menuV?.delegate = self
        maskV?.addSubview(menuV!)
        
        self.initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        let btn = self.rightV as! UIButton
        if btn.selected {
            btn.userInteractionEnabled = false
            btn.selected = !btn.selected
            self.showMenuWithBool(btn.selected, complete: { () -> () in
                btn.userInteractionEnabled = true
            })
        }
    }
    
    func initData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.arData = NSMutableArray()
            self.arData.addObject("好友A")
            self.arData.addObject("荣陶")
            self.arData.addObject("我的电脑")
            self.arData.addObject("路人甲")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableV?.reloadData()
            })
        }
    }

    //Mark: - 本类方法
    func showMenuWithBool(bShow: Bool, complete: () -> ()) {
        if bShow {
            maskV?.hidden = false
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.menuV?.top = 0
                }, completion: { (finish) -> Void in
                    complete()
            })
        }else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.menuV?.top = -self.menuV!.height
                }, completion: { (finish) -> Void in
                    self.maskV?.hidden = true
                    complete()
            })
        }
    }
    
    //MARK: - selector
    func showMenu(btn: UIButton) {
        btn.userInteractionEnabled = false
        btn.selected = !btn.selected
        self.showMenuWithBool(btn.selected) { () -> () in
            btn.userInteractionEnabled = true
        }
    }
    
    func showMenuByTap(tap: UITapGestureRecognizer) {
        let btn = self.rightV as! UIButton
        btn.userInteractionEnabled = false
        btn.selected = !btn.selected
        self.showMenuWithBool(btn.selected) { () -> () in
            btn.userInteractionEnabled = true
        }
    }
    
    //MARK: - 代理
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchDisplayC!.searchResultsTableView {
            return 0
        }
        return arData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arData.objectAtIndex(indexPath.row) as? String
        return cell!
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //UISearchDisplayDelegate
    func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.rightV?.hidden = true
            }) { (finish) -> Void in
                controller.searchBar.showsCancelButton = true
                for subView in (controller.searchBar.subviews)[0].subviews {
                    if subView.isKindOfClass(UIButton.self) {
                        (subView as! UIButton).setTitle("取消", forState: .Normal)
                    }
                }
        }
    }
    
    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController) {
        self.rightV?.hidden = false
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        self.filteredListContentForSearchText(searchString, scope: self.searchDisplayController?.searchBar.scopeButtonTitles?[self.searchDisplayController!.searchBar.selectedScopeButtonIndex])
        
        let tableView = self.searchDisplayController?.searchResultsTableView
        for subView in tableView!.subviews {
            if subView.classForCoder == UILabel.self {
                let lbl = subView as! UILabel
                lbl.text = "没有数据"
            }
        }
        
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filteredListContentForSearchText(self.searchDisplayController?.searchBar.text, scope: self.searchDisplayController?.searchBar.scopeButtonTitles?[searchOption])
        return true
    }
    
    //RectViewForMessageDelegate
    func press(rectView: RectViewForMessage, index nIndex: CGFloat) {
    }
    
    //MARK: - 本类方法
    func filteredListContentForSearchText(searchText: String?, scope: String?) {
        //TODO
    }
    
    override func reloadImage() {
        super.reloadImage()
        let btn = self.view.viewWithTag(989) as? UIButton
        btn?.setImage(RTCommonUtil.imageNamed("menu_icon_bulb.png"), forState: .Normal)
        btn?.setImage(RTCommonUtil.imageNamed("menu_icon_bulb_pressed.png"), forState: .Selected)
        menuV?.reloadMenuImage()
    }
}
