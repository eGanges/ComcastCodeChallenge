//
//  FavoritesTableViewController.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/31/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// define delegate protocol
@objc public protocol FavoritesTableDelegate {
    func performFavShowDetailSegue(forShowCharacter cdShowCharacter: CDShowCharacter)
}

class FavoritesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    // MARK: - Vars
    var favoritesTableDelegate: FavoritesTableDelegate?
    var managedObjectContext: NSManagedObjectContext? = nil
    var cdShowCharacters: [NSManagedObject] = []
    var searchPredicate: NSPredicate? = NSPredicate(format: "isFavorite == true")

    // MARK: - Overrides
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // update configuration, if necessary
        AppConfiguration.shared.configure()
        
        // title bar
        navigationItem.title = "Favorites"
        
        print("ftv register cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavCell")
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // data
        loadDataIfNecessary()
        reloadAllData()
    }
    
    
    // MARK: - Custom
    func reloadAllData() {
        if Thread.isMainThread {
            reloadDataOnMainThread()
        } else {
            DispatchQueue.main.async {
                self.reloadDataOnMainThread()
            }
        }
    }
    func reloadDataOnMainThread() {
        guard Thread.isMainThread else {
            reloadAllData()
            return
        }
        print("ftvc reloading data on main thread")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()
    }
    

    func loadDataIfNecessary() {
        // always fresh, so reload
        do {
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: kFavoritesCacheName)
            let managedContext = fetchedResultsController.managedObjectContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDShowCharacter")
            fetchRequest.predicate = searchPredicate
            cdShowCharacters = try managedContext.fetch(fetchRequest)
            print("Did fetch for favs = \(cdShowCharacters.count)")
        }
        catch {
            let nserror = error as NSError
            print("Could Not fetch for favs; Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cdShowCharacter = cdShowCharacters[indexPath.row] as? CDShowCharacter {
            favoritesTableDelegate?.performFavShowDetailSegue(forShowCharacter: cdShowCharacter)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Favorites"
    }
    
    override func numberOfSections(in iTableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cdShowCharacters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("get cellForRowAt: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell", for: indexPath)
        if let cdShowCharacter = cdShowCharacters[indexPath.row] as? CDShowCharacter {
            configureCell(cell, forRowAt: indexPath, withCDShowCharacter: cdShowCharacter)
        } else {
            cell.textLabel!.text = ""
        }
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath, withCDShowCharacter cdShowCharacter: CDShowCharacter) {
        cell.textLabel!.text = cdShowCharacter.title ?? ""
    }
    
    
    // MARK: - Fetched results controller
    var _fetchedResultsController: NSFetchedResultsController<CDShowCharacter>? = nil
    var fetchedResultsController: NSFetchedResultsController<CDShowCharacter> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: kFavoritesCacheName)
        let fetchRequest: NSFetchRequest<CDShowCharacter> = CDShowCharacter.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // assign the filter
        fetchRequest.predicate = searchPredicate
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        if self.managedObjectContext == nil, let context = AppDelegate.shared?.persistentContainer.viewContext {
            self.managedObjectContext = context
        }
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: kFavoritesCacheName)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    private func controllerWillChangeContent(_ controller: NSFetchedResultsController<CDShowCharacter>) {
        tableView.beginUpdates()
    }
    
    private func controller(_ controller: NSFetchedResultsController<CDShowCharacter>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    private func controller(_ controller: NSFetchedResultsController<CDShowCharacter>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) {
                configureCell(cell, forRowAt: indexPath!, withCDShowCharacter: anObject as! CDShowCharacter)
            }
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, forRowAt: indexPath!, withCDShowCharacter: anObject as! CDShowCharacter)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    private func controllerDidChangeContent(_ controller: NSFetchedResultsController<CDShowCharacter>) {
        tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     */

    private func controllerDidChangeContent(controller: NSFetchedResultsController<CDShowCharacter>) {
     // In the simplest, most efficient, case, reload the table view.
     tableView.reloadData()
     }
 
}

