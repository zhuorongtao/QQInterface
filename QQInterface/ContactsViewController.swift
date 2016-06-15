//
//  ContactsViewController.swift
//  QQInterface
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class ContactsViewController: RTBasicViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    private var selectType: UISegmentedControl?
    private var tableV:     UITableView?

    private var arData     = []
    /// 人物成员分组名数组[String]
    private var arKey      = []
    /// 人物分组的字典[String: [String]]
    private var dicData    = NSMutableDictionary()
    /// 正在展开显示的字典[String: NSNumber]
    private var dicShowRow = NSMutableDictionary()

    private var tableHeaderV:   UIView?
    private var searchB:        UISearchBar?
    private var searchDisplayC: UISearchDisplayController?
    private var arMenuData:     NSArray?
    private var menuV:          RectViewForMessage?

    /// 搜索栏复位的临时变量
    private var tempSearchFrame: CGRect?
    private var tempTableFrame:  CGRect?
    private var tempNavFrame:    CGRect?

    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserver()
        
        self.createNavWithTitle("联系人") { (nIndex) -> UIView? in
            if nIndex == 1 {
                let btn   = UIButton(type: UIButtonType.Custom)
                btn.frame = CGRectMake(self.navView!.width - 20, (self.navView!.height - 40) / 2, 60, 40)
                btn.setTitle("添加", forState: .Normal)
                btn.backgroundColor = UIColor.blueColor()
                btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                return btn //创建有导航按钮
            }
            return nil //不创建左导航按钮
        }
        searchB                                 = UISearchBar(frame: CGRectMake(0, self.navView!.bottom, self.view.width, 44))
        searchB?.placeholder                    = "搜索"
        searchB?.searchBarStyle                 = .Default
        searchDisplayC                          = UISearchDisplayController(searchBar: searchB!, contentsController: self)
        searchDisplayC?.active                  = false
        searchDisplayC?.delegate                = self
        searchDisplayC?.searchResultsDataSource = self//UITableViewDataSource
        searchDisplayC?.searchResultsDelegate   = self
        self.view.addSubview(searchDisplayC!.searchBar)

        tableHeaderV                            = UIView(frame: CGRectMake(0, searchB!.bottom, self.view.width, 106))
        tableHeaderV?.backgroundColor           = UIColor.whiteColor()
        
        //好友分组的标题
        let titleV             = UIView(frame: CGRectMake(0, tableHeaderV!.height - 25, self.view.width, 25))
        titleV.backgroundColor = RGBA(235, G: 235, B: 235, A: 1)
        let titleL             = UILabel(frame: titleV.bounds)
        titleL.backgroundColor = UIColor.clearColor()
        titleL.text            = "  好友分组"
        titleL.font            = UIFont.systemFontOfSize(13)
        titleV.addSubview(titleL)
        tableHeaderV?.addSubview(titleV)
        
        arMenuData = [
            ["人脉圈", "mulchat_header_icon_circle.png"],
            ["通讯录", "buddy_header_icon_addressBook.png"],
            ["群组", "buddy_header_icon_group.png"],
            ["生活服务", "buddy_header_icon_public.png"]
        ]
        
        menuV = RectViewForMessage(frame: CGRectMake(0, 0, tableHeaderV!.width, tableHeaderV!.height - titleV.height), ar: arMenuData!, showSpera: false, bg: "buddy_header_nor.png")
        tableHeaderV?.addSubview(menuV!)
        
        //好友分组的tableView
        tableV = UITableView(frame: CGRectMake(0, searchB!.bottom, self.view.width, self.view.height - searchB!.bottom - self.tabBarController!.tabBar.height), style: .Plain)
        tableV?.delegate        = self
        tableV?.dataSource      = self
        tableV?.backgroundColor = UIColor.clearColor()
        self.view.addSubview(tableV!)
        tableV?.tableHeaderView = tableHeaderV
        
        self.initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 本类方法
    func initData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.arKey = [
                "我的设备",
                "朋友",
                "兄弟",
                "家人",
                "同学",
                "同事",
                "陌生人",
                "黑名单"
            ]
            self.arKey.enumerateObjectsUsingBlock({ (obj, idx, _) -> Void in
                let ar = NSMutableArray()
//                srand(UInt32(time(UnsafeMutablePointer<time_t>.alloc(0))))//不加这句每次产生的随机数不变
                let c = rand() % 10  + 1
//                let c = arc4random() % 10 + 1
                for var i: Int32 = 1; i < c; i++ {
                    ar.addObject(String(format: "%d", i))
                }
                if let keyObj = obj as? String {
                    //每个cell的header(人物分组, ar为组成员, keyObj为组名)
                    self.dicData.setObject(ar, forKey: keyObj)
                    //子单元(人物)
                    self.dicShowRow.setObject(NSNumber(bool: false), forKey: keyObj)
                }
            })
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableV?.reloadData()
            })
        }
    }
    
    //MARK: - 代理
    //UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == searchDisplayC!.searchResultsTableView {
            return 0
        }
        return arKey.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchDisplayC!.searchResultsTableView {
            return 0
        }
        let key      = arKey.objectAtIndex(section) as! String
        let bShowRow = (dicShowRow.objectForKey(key) as! NSNumber).boolValue
        if bShowRow {
            //返回组成员个数
            return (dicData.objectForKey(arKey.objectAtIndex(section) as! String) as! NSMutableArray).count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let indentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(indentifier)
        if cell == nil {
            let w = tableView.width / 6
            cell = UITableViewCell(style: .Value1, reuseIdentifier: indentifier)
            //人物头像
            let image                  = UIImage(named: "aio_face_manage_cover_default")
            let imageV                 = UIImageView(frame: CGRectMake(10, (50 - w + 15) / 2, w - 15, w - 15))
            imageV.layer.masksToBounds = true
            imageV.layer.cornerRadius  = 6
            imageV.layer.borderWidth   = 1
            imageV.layer.borderColor   = UIColor.whiteColor().CGColor
            imageV.image               = image
            imageV.tag                 = 1
            cell?.contentView.addSubview(imageV)
            
            //人物名
            let nameL = UILabel(frame: CGRectMake(w + 5, 0, w * 4 - 5, 30))
            nameL.backgroundColor = UIColor.clearColor()
            nameL.textAlignment = .Natural
            nameL.font = UIFont.systemFontOfSize(18)
            nameL.tag = 2
            cell?.contentView.addSubview(nameL)
            
            //人物状态
            let stateL = UILabel(frame: CGRectMake(w + 5, 25, w * 4 - 5, 20))
            stateL.backgroundColor = UIColor.clearColor()
            stateL.font = UIFont.systemFontOfSize(12)
            stateL.textColor = UIColor.grayColor()
            stateL.tag = 3
            stateL.text = "[离线]这家伙很吊，什么也没有留下"
            cell?.contentView.addSubview(stateL)
        }
        let key = arKey.objectAtIndex(indexPath.section) as! String
        let bShowRow = (dicShowRow.objectForKey(key) as! NSNumber).boolValue
        if bShowRow {
            (cell?.contentView.viewWithTag(2) as? UILabel)?.text = (dicData.objectForKey(key) as! NSArray).objectAtIndex(indexPath.row) as? String
        }
        return cell!
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //每个分组的样式
        let w = tableView.width / 7
        let headV = UIView(frame: CGRectMake(0, 0, tableView.width, 44))
        headV.backgroundColor = UIColor.whiteColor()
        
        let key = arKey.objectAtIndex(section)
        let bShowRow = (dicShowRow.objectForKey(key) as! NSNumber).boolValue
        
        //分组展开的图标
        let image = RTCommonUtil.imageNamed("buddy_header_arrow.png")
        let arrowIV = UIImageView(frame: CGRectMake((w - image!.size.width) / 2, (44 - image!.size.height) / 2, image!.size.width, image!.size.height))
        arrowIV.image = image
        headV.addSubview(arrowIV)
        if bShowRow {
            arrowIV.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        }
        
        //分组名称
        let titleL = UILabel(frame: CGRectMake(w, 2, w * 4, 40))
        titleL.text = arKey.objectAtIndex(section) as? String
        titleL.font = UIFont.systemFontOfSize(16)
        titleL.userInteractionEnabled = false
        headV.addSubview(titleL)
        
        //组之间的分割线, 位于header的上方
        let lineHV = UIView(frame: CGRectMake(0, 0, tableView.width, 0.5))
        lineHV.backgroundColor = UIColor.grayColor()
        headV.addSubview(lineHV)
        
        if bShowRow {
            //组被展开后,组之间的分割线, 位于header的下方
            let lineBV = UIView(frame: CGRectMake(0, 44 - 0.5, tableView.width, 0.5))
            lineBV.backgroundColor = UIColor.grayColor()
            headV.addSubview(lineBV)
        }
        
        let sumL = UILabel(frame: CGRectMake(w * 5, 2, w * 2 - 5, 40))
        sumL.textColor = UIColor.grayColor()
        sumL.text = "\(0)/\((dicData.objectForKey(arKey.objectAtIndex(section)) as! NSArray).count)"
        sumL.textAlignment = .Right
        sumL.font = UIFont.systemFontOfSize(14)
        sumL.userInteractionEnabled = false
        headV.addSubview(sumL)
        
        let btn = UIButton(type: .Custom)
        btn.frame = headV.bounds
        btn.tag = section + 1
        headV.addSubview(btn)
        btn.addTarget(self, action: "showRow:", forControlEvents: .TouchUpInside)
        
        return headV
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //UISearchDisplayDelegate
    func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController) {
        tempNavFrame    = self.navView?.frame
        tempTableFrame  = self.tableV?.frame
        tempSearchFrame = self.searchB?.frame
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.navView?.top -= 64
            self.searchB?.top -= 44
            self.tableV?.top  -= 44
            }) { (finish) -> Void in
                self.navView?.hidden = true
                self.tableV?.height  += 44
        }
        
        controller.searchBar.showsCancelButton = true
        for subView in (controller.searchBar.subviews)[0].subviews {
            if subView.isKindOfClass(UIButton.self) {
                (subView as! UIButton).setTitle("取消", forState: .Normal)
            }
        }
        
    }
    
    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.navView?.frame = self.tempNavFrame!
            self.searchB?.frame = self.tempSearchFrame!
            self.tableV?.frame  = self.tempTableFrame!
            }) { (finish) -> Void in
                self.navView?.hidden = false
        }
    }
    
    //MARK: - selector
    func showRow(sender: UIButton) {
        let key = arKey.objectAtIndex(sender.tag - 1) as! String
        let b = (dicShowRow.objectForKey(key) as! NSNumber).boolValue
        dicShowRow.setObject(NSNumber(bool: !b), forKey: key)
        tableV?.reloadSections(NSIndexSet(index: sender.tag - 1), withRowAnimation: .None)
    }
    
    //MARK: - 本类方法
    override func reloadImage() {
        super.reloadImage()
        menuV?.reloadMenuImage()
        tableV?.reloadData()
    }
}
