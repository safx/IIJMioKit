//
//  CouponInfoCell.swift
//  IIJMioKit
//
//  Created by Safx Developer on 2015/05/16.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import UIKit
import IIJMioKit


class CouponInfoCell: UITableViewCell {
    @IBOutlet weak var plan: UILabel!
    @IBOutlet weak var coupon: UILabel!

    var model: MIOCouponInfo? {
        didSet { modelDidSet() }
    }

    private func modelDidSet() {
        plan!.text = model!.plan.rawValue

        let c = (model!.coupon).reduce(Int64(0)) { a, e in return a + Int64(e.volume) }
        coupon!.text = NSByteCountFormatter.stringFromByteCount(c * 1000 * 1000, countStyle: .Decimal)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
