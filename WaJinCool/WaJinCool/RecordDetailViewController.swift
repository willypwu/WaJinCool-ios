//
//  RecordDetailViewController.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/11.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit
import Photos
import os.log
import CoreData

protocol RecordDetailViewControllerDelegate {
    func didSaveRecord(controller: RecordDetailViewController)
    func didDeleteRecord(controller: RecordDetailViewController)
}

class RecordDetailViewController: UIViewController, UITextFieldDelegate
    , UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource
    , FSCalendarDelegate, FSCalendarDataSource, PhotoViewControllerDelegate{
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    //MARK: Properties
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var moneyTextfield: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var categoryDropDown: UIPickerView!
    @IBOutlet weak var calendar: FSCalendar!
    
    var record: Record?
    var photo: UIImage?
    var hasPhoto = false
    var photoAssetId = ""
    var delegate: RecordDetailViewControllerDelegate! = nil
    var cateList = [String]()
    let dataManager = WaJinCoolDataManager.sDataManager
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load data from datamanager
        cateList = dataManager.categoryAll
        
        // num keyboard
        let numKeyboardToolBar = UIToolbar.init()
        numKeyboardToolBar.sizeToFit()
        let numKeyboardDoneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(numKeyboardDoneClick))
        numKeyboardToolBar.items = [numKeyboardDoneButton] // You can even add cancel button too
        
        dateTextField.delegate = self
        dateTextField.inputView = UIView();
        dateTextField.tintColor = .clear
        moneyTextfield.delegate = self
        moneyTextfield.keyboardType = UIKeyboardType.decimalPad
        moneyTextfield.inputAccessoryView = numKeyboardToolBar
        categoryTextField.delegate = self
        categoryTextField.inputView = UIView();
        categoryTextField.tintColor = .clear
        commentTextField.delegate = self
        
        if let record = record {
            navigationItem.title = record.date
            dateTextField.text = record.date
            moneyTextfield.text = String(record.money)
            categoryTextField.text = record.category
            commentTextField.text = record.comment
            self.photo = record.photo
            hasPhoto = record.hasPhoto
            deleteButton.isEnabled = true
            let cateRow = cateList.index(of: record.category)
            categoryDropDown.selectRow(cateRow!, inComponent: 0, animated: false)
            calendar.select(self.dateFormatter.date(from: record.date))
        } else {
            deleteButton.isEnabled = false
            deleteButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            
            // set default
            let date = Date()
            let today = dateFormatter.string(from: date)
            if (today.contains(dataManager.currentYearAndMonth)) {
                dateTextField.text = dateFormatter.string(from: date)
                calendar.select(calendar.today)
            } else {
                let specificDay = dataManager.currentYearAndMonth + "-01"
                dateTextField.text = specificDay
                calendar.select(self.dateFormatter.date(from: specificDay))
            }
            categoryTextField.text = cateList[0]
        }
    
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
        
        // get image by local identifier
        //let assets = PHAsset.fetchAssets(withLocalIdentifiers: ["7F40E6DE-1ABC-484F-9499-9F71B2E0649B/L0/001"], options: nil)
        //let asset = assets.firstObject
        //let selectedImage = getAssetThumbnail(asset: asset!)
        //photoImageView.image = selectedImage
        //NSLog("asset : \(String(describing: asset))")
    }
    
    @IBAction func clickSave(_ sender: Any) {
        // for has photo ...
        var hasPhotInfo = "no.."
        if self.hasPhoto {
            hasPhotInfo = "yes.."
        }
        
        let date = dateTextField.text ?? ""
        let money:Int = Int(moneyTextfield.text!)!
        let comment = hasPhotInfo + (commentTextField.text ?? "")
        let categoryText = categoryTextField.text ?? ""
        
        var category = ""
        if dataManager.categoryIn.contains(categoryText) {
            category = "in.\(categoryText)"
        } else if dataManager.categoryOut.contains(categoryText) {
            category = "out.\(categoryText)"
        }

        if category == "" {
            return
        }
        
        if self.record == nil {
            WaJinCoolServerService.sService.addRecord(date: date, cost: money, category: category, comment: comment,
                                                      successCallback: didSave, failedCallback: failedSave)
        } else {
            WaJinCoolServerService.sService.updateRecord(id: (self.record?.id)!, date: date, cost: money, category: category, comment: comment, successCallback: didSave, failedCallback: failedSave)
        }
    }
    
    @IBAction func clickDelete(_ sender: Any) {
        showDeleteAlert()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
        
        if (textField == commentTextField) {
            moveTextField(textField, moveDistance: -250, up: true);
        }
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        // get the 4 values and save ...
        updateSaveButtonState()
        
        if (textField == commentTextField) {
            moveTextField(textField, moveDistance: -250, up: false);
        }
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
    
    // category picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countRows: Int = cateList.count
        return countRows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryDropDown {
            let titleRow = cateList[row]
            return titleRow
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryDropDown {
            self.categoryTextField.text = self.cateList[row]
            //self.categoryDropDown.isHidden = true
            categoryTextField.resignFirstResponder()
        }
        updateSaveButtonState()
    }
    
    // calendar pick
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.dateTextField.text = self.dateFormatter.string(from: date)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "ShowPhoto":
            commentTextField.resignFirstResponder()
            
            guard let photoViewController = segue.destination as? PhotoViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            photoViewController.photoImage = self.photo
            photoViewController.record = self.record
            photoViewController.delegate = self
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    func didGetPhoto(photo: UIImage, assetId: String) {
        self.photo = photo
        self.hasPhoto = true
        self.photoAssetId = assetId
    }
    
    //MARK: Private Methods
    func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let dateText = dateTextField.text ?? ""
        let moneyText = moneyTextfield.text ?? ""
        let castegoryText = categoryTextField.text ?? ""
        saveButton.isEnabled = !dateText.isEmpty && !moneyText.isEmpty && !castegoryText.isEmpty
    }
    
    func numKeyboardDoneClick() {
        view.endEditing(true)
    }
    
    func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete Record?",
                                      message: "Deleting this record will also update the data in server.",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.cancel,
                                         handler:{ (action: UIAlertAction) -> Void in
                                            print("UIAlertController action :", action.title ?? "Cancel");
        })
        let destructiveAction = UIAlertAction(title: "Delete",
                                              style: UIAlertActionStyle.destructive,
                                              handler:{ (action: UIAlertAction) -> Void in
                                                self.doDeleteRecord();
        })
        
        alert.addAction(cancelAction);
        alert.addAction(destructiveAction);
        present(alert, animated: true, completion: {
            print("UIAlertController present");
        })
    }
    
    func doDeleteRecord()  {
        WaJinCoolServerService.sService.deleteRecord(id: (self.record?.id)!, successCallback: didDeleteRecord, failedCallback: failedDeleteRecord)
    }
    
    func didDeleteRecord()  {
        self.navigationController?.popViewController(animated: true)
        delegate.didDeleteRecord(controller: self)
    }
    
    func failedDeleteRecord()  {
        let alert = UIAlertController(title: "Save Delete",
                                      message: "Delete this record failed .",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let doneAction = UIAlertAction(title: "Done",
                                       style: UIAlertActionStyle.cancel,
                                       handler:{ (action: UIAlertAction) -> Void in
                                        print("UIAlertController action :", action.title ?? "Done");
        })
        
        alert.addAction(doneAction);
        present(alert, animated: true, completion: {
            print("UIAlertController present");
        })
    }

    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = up ? 0.35 : 0.2
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func didSave(id: String, date: String, money: String, category: String, comment: String) {
        // save photo mapping to db(core data)
        let photo = self.photo
        dataManager.addPhotoMapping(id: id, photoAssetId: self.photoAssetId)
        NSLog("====@@@ comment : \(comment)")
        let commentArr = comment.components(separatedBy: "..")
        
        // Set the record to be passed to RecordTableViewController after the unwind segue.
        record = Record(id: id, date: date, money: Int(money)!, category: category, comment: commentArr[1], photo: photo, hasPhoto: hasPhoto)
        
        // TODO server part
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
            delegate.didSaveRecord(controller: self)
        } else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
            delegate.didSaveRecord(controller: self)
        }
    }
    
    func failedSave() {
        let alert = UIAlertController(title: "Save Failed",
                                      message: "Save this record failed .",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let doneAction = UIAlertAction(title: "Done",
                                         style: UIAlertActionStyle.cancel,
                                         handler:{ (action: UIAlertAction) -> Void in
                                            print("UIAlertController action :", action.title ?? "Done");
        })
        
        alert.addAction(doneAction);
        present(alert, animated: true, completion: {
            print("UIAlertController present");
        })
    }
}

