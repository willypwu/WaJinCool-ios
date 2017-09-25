//
//  WaJinCoolDataManager.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/18.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import Foundation
import CoreData

class WaJinCoolDataManager : NSObject{
    
    static var sDataManager = WaJinCoolDataManager()

    override init() {
        super.init()
        getPhotoMappings()
    }
    
    // category
    var categoryOut = [String]()
    var categoryIn = [String]()
    var categoryAll = [String]()
    
    func setupCategoryAll() {
        categoryAll.removeAll()
        for ci in categoryIn {
            categoryAll.append(ci)
        }
        for co in categoryOut {
            categoryAll.append(co)
        }
    }
    
    func removeCategory(type: String, cate: String) {
        if type == "in" {
            if let index = categoryIn.index(of: cate) {
                categoryIn.remove(at: index)
            }
        } else if type == "out" {
            if let index = categoryOut.index(of: cate) {
                categoryOut.remove(at: index)
            }
        }
        if let index = categoryAll.index(of: cate) {
            categoryAll.remove(at: index)
        }
    }
    
    func addCategory(type: String, cate: String) {
        if type == "in" {
            categoryIn.append(cate)
        } else if type == "out" {
            categoryOut.append(cate)
        }
        self.setupCategoryAll()
    }
    
    // year and month list for main page
    var yearMonthList = [
        "2017-07", "2017-08","2017-09", "2017-10", "2017-11", "2017-12"
        , "2018-01", "2018-02", "2018-03", "2018-04", "2018-05", "2018-06"
        , "2018-07", "2018-08", "2018-09", "2018-10", "2018-11", "2018-12"
        , "2019-01", "2019-02", "2019-03", "2019-04", "2019-05", "2019-06"
        , "2019-07", "2019-08", "2019-09", "2019-10", "2019-11", "2019-12"
        , "2020-01", "2020-02", "2020-03", "2020-04", "2020-05", "2020-06"
        , "2020-07", "2020-08", "2020-09", "2020-10", "2020-11", "2020-12"
        , "2021-01", "2021-02", "2021-03", "2021-04", "2021-05", "2021-06"
        , "2021-07", "2021-08", "2021-09", "2021-10", "2021-11", "2021-12"
        , "2022-01", "2022-02", "2022-03", "2022-04", "2022-05", "2022-06"
        , "2022-07", "2022-08", "2022-09", "2022-10", "2022-11", "2022-12"]
    var previousYearAndMonth = ""
    var currentYearAndMonth = ""
    
    // records
    var records = [Record]()
    
    func addRecord(record : Record) {
        records.append(record)
        // sort
        records.sort(by: { $0.day! > $1.day! })
    }
    
    func addRecordWithInsert(record : Record) {
        records.insert(record, at: 0)
    }
    
    func saveRecord(record : Record) {
        addRecord(record: record)
    }
    
    func updateRecord(record : Record, index : Int) {
        let origianlRecord = records[index]
        origianlRecord.category = record.category
        origianlRecord.comment = record.comment
        origianlRecord.date = record.date
        origianlRecord.hasPhoto = record.hasPhoto
        origianlRecord.money = record.money
        origianlRecord.photo = record.photo
        origianlRecord.day = record.day
        // sort
        records.sort(by: { $0.day! > $1.day! })
    }
    
    func deleteRecord(index : Int) {
        records.remove(at: index)
    }
    
    // photo mapping
    var photoMappingDatas = [PhotoMappingData]()
    func getPhotoMappings(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoMapping")
        do {
            let searchResults = try getContext().fetch(fetchRequest)
            print("numbers of \(searchResults.count)")
            for p in (searchResults as! [NSManagedObject]){
                let photoMappingData = PhotoMappingData(recordId: p.value(forKey: "recordId")! as! String, assetId: p.value(forKey: "assetId")! as! String)
                photoMappingDatas.append(photoMappingData)
            }
        } catch  {
            print(error)
        }
    }
    
    func addPhotoMapping(id: String, photoAssetId: String) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "PhotoMapping", in: context)
        let photoMapping = NSManagedObject(entity: entity!, insertInto: context)
        photoMapping.setValue(id, forKey: "recordId")
        photoMapping.setValue(photoAssetId, forKey: "assetId")
        do {
            try context.save()
        }catch{
            print(error)
        }

    }
    
    func deletePhotoMapping(photoMappingData: PhotoMappingData) {
        // memory
        if let index = photoMappingDatas.index(where: { $0.recordId == photoMappingData.recordId }) {
            photoMappingDatas.remove(at: index)
        }
        
        // DB
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoMapping")
        do {
            let searchResults = try getContext().fetch(fetchRequest)
            print("numbers of \(searchResults.count)")
            for p in (searchResults as! [NSManagedObject]){
                if photoMappingData.recordId == p.value(forKey: "recordId") as! String {
                    getContext().delete(p)
                    break
                }
            }
        } catch  {
            print(error)
        }
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
