//
//  NSLayoutConstraint+Extension.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/22/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    class func addVisualFormatConstraintsTo(_ view: UIView, _ views: [String: UIView], _ constraints: [String], metrics: [String: Float]?, options: NSLayoutConstraint.FormatOptions = NSLayoutConstraint.FormatOptions(), additionalConstraints: [NSLayoutConstraint]?) {

        views.forEach {
            $1.translatesAutoresizingMaskIntoConstraints = false
            if !view.subviews.contains($1) {
                view.addSubview($1)
            }
        }

        constraints.forEach {
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: $0, options: options, metrics: metrics, views: views))
        }

        if let ac = additionalConstraints {
            view.addConstraints(ac)
        }
    }
}
