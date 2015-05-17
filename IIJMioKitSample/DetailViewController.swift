//
//  DetailViewController.swift
//  IIJMioKitSample
//
//  Created by Safx Developer on 2015/05/16.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import UIKit
import IIJMioKit

class DetailViewController: UITableViewController {

    var packetLog = [MIOPacketLog]()
    var info: MIOCouponHdoInfo?

    func configureView() {
        self.title = info?.phoneNumber
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = info?.phoneNumber
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packetLog.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PacketLogCell", forIndexPath: indexPath) as! PacketLogCell
        cell.model = packetLog[indexPath.row]
        return cell
    }

}

