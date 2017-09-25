//
//  RecordTableViewController.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/13.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit
import os.log
import CoreData
import Photos

class RecordTableViewController: UITableViewController, RecordDetailViewControllerDelegate{
    //MARK: Properties
    let dataManagent = WaJinCoolDataManager.sDataManager
    var records = [Record]()
    var activityIndicatorView: UIActivityIndicatorView?
    
    @IBOutlet weak var addItemButton: UIBarButtonItem!
    @IBOutlet weak var showInfoButton: UIBarButtonItem!
    
    func didSaveRecord(controller: RecordDetailViewController) {
        if let record = controller.record {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing record.
                dataManagent.updateRecord(record: record, index: selectedIndexPath.row)
                
                //records[selectedIndexPath.row] = record
                //tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
                records = dataManagent.records
                tableView.reloadData()
            } else {
                // Add a new record.
                dataManagent.addRecordWithInsert(record: record)
                
                //let newIndexPath = IndexPath(row: records.count, section: 0)
                //records.append(record)
                //tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                records = dataManagent.records
                tableView.reloadData()
            }
        }
    }
    
    func didDeleteRecord(controller: RecordDetailViewController) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // Delete the row from the data source
            dataManagent.deleteRecord(index: selectedIndexPath.row)
            
            records.remove(at: selectedIndexPath.row)
            tableView.deleteRows(at: [selectedIndexPath], with: .fade)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showActivityIndicatorView()
        
        // get records
        if dataManagent.previousYearAndMonth == dataManagent.currentYearAndMonth {
            hideActivityIndicatorView()
            addItemButton.isEnabled = true
            showInfoButton.isEnabled = true
            records = dataManagent.records
        } else {
            dataManagent.records.removeAll()
            records = dataManagent.records
            WaJinCoolServerService.sService.getRecords(yearAndMonth: dataManagent.currentYearAndMonth, callback: didGetRecords)
        }
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
            case "AddItem":
                //recordDetailViewController.delegate = self
                guard let natigationController = segue.destination as? UINavigationController else {
                    fatalError("Unexpected destination A : \(segue.destination)")
                }
            
                guard let recordDetailViewController = natigationController.topViewController as? RecordDetailViewController else {
                    fatalError("Unexpected destination B : \(natigationController.topViewController)")
                }
                
                recordDetailViewController.delegate = self
            case "ShowDetail":
                guard let recordDetailViewController = segue.destination as? RecordDetailViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
            
                guard let selectedRecordlCell = sender as? RecordTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
            
                guard let indexPath = tableView.indexPath(for: selectedRecordlCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
            
                let selectedRecord = records[indexPath.row]
                recordDetailViewController.record = selectedRecord
                recordDetailViewController.delegate = self
            case "ShowInfo":
                break
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RecordTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecordTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RecordTableViewCell.")
        }
        
        let record = records[indexPath.row]
        cell.dateLabel.text = record.date
        cell.moneyLabel.text = "$" + String(record.money)
        cell.categoryLabel.text = record.category
        if let photo = record.photo {
            if record.hasPhoto == true {
                cell.photoImageView.image = photo
            }
        } else {
            cell.photoImageView.image = nil
        }
        
        return cell
    }
    
    @IBAction func showCategoryDetails(_ sender: UIBarButtonItem) {
        hideActivityIndicatorView()
    }
    
    func didGetRecords(recordsContent: [AnyObject]) {
        hideActivityIndicatorView()
        addItemButton.isEnabled = true
        showInfoButton.isEnabled = true
        
        for content in recordsContent {
            let category = content["category"] as! String
            let cateArr = category.components(separatedBy: ".")
            let originalComment = content["comment"] as! String
            let cost = content["cost"] as! Int
            let date = content["date"] as! String
            let id = content["id"] as! String
            
            var photo: UIImage?
            photo = nil
            var hasPhoto = false
            
            var comment = originalComment
            NSLog("==== comment : \(comment)")
            let commentArr = originalComment.components(separatedBy: "..")
            if commentArr.count > 1 {
                comment = commentArr[1]
                if commentArr[0] == "yes" {
                    for mapping in dataManagent.photoMappingDatas {
                        var tmpMapping = nil as PhotoMappingData?
                        if mapping.recordId == id {
                            if (tmpMapping != nil) {
                                // remove
                                dataManagent.deletePhotoMapping(photoMappingData: tmpMapping!)
                            }
                            tmpMapping = mapping
                        
                            // get image by local identifier
                            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [mapping.assetId], options: nil)
                            let asset = assets.firstObject
                            if (asset != nil) {
                                photo = getAssetThumbnail(asset: asset!)
                                hasPhoto = true
                            } else {
                                // remove
                                dataManagent.deletePhotoMapping(photoMappingData: mapping)
                            }
                        }
                    }
                }
            }
            
            let record = Record(id: id, date: date, money: cost, category: String(cateArr[1]), comment: comment, photo: photo, hasPhoto: hasPhoto)
            // add to datamanager
            dataManagent.addRecord(record: record!)
        }
        self.records = dataManagent.records
        tableView.reloadData()
    }
    
    func showActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        activityIndicatorView!.startAnimating()
    }
    
    func hideActivityIndicatorView()  {
        tableView.backgroundView = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        //tableView.reloadData()
        activityIndicatorView!.stopAnimating()
    }
    
    // get PHAsset by local id
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
}
