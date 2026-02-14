//
//  Item.swift
//  BaristaLog
//
//  Created by Andreu Gordillo Vázquez on 14/2/26.
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
