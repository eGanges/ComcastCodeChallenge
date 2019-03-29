//
//  NSAttributedString+SearchHighlights.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 2/2/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//
// Attribution:
// Bohdan Savych
// https://stackoverflow.com/users/6061098/bohdan-savych
//

import Foundation
import UIKit

extension NSAttributedString {
    convenience init(searchBase: String,
                     keyWords: [String],
                     foregroundColor: UIColor,
                     font: UIFont,
                     highlightForeground: UIColor,
                     highlighBackground: UIColor) {
        let baseAttributed = NSMutableAttributedString(string: searchBase, attributes: [NSAttributedString.Key.font: font,
                                                                                  NSAttributedString.Key.foregroundColor: foregroundColor])
        let range = NSRange(location: 0, length: searchBase.utf16.count)
        for word in keyWords {
            guard let regex = try? NSRegularExpression(pattern: word, options: .caseInsensitive) else {
                continue
            }
            
            regex
                .matches(in: searchBase, options: .withTransparentBounds, range: range)
                .forEach { baseAttributed
                    .addAttributes([NSAttributedString.Key.backgroundColor: highlighBackground,
                                    NSAttributedString.Key.foregroundColor: highlightForeground],
                                   range: $0.range) }
        }
        self.init(attributedString: baseAttributed)
    }
}
