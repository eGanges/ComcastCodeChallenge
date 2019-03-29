//
//  ShowCharacterService.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/22/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation
import CoreData

// SERVICE
public class ShowCharacterService {
    // create a request client, setting the base URL for this service,
    private let client = WebClient(baseUrl: "https://api.duckduckgo.com")
    private let path = "/"
    
    @discardableResult
    func loadRecords(forShow showName: String, completion: @escaping ([ShowCharacter]?, ServiceError?) ->()) -> URLSessionDataTask? {
        
        // set service specific parameters
         let params: JSONParams = ["q": "\(showName)+characters", "format": "json"]
        
        // add common (authentication?) parameters,
        // for instance:
        // if let token = KeychainWrapper.itemForKey("application_token") {
        //    params["token"] = token
        // }


        // pass specific url and params to webClient
        return client.load(path: path, method: .get, params: params, completion: { result, error in
            
            // parse response from desired json component into objects/models and return to application
            if let json = result as? JSON, let relatedTopics = json["RelatedTopics"] as? Array<[String: Any?]> {
                completion(relatedTopics.compactMap(ShowCharacter.init), error)
            } else {
                print("RelatedTopics not found in result: \(result ?? "nil")")
                completion(nil, error)
            }
        })
    }
    
    func getImageDataAtWebAddress(_ urlString: String, completion: @escaping(Data?, Error?) -> ()) -> URLSessionDataTask? {
        guard var fileType = urlString.components(separatedBy: ".").last,
            ["gif", "jpeg", "jpg", "png", "bmp"].contains(fileType.lowercased()),
            let url = URL(string: urlString)
            else {
                completion(nil, nil)
                return nil
        }
        
        if fileType == "jpg" {
            fileType = "jpeg"
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "get"
        urlRequest.setValue("image/\(fileType)", forHTTPHeaderField: "Accept")
        urlRequest.setValue("image/\(fileType)", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data, let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode {
                // we are done
                completion(data, nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }

}

// Tests
