//
//  ApiConnector.swift
//  GithubJavaDevList
//
//  Created by Rost on 16.12.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

import Foundation
import SwiftHTTP
import SwiftyJSON


let apiUrl      = "https://api.github.com"
let javaUsers   = "search/users?q=language:java&sort=stars&order=desc&page"
let detailUser  = "users"

let clientId    = "37598b40f21ca8ad12d1"
let cs          = "6a772f93f77655941d2f088ab6c97f2a2dffa31a"


class ApiConnector {
    var resultsCount: Int = 0
    
    
    /// ---> Shared Instance <--- ///
    
    static let shared : ApiConnector = {
        let instance = ApiConnector()
        
        return instance
    } ()
    
    
    /// ---> Function for load data from API <--- ///
    
    func sendRequest(method: HTTPVerb,
                     completion: ((_ response: AnyObject) -> Void)?) {
        
        var requestUrl = ""

        if let currentPage = Page.first() {
            let startPage   = currentPage.start_page
            
            requestUrl = String(format: "%@/%@=%d&per_page=10&client_id=%@", apiUrl, javaUsers, startPage, clientId)
        } else {
            return
        }

        let requestSerializer: HTTPSerializeProtocol = JSONParameterSerializer()
        
        do {
            let opt = try HTTP.New(requestUrl,
                                   method: method,
                                   parameters: nil,
                                   headers: nil,
                                   requestSerializer: requestSerializer)
            
            var attempted = false           // override SSL
            
            opt.auth = {
                challenge in
                
                if !attempted {
                    attempted = true
                    return URLCredential(trust: challenge.protectionSpace.serverTrust!)
                }
                
                return nil
            }
            
            opt.start { response in
                if let error = response.error {
                    print("got an error: \(error)")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as! NSDictionary
                    
                    if let totalCount = json["total_count"] {
                        let totalValue = ["total_count": totalCount]
                        _ = Page.saveObject(values: totalValue as! Dictionary<String, Int64>)
                        
                        let currentPages = Page.first()
                        
                        var startPage   = -1
                        
                        if var start   = currentPages?.start_page {
                            start   += Int64(1)
                            startPage = Int(start)
                        }
                        
                        let pageValues = ["start_page": Int64(startPage)]
                        _ = Page.saveObject(values: pageValues)
                    }
                    
                    let devObjects = json["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    let count           = devObjects.count
                    self.resultsCount   = 0
                    
                    if count > 0 {
                        for developer in devObjects {
                            if let url = developer["url"] as? String {
                                self.loadDetails(link: url, completion: { result in
                                    if (result as? String) != nil {
                                        completion!(result as AnyObject)
                                        return
                                        
                                    } else if (result as? Bool) != nil {
                                        self.resultsCount += 1
                                        
                                        if self.resultsCount == count {
                                            completion!(true as AnyObject)
                                        }
                                    }
                                })
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Parse received json error -> %@", error)
                    
                    completion!(error.localizedDescription as AnyObject)
                }
            }
        } catch let error {
            print("Received error on try to send request to api: \(error)")
        }
    }
    
    
    /// ---> Fucntion for download a details of developer  <--- ///
    
    func loadDetails(link: String,
                           completion: ((_ result: AnyObject) -> Void)?) {
        let authLink = String(format: "%@?client_id=%@&client_secret=%@", link, clientId, cs)

        guard let url = URL(string: authLink) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("application/json"),
                let data = data, error == nil
                
                else {  if (error?.localizedDescription) != nil {
                            print((error?.localizedDescription)! as String)
                        }
                        return
                }
            
            
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                    
                    if json.count > 0 {
                        let saveObject = JSON(object: json)

                        _ = Developer.saveObject(json: saveObject)
                        
                        completion!(true as AnyObject)
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                    
                    completion!(error.localizedDescription as AnyObject)
                }
            }.resume()
    }
}


/// ---> Extension for download image asyncronously <--- ///

public extension UIImageView {
    func downloadedImage(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        
        guard let url = URL(string: link) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
                DispatchQueue.main.async() { () -> Void in
                    self.image = image
                }
            }.resume()
    }
}
