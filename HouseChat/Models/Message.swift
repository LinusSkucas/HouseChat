//
//  Message.swift
//  HouseChat
//
//  Created by Linus Skucas on 12/3/20.
//

import Foundation
import UIKit  // 🤮

struct Message: Identifiable, Equatable, Codable {
    var id = UUID()
    var time = Date()
    var displayName: String
    let message: String
    
    var isCurrentDevice: Bool {
        return UIDevice.current.name == displayName
    }
}
