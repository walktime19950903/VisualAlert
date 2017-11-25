//
//  TODO+CoreDataProperties.swift
//  VisualAlert
//
//  Created by ryousuke on 2017/11/21.
//  Copyright © 2017年 ryousuke Takahashi. All rights reserved.
//
//

import Foundation
import CoreData


extension TODO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TODO> {
        return NSFetchRequest<TODO>(entityName: "TODO")
    }

    @NSManaged public var memo: String?
    @NSManaged public var image: URL?
    @NSManaged public var kurikaeshi: NSDate?
    @NSManaged public var sunuzu: String?
    @NSManaged public var color: String?
    @NSManaged public var time: NSDate?

}
