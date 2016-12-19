//
//  Developer+CoreDataProperties.swift
//  GithubJavaDevList
//
//  Created by Rost on 17.12.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

import Foundation
import CoreData


extension Developer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Developer> {
        return NSFetchRequest<Developer>(entityName: "Developer");
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var details_url: String?
    @NSManaged public var company: String?
    @NSManaged public var email: String?
    @NSManaged public var avatar: String?
    @NSManaged public var reg_date: String?
    @NSManaged public var followers: String?
    @NSManaged public var following: String?
    @NSManaged public var location: String?
    @NSManaged public var blog: String?    
    @NSManaged public var public_repos: String?
    @NSManaged public var public_gists: String?

}
