//
//  DetailVC+Favorites.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/30/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Favorites
extension DetailViewController {
    func favoritesUpdateIcon() {
        if let cdShowCharacter = detailShowCharacter {
            let favIcon =  favoritesButtonForCharacter(cdShowCharacter)
            favIcon.frame = self.favButton.frame
            self.favIconContainer.addSubview(favIcon)
            self.favButton.removeFromSuperview()
            self.favButton = favIcon
        } else {
            self.favButton.removeFromSuperview()
            var rect = favIconContainer.frame
            rect.size.height = 0
            favIconContainer.frame = rect
            self.view.setNeedsLayout()
        }
    }
    
    func favoritesButtonForCharacter(_ cdShowCharacter: CDShowCharacter) -> UIButton {
        let favButton = MasterViewController.favoritesButtonUntargettedForCharacter(cdShowCharacter)
        favButton.addTarget(self, action: #selector(favoritesButtonTapped(sender:event:)), for: .touchUpInside)
        return favButton
    }
    
    @objc func favoritesButtonTapped(sender: UIButton?, event: UIControl.Event) {
        if let cdShowCharacter = detailShowCharacter {
            cdShowCharacter.isFavorite = !cdShowCharacter.isFavorite
            _ = AppDelegate.shared?.saveContextForManagedObject(cdShowCharacter)
            MasterViewController.favoritesSetImagesForButton(self.favButton, character: cdShowCharacter)
        }
    }
}

