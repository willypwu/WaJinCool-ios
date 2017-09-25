//
//  Record.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/14.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit

class Record {
    
    //MARK: Properties
    var id: String
    var date: String
    var money: Int
    var category: String
    var comment: String?
    var photo: UIImage?
    var hasPhoto: Bool
    var day: Int?
    
    //MARK: Initialization
    init?(id: String, date: String, money: Int, category: String, comment: String?, photo: UIImage?, hasPhoto: Bool) {
        if date.isEmpty || money < 0 || category.isEmpty {
            return nil
        }
        
        self.id = id
        self.date = date
        self.money = money
        self.category = category
        self.comment = comment
        self.photo = photo
        self.hasPhoto = hasPhoto
        
        let start = date.index(date.endIndex, offsetBy: -2)
        let end   = date.index(date.endIndex, offsetBy: 0)
        let range = Range(start..<end)
        day = Int(date.substring(with: range))
    }
}
