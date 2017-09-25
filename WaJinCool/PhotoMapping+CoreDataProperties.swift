//
//  PhotoMapping+CoreDataProperties.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/21.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import Foundation
import CoreData


extension PhotoMapping {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoMapping> {
        return NSFetchRequest<PhotoMapping>(entityName: "PhotoMapping")
    }

    @NSManaged public var recordId: String?
    @NSManaged public var assetId: String?

}
