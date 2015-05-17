//
//  HdoInfoCell.swift
//  IIJMioKit
//
//  Created by Safx Developer on 2015/05/16.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import UIKit
import IIJMioKit


class HdoInfoCell: UITableViewCell {
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var addtionalInfo: UILabel!
    @IBOutlet weak var regulated: UILabel!
    @IBOutlet weak var couponSwitch: UISwitch!

    var model: MIOCouponHdoInfo? {
        didSet { modelDidSet() }
    }

    private func modelDidSet() {
        phoneNumber!.text = model!.phoneNumber
        addtionalInfo!.text = model!.voice ? "Voice" : (model!.sms ? "SMS" : "")
        regulated.hidden = !model!.regulation
        couponSwitch!.on = model!.couponUse
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func couponSwitchStatusChaged(sender: UISwitch) {
        let savedCouponUse = model!.couponUse

        let revert = { () in
            dispatch_async(dispatch_get_main_queue()) { () in
                sender.on = savedCouponUse
            }
        }

        if sender.on != savedCouponUse {
            MIORestClient.sharedClient.putCoupon(sender.on, hdoServiceCode: model!.hdoServiceCode) { [weak self] (response, error) -> Void in
                if let e = error {
                    revert()
                    return
                }
                if let r = response where r.returnCode != "OK" {
                    revert()
                } else {
                    self?.model!.couponUse = !savedCouponUse
                }
            }
        }
    }
}
