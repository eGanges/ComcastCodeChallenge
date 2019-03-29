//
//  MasterVC+SlideMenu.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 2/1/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation
import UIKit

/// MARK: - SlideMenuController
extension MasterViewController: SlideMenuControllerDelegate {
    
    func rightWillOpen() {
        print("favorites SubDrawer rightWillOpen")
        self.tableView.isScrollEnabled = false
        opacityView.isUserInteractionEnabled = true
        mainContainerView.isUserInteractionEnabled = true
    }
    
    func rightDidOpen() {
        print("favorites SubDrawer rightDidOpen")
    }
    
    func rightWillClose() {
        print("favorites SubDrawer rightWillClose")
    }
    
    func rightDidClose() {
        print("favorites SubDrawer rightDidClose")
        self.tableView.isScrollEnabled = true
        opacityView.isUserInteractionEnabled = false
        mainContainerView.isUserInteractionEnabled = false
    }
}

