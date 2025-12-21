//
//  Item.swift
//  SampoMaster
//
//  Created by 松本 圭祐 on 2025/12/21.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
