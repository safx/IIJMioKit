//
//  PacketLogCell.swift
//  IIJMioKit
//
//  Created by Safx Developer on 2015/05/16.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import UIKit
import IIJMioKit

class PacketLogCell: UITableViewCell {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var withCoupon: UILabel!
    @IBOutlet weak var withoutCoupon: UILabel!

    private let dateFormatter = NSDateFormatter()

    var model: MIOPacketLog? {
        didSet { modelDidSet() }
    }

    private func modelDidSet() {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        date!.text = dateFormatter.stringFromDate(model!.date)

        let f = NSByteCountFormatter()
        f.allowsNonnumericFormatting = false
        f.allowedUnits = .UseMB | .UseGB
        withCoupon!.text    = f.stringFromByteCount(Int64(model!.withCoupon * 1000 * 1000))
        withoutCoupon!.text = f.stringFromByteCount(Int64(model!.withoutCoupon * 1000 * 1000))
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
