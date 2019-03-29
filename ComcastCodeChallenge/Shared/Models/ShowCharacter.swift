//
//  ShowCharacter.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/22/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation

// Characters
struct ShowCharacter {
    var title: String?
    var details: String?
    var linkAddress: String?
    var iconAddress: String?
}

extension ShowCharacter {
    init(_ json: JSON) {
        if let text = json["Text"] as? String {
            self.title = text.components(separatedBy: "-").first?.trimmingCharacters(in: CharacterSet(charactersIn: " "))
            let drop = self.title! + " - "
            self.details = text.replacingOccurrences(of: drop, with: "")
            
            self.linkAddress = json["FirstURL"] as? String
            if let icon: JSON = json["Icon"] as? [String: Any?] {
                self.iconAddress = icon["URL"] as? String
            }
        }
    }
}

