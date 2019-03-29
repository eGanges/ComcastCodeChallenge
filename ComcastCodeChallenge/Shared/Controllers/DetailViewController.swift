//
//  DetailViewController.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/22/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var favIconContainer: UIView!
    @IBOutlet weak var favButton: UIButton!
    
    var detailIconTask: URLSessionDataTask?
    
    // implement search string highilighting in Detail results.
    // Technically, this is scope creep; but it makes it easier to very accurate results
    // and is a more pleasant user experience.
    var searchString: String?

    var detailShowCharacter: CDShowCharacter? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    
    func attributedStringForSearchText(_ sText: String?, baseText bText: String?) -> NSAttributedString? {
        guard let searchText = sText?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty, let baseText = bText else {
            if bText != nil {
                return NSMutableAttributedString(string: bText!)
            }
            return nil
        }
        return NSAttributedString(searchBase: baseText, keyWords: [searchText], foregroundColor: UIColor.black, font: detailTextView.font!, highlightForeground: UIColor.black, highlighBackground: UIColor.yellow)
        
    }
    
    func configureView() {
        // update app configuration, if necessary
        AppConfiguration.shared.configure()
        
        // Update the user interface for the detail item.
        guard let cdShowCharacter = detailShowCharacter, detailTextView != nil, detailImageView != nil, activityIndicator != nil  else {
            // title
            navigationItem.title = AppConfiguration.shared.appTitleBarName
            
            // content
            if detailImageView != nil {
                detailImageView.image = UIImage(named: "ios-marketing.png")
            }
            if detailTextView != nil {
                let theThe = AppConfiguration.shared.appTitleBarName.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true).first?.lowercased() == "the" ? "" : " the"
                detailTextView.text = "\nWelcome to\(theThe) \(AppConfiguration.shared.appTitleBarName). Please return to the Master Menu and select a desired character from the show."
            }
            return
        }
        
        // image D/L
        detailIconTask = nil
        
        // title
        navigationItem.title = cdShowCharacter.title
        
        // text
        if let desc = cdShowCharacter.details, let searchText = searchString, !searchText.isEmpty {
            detailTextView.attributedText = attributedStringForSearchText(searchText, baseText: desc)
            searchString = nil
        } else if let text = cdShowCharacter.details {
            detailTextView.text = text
        } else {
            detailTextView.text = "Sorry, something went wrong."
        }
        
        // make the best presentation for the target's image sets
        switch AppConfiguration.shared.appImageAspectDetail {
        case "AspectFit":
            detailImageView.contentMode = .scaleAspectFit
            break
        case "AspectFill":
            detailImageView.contentMode = .scaleAspectFill
            break
            
        default:
            detailImageView.contentMode = .scaleAspectFit
            break
        }
        
        // image
        if let iconData = cdShowCharacter.iconData {
            detailImageView.image = UIImage(data: iconData)
        } else if cdShowCharacter.iconAddress == nil || cdShowCharacter.iconAddress!.isEmpty {
            detailImageView.image = AppConfiguration.shared.imageNotAvailableSingleton
        } else {
            // show spinner
            activityIndicator.startAnimating()
                        
            // show loading BG image
            detailImageView.image = AppConfiguration.shared.imageLoadingSingleton

            // load image data
            detailIconTask = ShowCharacterService().getImageDataAtWebAddress(cdShowCharacter.iconAddress!) { (data, error) in
                let curTask = cdShowCharacter.iconTaskID
                cdShowCharacter.setNilValueForKey("iconTaskID")
                guard self.detailIconTask.hashValue.description == curTask else {
                    return
                }
                // reset task
                self.detailIconTask = nil
                
                // update image, if possible
                DispatchQueue.main.async {
                    if let iconData = data, iconData.count > 0, let image = UIImage(data: iconData) {
                        cdShowCharacter.setValue(iconData, forKey: "iconData")
                        self.detailImageView.image = image
                    } else {
                        // show nil image placeholder
                        self.detailImageView.image = AppConfiguration.shared.imageNotAvailableSingleton
                        print("Detail Could Not Validate Image Data for \(cdShowCharacter.title!) at \(cdShowCharacter.iconAddress!)")
                    }
                    // stop spinner
                    self.activityIndicator.stopAnimating()
                }
            }
            // store task to compare later
            cdShowCharacter.iconTaskID = detailIconTask.hashValue.description
        }
        // Favorites
        MasterViewController.favoritesSetImagesForButton(self.favButton, character: cdShowCharacter)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.activityIndicator.hidesWhenStopped = true
        self.favButton.addTarget(self, action: #selector(favoritesButtonTapped(sender:event:)), for: .touchUpInside)
        configureView()
    }
}
