//
//  MasterVC+CollectionView.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/30/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import UIKit
import CoreData
import Foundation


class CustomCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favIconContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favButton: UIButton!

    var iconTaskID: String?

    override init(frame: CGRect){
        super.init(frame: frame)
        
    }

    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
}


// MARK: - Collection View Delegate
extension MasterViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    func viewDidLoadAddCollectionView() {
        // title bar
        addCollectionsEnabledTitleView()
        
        // collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = true
        let tBounds = self.tableView.bounds
        let sHeight = searchBar.frame.size.height
        let cFrame = CGRect(x: 0, y: sHeight, width: tBounds.width, height: tBounds.height - sHeight)
        collectionView.frame = cFrame
        self.tableView.addSubview(collectionView)
        print("added collectionView to tableView")
    }
    
    func addCollectionsEnabledTitleView() {
        // titleView
        navigationItem.title = ""
        let width = UIScreen.main.bounds.width
        let height = navigationController?.navigationBar.frame.height ?? 67
        var rect = CGRect(x: 0, y: 0, width: width, height: height)
        let titleView = UIView(frame: rect)
        
        // title button
        collectionToggleButton = UIButton(type: .custom)
        collectionToggleButton.setImage(UIImage(named: "icon_grid.png"), for: .normal)
        collectionToggleButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        collectionToggleButton.imageView?.contentMode = .scaleAspectFit
        collectionToggleButton.addTarget(self, action: #selector(toggleCollectionView(_:)), for: .touchUpInside)
        
        // title
        let offset = collectionToggleButton.frame.size.width + 15
        rect = CGRect(x: offset, y: 0, width: width - offset, height: 44)
        let title = UILabel(frame: rect)
        title.font = UIFont.boldSystemFont(ofSize: 48)
        title.text = AppConfiguration.shared.appTitleBarName
        title.textAlignment = .right
        title.baselineAdjustment = .alignCenters
        title.adjustsFontSizeToFitWidth = true
        title.autoresizingMask = [.flexibleWidth]
        title.layer.borderColor = UIColor.blue.cgColor
        title.layer.borderWidth = 0
        
        NSLayoutConstraint.addVisualFormatConstraintsTo(titleView, [
            "toggleButton": collectionToggleButton,
            "title": title
            ], [
                "H:|-(-11)-[toggleButton(44)]-(>=15)-[title]|",
                "V:|-[toggleButton]-|",
                "V:|[title]|"
            ], metrics: nil, additionalConstraints: nil)
        title.translatesAutoresizingMaskIntoConstraints  = false
        collectionToggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.autoresizingMask = [.flexibleWidth]
        navigationItem.titleView = titleView
        navigationItem.backBarButtonItem = nil

    }
    
    @objc func toggleCollectionView(_ sender: Any?) {
        isCollectionGridView = !isCollectionGridView
        if isCollectionGridView {
            collectionToggleButton.setImage(UIImage(named: "icon_lines.png"), for: .normal)
            self.tableView.separatorStyle = .none
        } else {
            collectionToggleButton.setImage(UIImage(named: "icon_grid.png"), for: .normal)
            self.tableView.separatorStyle = .singleLine
        }
        collectionView.isHidden = !isCollectionGridView
        reloadData()
    }
    

    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionCell", for: indexPath) as! CustomCollectionCell
        let cdShowCharacter = fetchedResultsController.object(at: indexPath)
        configureCustomCollectionCell(cell, withCDShowCharacter: cdShowCharacter)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func configureCustomCollectionCell(_ cell: CustomCollectionCell, withCDShowCharacter cdShowCharacter: CDShowCharacter) {
        let favButton = favoritesButtonForCharacter(cdShowCharacter)
        cell.iconTaskID = nil
        cell.activityIndicator.hidesWhenStopped = true
        cell.titleLabel.text = cdShowCharacter.title
        cell.favIconContainer.addSubview(favButton)
        cell.favButton.removeFromSuperview()
        cell.favButton = favButton
        
        // customize to make the best presentation for the target's image sets
        switch AppConfiguration.shared.appImageAspectCollection {
        case "AspectFit":
            cell.imageView.contentMode = .scaleAspectFit
            break
        case "AspectFill":
            cell.imageView.contentMode = .scaleAspectFill
            break
        
        default:
            cell.imageView.contentMode = .scaleAspectFit
            break
        }
        
        if cdShowCharacter.iconAddress == nil {
            // use placeholder image
            cell.imageView.image = AppConfiguration.shared.imageNotAvailableSingleton
        } else if let iconData = cdShowCharacter.iconData {
            cell.imageView.image = UIImage(data: iconData)
        } else {
            // load image data
            let iconTask = getImageDataForCDShowCharacter(cdShowCharacter, context: self.fetchedResultsController.managedObjectContext) { task, success, error in
                if success, let iconData = cdShowCharacter.iconData, let image = UIImage(data: iconData) {
                    // save new data
                    do {
                        try cdShowCharacter.managedObjectContext?.save()
                        print("Image D/L Success for \(cdShowCharacter.title!) at \(cdShowCharacter.iconAddress!)")
                    } catch {
                        let nserror = error as NSError
                        print("Could Not Save Image Data for \(cdShowCharacter.title!) at \(cdShowCharacter.iconAddress!); Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    
                    // show new image, if within the same task
                    if task == cell.iconTaskID {
                        DispatchQueue.main.async {
                            cell.imageView.image = image
                        }
                    }
                } else {
                    // show nil image placeholder
                    DispatchQueue.main.async {
                        cell.imageView.image = AppConfiguration.shared.imageNotAvailableSingleton
                    }
                }
                // stop spinner
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                }
            }
            cell.iconTaskID = iconTask.hashValue.description
            // show spinner
            cell.activityIndicator.startAnimating()
            // loading BG image
            cell.imageView.image = AppConfiguration.shared.imageLoadingSingleton
        }
        cell.backgroundColor = AppConfiguration.shared.appCollectionCellBGColor
    }
}

