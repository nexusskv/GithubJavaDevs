//
//  Page+CoreDataProperties.swift
//  
//
//  Created by Rost on 18.12.16.
//
//

import Foundation
import CoreData


extension Page {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page");
    }

    @NSManaged public var id: Int64
    @NSManaged public var total_count: Int64
    @NSManaged public var start_page: Int64

}
