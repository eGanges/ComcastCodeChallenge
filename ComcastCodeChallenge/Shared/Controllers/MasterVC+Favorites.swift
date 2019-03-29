//
//  MasterVC+Favorites.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/30/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - Favorites
extension MasterViewController: FavoritesTableDelegate {
    static var favoritesSelectedCDShowCharacter: CDShowCharacter?
    
    func favoritesToggleSubDrawer() {
        print("favorites should toggle SubDrawer")
        if isCollectionGridView && isShowingFavorites {
            // rehide collection view, which superceded drawer view
            toggleCollectionView(nil)
            return
        }
        else if isCollectionGridView {
            // superceded collection view
            toggleCollectionView(nil)
        }
        
        if !isShowingFavorites {
            self.openRight()
        } else {
            self.closeRight()
            opacityView.isUserInteractionEnabled = false
        }
        isShowingFavorites = !isShowingFavorites
    }

    func performFavShowDetailSegue(forShowCharacter cdShowCharacter: CDShowCharacter) {
        MasterViewController.favoritesSelectedCDShowCharacter = cdShowCharacter
        performSegue(withIdentifier: "showDetail", sender: self)
    }

    @objc func favoritesButtonTapped(sender: UIButton?, event: UIControl.Event) {
        if let cell = sender?.superview as? UITableViewCell {
            favoritesButtonTappedForTableViewCell(cell)
        } else if let cell = sender?.superview?.superview?.superview as? CustomCollectionCell {
            favoritesButtonTappedForCollectionCell(cell)
        } else {
            print("sender: \(String(describing: sender)), \nsuperview1: \(String(describing: sender?.superview)), \nsuperview2: \(String(describing: sender?.superview?.superview)), \nsuperview3: \(String(describing: sender?.superview?.superview))")
            return
        }
    }
    
    func favoritesButtonTappedForTableViewCell(_ cell: UITableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let cdShowCharacter = fetchedResultsController.object(at: indexPath)
        cdShowCharacter.isFavorite = !cdShowCharacter.isFavorite
        _ = AppDelegate.shared?.saveContextForManagedObject(cdShowCharacter)
        cell.accessoryView =  favoritesButtonForCharacter(cdShowCharacter)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func favoritesButtonTappedForCollectionCell(_ cell: CustomCollectionCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return
        }
        let cdShowCharacter = fetchedResultsController.object(at: indexPath)
        cdShowCharacter.isFavorite = !cdShowCharacter.isFavorite
        _ = AppDelegate.shared?.saveContextForManagedObject(cdShowCharacter)
        let favIcon =  favoritesButtonForCharacter(cdShowCharacter)
        cell.favIconContainer.addSubview(favIcon)
        cell.favButton.removeFromSuperview()
        cell.favButton = favIcon
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func favoritesButtonForCharacter(_ cdShowCharacter: CDShowCharacter) -> UIButton {
        let favButton = MasterViewController.favoritesButtonUntargettedForCharacter(cdShowCharacter)
        favButton.addTarget(self, action: #selector(favoritesButtonTapped(sender:event:)), for: .touchUpInside)
        return favButton
    }
    
    static func favoritesButtonUntargettedForCharacter(_ cdShowCharacter: CDShowCharacter) -> UIButton {
        let favButton = UIButton(type: .custom)
        favoritesSetImagesForButton(favButton, character: cdShowCharacter)
        favButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        return favButton
    }
    
    static func favoritesSetImagesForButton(_ favButton: UIButton, character cdShowCharacter: CDShowCharacter) {
        if cdShowCharacter.isFavorite {
            favButton.setImage(UIImage(named: "icon_favDelete.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
            favButton.setImage(UIImage(named: "icon_favAdd.png")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            favButton.tintColor = UIColor.red
        } else {
            favButton.setImage(UIImage(named: "icon_favDelete.png")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            favButton.setImage(UIImage(named: "icon_favAdd.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
            favButton.tintColor = UIColor.lightGray
        }
    }
}

