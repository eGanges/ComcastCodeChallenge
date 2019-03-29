//
//  WebClient.swift
//  ComcastCodeChallenge
//
//  Created by Edward C Ganges on 1/22/19.
//  Copyright © 2019 Edward C Ganges. All rights reserved.
//

import Foundation

// JSON type
typealias JSON = [String: Any?]
typealias JSONParams = [String: String]

// WEB CLIENT
enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension URL {
    init (baseUrl: String, path: String, params: JSONParams, method: RequestMethod) {
        var components = URLComponents(string: baseUrl)!
        components.path += path
        
        switch method {
        case .get, .delete: // aka GET request types
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        default:
            break
        }
        self = components.url!
    }
}

extension URLRequest {
    init(baseUrl: String, path: String, method: RequestMethod, params: JSONParams) {
        let url = URL(baseUrl: baseUrl, path: path, params: params, method: method)
        self.init(url:url)
        
        httpMethod = method.rawValue
        setValue("application/json", forHTTPHeaderField: "Accept")
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        switch method {
        case .put, .post:
            httpBody = try! JSONSerialization.data(withJSONObject: params, options:[])
        default:
            break
        }
    }
}

public class WebClient {
    private var baseUrl: String
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func load(path: String, method: RequestMethod, params: JSONParams, completion: @escaping (Any?, ServiceError?) -> ()) -> URLSessionDataTask? {
        // conncected?
        if !Reachability.isConnectedToNetwork() {
            completion(nil, ServiceError.noInternetConnection)
            return nil
        }
        
        let request = URLRequest(baseUrl: baseUrl, path: path, method: method, params: params)
        print("request: \(request)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Parse incoming data
            var object: Any? = nil
            if let data = data {
                object = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSON
            }
            if let httpResponse = response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode {
                completion(object, nil)
            } else {
                let error = (object as? JSON).flatMap(ServiceError.init) ?? ServiceError.other
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}
