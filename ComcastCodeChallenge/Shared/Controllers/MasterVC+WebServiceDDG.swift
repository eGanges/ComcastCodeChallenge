//
//  MasterVC+WebServiceDDG.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/31/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension MasterViewController {
    // MARK - Web Service - Duck Duck Go
    
    func webServiceLoadShowCharacterData(completion: @escaping (ServiceError?) ->()) {
        // Begin Web Service API call to load the data
        showCharacterTask = ShowCharacterService().loadRecords(forShow: AppConfiguration.shared.appWebServiceName, completion: { [weak self] showCharacters, error in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            }
            else if let showCharacters = showCharacters {
                // move results to managed object context
                for showCharacter in showCharacters {
                    if let title = showCharacter.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if let cdShowCharacter = self?.insertNewObject(showCharacter) {
                            // also store to non-persistant cache
                            self?.cdShowCharacters.append(cdShowCharacter)
                        }
                    }
                }
            }
            completion(nil)
        })
    }
    
    @objc
    func insertNewObject(_ object: Any) -> NSManagedObject? {
        guard let showCharacter = object as? ShowCharacter else {
            return nil
        }
        let context = self.fetchedResultsController.managedObjectContext
        let cdShowCharacter = CDShowCharacter(context: context)
        
        // If appropriate, configure the new managed object.
        cdShowCharacter.setValue(showCharacter.title, forKey: "title")
        cdShowCharacter.setValue(showCharacter.details, forKey: "details")
        cdShowCharacter.setValue(showCharacter.linkAddress, forKey: "linkAddress")
        cdShowCharacter.setValue(showCharacter.iconAddress, forKey: "iconAddress")
        cdShowCharacter.setValue(false, forKey: "isFavorite")
        
        // async append image data
        _ = getImageDataForCDShowCharacter(cdShowCharacter, context: context) { taskID, success, error in
            if (success) {
                DispatchQueue.main.async {
                    _ = AppDelegate.shared?.saveContextForManagedObject(cdShowCharacter)
                }
            }
        }
        
        // Save the context.
        if Thread.isMainThread {
            _ = AppDelegate.shared?.saveContextForManagedObject(cdShowCharacter)
        } else {
            DispatchQueue.main.async {
                _ = AppDelegate.shared?.saveContextForManagedObject(cdShowCharacter)
            }
        }
        return cdShowCharacter
    }
    
    func getImageDataForCDShowCharacter(_ cdShowCharacter: CDShowCharacter, context: NSManagedObjectContext, completion: @escaping(String?, Bool, Error?) -> ()) -> URLSessionDataTask? {
        // manage getting the image data into core data here
        // retrieves the data
        // tracks the task so that it can be matched after async calls in the Cells
        
        guard let iconAddress = cdShowCharacter.iconAddress else  {
            print("ABORTING Image Data for task \(cdShowCharacter.iconTaskID ?? "nil task") at \(cdShowCharacter.iconAddress!)")
            completion(cdShowCharacter.iconTaskID, false, nil)
            return nil
        }
        print("Attempting Image Data for \(cdShowCharacter.title!) at \(cdShowCharacter.iconAddress!)")
        let iconTask = ShowCharacterService().getImageDataAtWebAddress(iconAddress) { (data, error) in
            var success = false
            let curTask = cdShowCharacter.iconTaskID
            cdShowCharacter.setNilValueForKey("iconTaskID")
            
            // if data makes a valid image, update and save
            if let iconData = data, iconData.count > 0, let _ = UIImage(data: iconData) {
                cdShowCharacter.setValue(iconData, forKey: "iconData")
                success = true
            } else {
                print("Could Not Validate Image Data for \(cdShowCharacter.title!) at \(cdShowCharacter.iconAddress!)")
            }
            
            // complete
            completion(curTask, success, error)
        }
        cdShowCharacter.setValue(iconTask.hashValue.description, forKey: "iconTaskID")
        iconTask?.resume()
        return iconTask
    }
}
