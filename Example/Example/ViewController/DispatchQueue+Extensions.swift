//
//  DispatchQueue+Extensions.swift
//  Example
//
//  Created by Thanh Hai Khong on 17/3/25.
//

import Foundation

extension DispatchQueue {
    static var currentLabel: String {
        let name = __dispatch_queue_get_label(nil)
        if let label = String(cString: name, encoding: .utf8) {
            return label
        }
        return "Unknown"
    }
}
