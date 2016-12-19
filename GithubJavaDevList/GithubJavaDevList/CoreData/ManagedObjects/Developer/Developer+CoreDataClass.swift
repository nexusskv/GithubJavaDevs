//
//  Developer+CoreDataClass.swift
//  GithubJavaDevList
//
//  Created by Rost on 17.12.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

import Foundation
import CoreData
import AERecord
import SwiftyJSON


@objc(Developer)
public class Developer: NSManagedObject {

    
    /// ---> Save object <--- ///
    
    class func saveObject(json: JSON) -> Developer? {
        var devObject: Developer? = nil
        
        if let devId = json["id"].int64 {
            devObject = self.createOrGet(id: devId) 
        }
        
        guard let resultObject = devObject else {
            return devObject
        }

        if let details = json["url"].string {
            resultObject.details_url = details
        }
        
        if let name = json["name"].string {
            resultObject.name = name
        }
        
        if let email = json["email"].string {
            resultObject.email = email
        }
        
        if let avatar = json["avatar_url"].string {
            resultObject.avatar = avatar
        }
        
        if let date = json["created_at"].string {
            let cropZ = date.replacingOccurrences(of: "Z", with: "", options: .literal, range:nil)
            let cropT = cropZ.replacingOccurrences(of: "T", with: " ", options: .literal, range:nil)
            
            resultObject.reg_date = cropT
        }
        
        if let company = json["company"].string {
            resultObject.company = company
        }
        
        if let followers = json["followers"].int64 {
            resultObject.followers = String(format: "%lld", followers)
        }
        
        if let following = json["following"].int64 {
            resultObject.following = String(format: "%lld", following)
        }
        
        if let location = json["location"].string {
            resultObject.location = location
        }
        
        if let blog = json["blog"].string {
            resultObject.blog = blog
        }
        
        if let publicRepos = json["public_repos"].int64 {
            resultObject.public_repos = String(format: "%lld", publicRepos)
        }
        
        if let publicGists = json["public_gists"].int64 {
            resultObject.public_gists = String(format: "%lld", publicGists)
        }

  
        AERecord.saveContextAndWait()
        
        return resultObject
    }
    
    
    /// ---> Creator and Getter <--- ///
    
    class func createOrGet(id: Int64) -> Developer? {
        if let object = Developer.firstWithAttribute(attribute: "id", value: id as AnyObject) {
            return object
        } else {
            return Developer.createWithAttributes(attributes: ["id": id as AnyObject])
        }
    }
}
