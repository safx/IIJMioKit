//
//  MasterViewController.swift
//  IIJMioKitSample
//
//  Created by Safx Developer on 2015/05/16.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import UIKit
import IIJMioKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var couponInfo = [MIOCouponInfo]()
    var packetLogInfo = [MIOPacketLogInfo]()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if MIORestClient.sharedClient.loadAccessToken() {
            getInfomation()
        } else {
            authorize { [weak self] err in
                if err != nil {
                    return
                }
                self?.getInfomation()
            }
        }
    }

    private func authorize(closure: MIORestClient.OAuthCompletionClosure) {
        let app = UIApplication.sharedApplication()
        let window = app.windows[0] as! UIWindow
        let view = window.rootViewController!.childViewControllers[0].view
        MIORestClient.sharedClient.authorizeInView(view!!, closure: closure)
    }

    private func getInfomation() {
        MIORestClient.sharedClient.getCoupon { [weak self] (response, error) -> Void in
            if let s = self, r = response {
                s.couponInfo = r.couponInfo
                dispatch_async(dispatch_get_main_queue()) { () in
                    s.tableView.reloadData()
                }
            }
        }
        MIORestClient.sharedClient.getPacket { [weak self] (response, error) -> Void in
            if let s = self, r = response {
                s.packetLogInfo = r.packetLogInfo
            }
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let info = couponInfo[indexPath.section].hdoInfo[indexPath.row - 1]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController

                for i in packetLogInfo {
                    for j in i.hdoInfo {
                        if info.hdoServiceCode == j.hdoServiceCode {
                            controller.packetLog = reverse(j.packetLog)
                            controller.info = info
                        }
                    }
                }
            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return couponInfo[section].hddServiceCode
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return couponInfo.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + couponInfo[section].hdoInfo.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CouponInfoCell", forIndexPath: indexPath) as! CouponInfoCell
            cell.model = couponInfo[indexPath.section]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("HdoCell", forIndexPath: indexPath) as! HdoInfoCell
            cell.model = couponInfo[indexPath.section].hdoInfo[indexPath.row - 1]
            return cell
        }
    }
}

