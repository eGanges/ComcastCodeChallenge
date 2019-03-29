//
//  MasterVC+Search.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/30/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import UIKit
import CoreData
import Foundation

// MARK: - Search Bar
extension MasterViewController: UISearchBarDelegate {

    func viewDidLoadAddSearch() {
        searchBar.delegate = self
        searchBar.setImage(UIImage(named: "icon_favFilterOn.png"), for: .bookmark, state: .normal)
    }
    
    // MARK: - SearchBar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBarUpdatePredicateAndReload()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            searchBar.text = nil
        }
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBarUpdatePredicateAndReload()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBarUpdatePredicateAndReload()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("Search Bookmark Tapped")
        favoritesToggleSubDrawer()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarUpdatePredicateAndReload()
    }

    func searchBarUpdatePredicateAndReload() {
        var searchText = ""
        if let text = searchBar.text, text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
            searchText = text
            searchPredicate = NSPredicate(format: "(title CONTAINS[c] %@) || (details CONTAINS[c] %@)", searchText, searchText)
        } else {
            searchPredicate = nil
        }
        _fetchedResultsController?.fetchRequest.predicate = searchPredicate
        do {
            try _fetchedResultsController?.performFetch()
            print("Did fetch for search: \(searchText)")
        }
        catch {
            let nserror = error as NSError
            print("Could Not fetch for search: \(searchText); Unresolved error \(nserror), \(nserror.userInfo)")
        }
        reloadData()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}
