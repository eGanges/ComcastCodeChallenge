//
//  MasterViewController.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/22/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: SlideMenuController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    var showCharacterTask: URLSessionDataTask!
    
    var cdShowCharacters: [NSManagedObject] = []
    var showCharacters: [ShowCharacter] = []
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var collectionToggleButton: UIButton!
    var isCollectionGridView = false

    @IBOutlet weak var searchBar: UISearchBar!
    var searchPredicate: NSPredicate?
    
    var isShowingFavorites = false

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FavoritesTable") as? FavoritesTableViewController {
            controller.favoritesTableDelegate = self  // see MasterVC+Favorites.swift for implemenation
            self.rightViewController = controller
        }
        self.delegate = self
        initView()
    }
    
    override func initView() {
        super.initView()
        adjustInteractivityForSideDrawer()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustInteractivityForSideDrawer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.adjustInteractivityForSideDrawer()
        }
    }
    
    func adjustInteractivityForSideDrawer() {
        if !isShowingFavorites {
            mainContainerView.isUserInteractionEnabled = false
            opacityView.isUserInteractionEnabled = false
        } else {
            closeRight()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // update configuration
        AppConfiguration.shared.configure()
        
        // slidemenu
        edgesForExtendedLayout = UIRectEdge()

        // title bar
        navigationItem.title = AppConfiguration.shared.appTitleBarName
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone:
            // load collection view, custom title, collection view toggle button
            viewDidLoadAddCollectionView()
        } else {
            // iPad:
            // custom title
            let width = UIScreen.main.bounds.width
            let rect = CGRect(x: 0, y: 0, width: width, height: 44)
            let label = UILabel(frame: rect)
            label.text = AppConfiguration.shared.appTitleBarName
            label.sizeToFit()
            label.adjustsFontSizeToFitWidth = true
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            navigationItem.titleView = label
            navigationItem.title = ""
        }

        // search
        viewDidLoadAddSearch()

        // integrate activityView
        self.activityIndicator.hidesWhenStopped = true
        NSLayoutConstraint.addVisualFormatConstraintsTo(self.tableView, [
            "activityIndicator": activityIndicator
            ], [
                "H:|-(>=15)-[activityIndicator]-(>=15)-|",
                "V:|-(>=15)-[activityIndicator]-(>=15)-|"
            ], metrics: nil, additionalConstraints: [
                NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self.tableView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self.tableView, attribute: .centerY, multiplier: 1, constant: 0)
            ])
        activityIndicator.translatesAutoresizingMaskIntoConstraints  = false

        // load data
        loadDataIfNecessary()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    func updateUI() {
        print("showCharacters: \(showCharacters)")
        reloadData()
    }

    func loadDataIfNecessary() {
        guard cdShowCharacters.count == 0 else {
            return
        }
        
        showCharacterTask?.cancel() // cancel previous loading task
        activityIndicator.startAnimating() // show loading indicator
        
        // reload persistent data?
        let managedContext = fetchedResultsController.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDShowCharacter")
        do {
            cdShowCharacters = try managedContext.fetch(fetchRequest)
            //  if data has persisted, return
            if cdShowCharacters.count > 0 {
                print("persistant cache reload successful")
                reloadData()
                activityIndicator.stopAnimating()
                return
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // else...        
        // Begin Web Service API call to load the data
        webServiceLoadShowCharacterData { [weak self] error in
            // update UI
            DispatchQueue.main.async {
                if let error = error {
                    // error?
                    let alert = UIAlertController(title: "Networking Error", message: "\(error.localizedDescription) \n\nPlease check your connection and restart \(AppConfiguration.shared.appTitleBarName) to try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self?.present(alert, animated: true)
                }
                
                self?.activityIndicator.stopAnimating()
                self?.updateUI()
            }
        }
            
    }
    
    func reloadData() {
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
            reloadData()
            return
        }
        self.tableView.reloadData()
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.collectionView.reloadData()
        }
    }
    


    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDetail":
            var cdShowCharacter: CDShowCharacter?
            
            if MasterViewController.favoritesSelectedCDShowCharacter != nil {
                cdShowCharacter = MasterViewController.favoritesSelectedCDShowCharacter
                MasterViewController.favoritesSelectedCDShowCharacter = nil
            }
            else if isCollectionGridView, let indexPath = collectionView.indexPathsForSelectedItems?.first {
                cdShowCharacter = fetchedResultsController.object(at: indexPath)
            } else if let indexPath = tableView.indexPathForSelectedRow {
                cdShowCharacter = fetchedResultsController.object(at: indexPath)
            }
            
            if let cdShowCharacter = cdShowCharacter {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailShowCharacter = cdShowCharacter
                controller.searchString = searchBar.text
                
                // preload the title bar
                controller.navigationItem.title = cdShowCharacter.title ?? AppConfiguration.shared.appTitleBarName
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
            break
            
        default:
            return
        }
    }


    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isCollectionGridView { return 0 }
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cdShowCharacter = fetchedResultsController.object(at: indexPath)
        configureCell(cell, forRowAt: indexPath, withCDShowCharacter: cdShowCharacter)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath, withCDShowCharacter cdShowCharacter: CDShowCharacter) {
        cell.textLabel!.text = cdShowCharacter.title ?? ""
        cell.accessoryView = favoritesButtonForCharacter(cdShowCharacter)
    }

    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<CDShowCharacter> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }

        let fetchRequest: NSFetchRequest<CDShowCharacter> = CDShowCharacter.fetchRequest()

        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20

        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchRequest.predicate = searchPredicate

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        if self.managedObjectContext == nil, let context = AppDelegate.shared?.persistentContainer.viewContext {
            self.managedObjectContext = context
        }
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController

        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<CDShowCharacter>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

