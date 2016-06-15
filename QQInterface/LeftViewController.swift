//
//  LeftViewController.swift
//  QQInterface
//
//  Created by apple on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class LeftViewController: RTBasicViewController, UITableViewDelegate, UINavigationBarDelegate, UIImagePickerControllerDelegate, UITableViewDataSource {

    var contentView: UIView!
    
    private var arData = []
    private var dicData: NSDictionary?
    private var tableView: UITableView!
    
    /// 人物头像
    var hearderIV: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserver()
        arData = [
            ["开通会员", "vip_shadow.png"],
            ["QQ钱包", "sidebar_purse.png"],
            ["网上营业厅", "sidebar_business.png"],
            ["个性装饰", "sidebar_decoration.png"],
            ["我的收藏", "sidebar_favorit.png"],
            ["我的相册", "sidebar_album.png"],
            ["我的文件", "sidebar_file.png"]
        ]
        self.view.backgroundColor = UIColor.clearColor()
        
        var hHeight:CGFloat = 90
        let imageBgV = UIImageView(frame: CGRectMake(0, 0, self.view.width, self.view.height / 4 + 10))
        imageBgV.tag = 18
        self.view.addSubview(imageBgV)
        
        hHeight = imageBgV.bottom - 80
        
        let imageBgV2 = UIImageView(frame: CGRectMake(0, hHeight, self.view.width, self.view.height - hHeight))
        imageBgV2.tag = 19
        imageBgV2.backgroundColor = UIColor.clearColor()
        self.view.addSubview(imageBgV2)
        
        contentView = UIView(frame: self.view.bounds)
        contentView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(contentView)
        
        self.hearderIV = UIImageView(frame: CGRectMake(25, 60, 70, 70))
        self.hearderIV?.layer.cornerRadius = self.hearderIV!.width / 2
        self.hearderIV?.tag = 20
        self.hearderIV?.userInteractionEnabled = true
        self.hearderIV?.clipsToBounds = true
        contentView.addSubview(self.hearderIV!)
        let tap = UITapGestureRecognizer(target: self, action: "takePhoto")
        self.hearderIV?.addGestureRecognizer(tap)
        
        tableView = UITableView(frame: CGRectMake(0, imageBgV.bottom + 10, self.view.width, self.view.height - imageBgV.bottom - 80), style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        contentView.addSubview(tableView)
        self.reloadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 相机
    func isPhotoAvailable(type: UIImagePickerControllerSourceType) -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(type)
    }
    
    func showPhotoLibrary(vc: LeftViewController) {
        self.showPhoto(.PhotoLibrary, viewcontroller: vc)
    }
    
    func takePhoto(vc: LeftViewController) {
        self.showPhoto(.Camera, viewcontroller: vc)
    }
    
    func showPhoto(type: UIImagePickerControllerSourceType, viewcontroller vc: LeftViewController) {
        if self.isPhotoAvailable(type) {
            let controller = UIImagePickerController()
            controller.sourceType = type
            controller.delegate = vc
            vc.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }else {
            let alert = UIAlertController(title: type == .PhotoLibrary ? "相册" : "相机", message: "不支持", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - 代理
    //imagePickController
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image0 = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.hearderIV?.image = image0
        }
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 47
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case 3:
            let themeVC = SelectThemeViewController()
            SliderViewController.sharedSliderController().closeSideBarWithAnimate(true, complete: { (finished) -> Void in
                SliderViewController.sharedSliderController().navigationController?.pushViewController(themeVC, animated: true)
            })
        default:
            self.backAction()
        }
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdetify = "left"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdetify)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdetify)
            cell?.backgroundColor = UIColor.clearColor()
            cell?.textLabel?.textColor = UIColor.whiteColor()
            cell?.selectionStyle = .Blue //设置
        }
        
        //获取工具栏title
        let ar = arData.objectAtIndex(indexPath.row) as! NSArray
        cell?.imageView?.image = RTCommonUtil.imageNamed(ar.objectAtIndex(1) as! String)
        cell?.textLabel?.text = ar.objectAtIndex(0) as? String
        return cell!
    }
    
    //MARK: - 本类方法
    /**
    重写父类reloadImage
    */
    override func reloadImage() {
        super.reloadImage()
        let imageBgV = self.view.viewWithTag(18) as! UIImageView
        let image = RTCommonUtil.imageNamed("sidebar_bg.jpg")
        imageBgV.image = image
        
        let imageBgV2 = self.view.viewWithTag(19) as! UIImageView
        let image2 = RTCommonUtil.imageNamed("sidebar_bg_mask.png")
        imageBgV2.image = image2?.resizableImageWithCapInsets(UIEdgeInsetsMake(image2!.size.height - 1, 0, 1, 0))
        
        let headerIV = self.view.viewWithTag(20) as! UIImageView
        let headerI = RTCommonUtil.imageNamed("chat_bottom_smile_nor.png")
        headerIV.image = headerI
        
        tableView.reloadData()
    }
    
    override func reloadImage(notification: NSNotificationCenter) {
        self.reloadImage()
    }
    
    func backAction() {
        SliderViewController.sharedSliderController().closeSideBar()
    }
    
    //MARK: - selector定义
    func takePhoto() {
        self.takePhoto(self)
    }

}
