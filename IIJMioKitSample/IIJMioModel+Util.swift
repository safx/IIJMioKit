//
//  IIJMioModel+Util.swift
//  IIJMioKit
//
//  Created by Safx Developer on 2015/05/17.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation


extension MIOCouponHdoInfo {
    public var phoneNumber: String {
        let x = number.startIndex
        let y = advance(x, 3)
        let z = advance(y, 4)
        let a = number.substringWithRange(Range<String.Index>(start: x, end: y))
        let b = number.substringWithRange(Range<String.Index>(start: y, end: z))
        let c = number.substringFromIndex(z)
        return "\(a)-\(b)-\(c)"
    }
}

