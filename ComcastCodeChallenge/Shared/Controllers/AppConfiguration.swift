//
//  AppConfiguration.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/24/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation
import UIKit
/// The `AppConfiguration` class manages target configuration and global resoures.
/// This allows the application to match the user's preferences.
/// Access configuration through the `sharedInstance` object.

class AppConfiguration {
    
    /**
     The shared configuration object.
     */
    static let shared = AppConfiguration()
    var _configDict: [String: Any?]?
    
    // these defaults will be overwritten in configure()
    var appTitleBarName = "Character Viewer"
    var appImageLoading = "image_loading.png"
    var appImageUnavailable = "image_notAvailable.png"
    var appWebServiceName = "Show+Name"
    var appImageAspectCollection = "Aspect-Fit"
    var appImageAspectDetail = "Aspect-Fit"
    var appCollectionCellBGColor = UIColor.white
    var isConfigured = false

    var _imageLoadingImage: UIImage?
    var imageLoadingSingleton: UIImage? {
        if _imageLoadingImage == nil {
            _imageLoadingImage = UIImage(named: appImageLoading)
        }
        return _imageLoadingImage
    }
    
    var _imageNotAvailableImage: UIImage?
    var imageNotAvailableSingleton: UIImage? {
        if _imageNotAvailableImage == nil {
            _imageNotAvailableImage = UIImage(named: appImageUnavailable)
        }
        return _imageNotAvailableImage
    }
    
    func configure() {
        guard !isConfigured else {
            return
        }
        isConfigured = true
        appTitleBarName = configurationValueForKey(kAppTitleBarName) ?? appTitleBarName
        appImageLoading = configurationValueForKey(kAppImageLoading) ?? appImageLoading
        appImageUnavailable = configurationValueForKey(kAppImageUnavailable) ?? appImageUnavailable
        appWebServiceName = configurationValueForKey(kAppWebServiceName) ?? appWebServiceName
        appImageAspectCollection = configurationValueForKey(kAppImageAspectCollection) ?? appImageAspectCollection
        appImageAspectDetail = configurationValueForKey(kAppImageAspectDetail) ?? appImageAspectDetail
        if let color = configurationValueForKey(kAppCollectionCellBGColor) {
            switch color {
            case "yellow":
                appCollectionCellBGColor = UIColor.yellow
                break
            default:
                appCollectionCellBGColor = UIColor.white
            }
        }
    }
    
    func configurationValueForKey(_ sKey: String) -> String? {
        if _configDict == nil {
            if let configurationFilePath = Bundle.main.path(forResource: kConfigurationPlistFileName, ofType: "plist") {
                if let info = NSDictionary(contentsOfFile: configurationFilePath) {
                    _configDict = info as? [String: Any?]
                }
            }
        }
        if let info = _configDict {
            if let retValue = info[sKey] as? String {
                return retValue
            }
        }
        return nil
    }
}
