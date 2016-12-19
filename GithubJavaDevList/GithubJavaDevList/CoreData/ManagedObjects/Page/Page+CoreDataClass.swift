//
//  Page+CoreDataClass.swift
//  
//
//  Created by Rost on 18.12.16.
//
//

import Foundation
import CoreData
import AERecord
import SwiftyJSON


@objc(Page)
public class Page: NSManagedObject {

    
    /// ---> Save object function <--- ///
    
    class func saveObject(values: Dictionary<String, Int64>) -> Page? {
        var pageObject: Page? = nil
        
        let recordId = 1
        pageObject = self.createOrGet(id: Int64(recordId))

        
        guard let resultObject = pageObject else {
            return pageObject
        }

        if let totalCount = values["total_count"] {
            resultObject.total_count = totalCount
        }
        
        if let startPage = values["start_page"] {
            resultObject.start_page = startPage
        }
        
        AERecord.saveContextAndWait()
        
        return resultObject
    }
    
    
    /// ---> Creator and Getter <--- ///
    
    class func createOrGet(id: Int64) -> Page? {
        if let object = Page.firstWithAttribute(attribute: "id", value: id as AnyObject) {
            return object
        } else {
            return Page.createWithAttributes(attributes: ["id": id as AnyObject])
        }
    }
    
}
