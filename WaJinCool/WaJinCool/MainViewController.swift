//
//  MainViewController.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/15.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate
    , UIPickerViewDelegate, UIPickerViewDataSource, UIWebViewDelegate {
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var dateDropDow: UIPickerView!
    @IBOutlet weak var signInWebView: UIWebView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var dateList = [String]()
    let dataManagent = WaJinCoolDataManager.sDataManager
    
    override func loadView() {
        super.loadView()
        activityIndicatorView.startAnimating()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
               
        // init and load from datamanager
        dateList = dataManagent.yearMonthList
        
        // date
        let yearMonth = self.dateFormatter.string(from: Date())
        let indexOfToday = dateList.index(of: yearMonth)
        dateTextField.delegate = self
        dateTextField.inputView = UIView();
        dateTextField.tintColor = .clear
        dateTextField.text = dateList[indexOfToday!]
        dateDropDow.selectRow(2, inComponent: 0, animated: false)
        
        
        // login
        var hasSACSID = false
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if "SACSID" == cookie.name {
                    hasSACSID = true
                    NSLog("cookie : \(cookie)")
                    break
                }
            }
        }
        if (!hasSACSID) {
            let url = URL(string: "https://wajincool.appspot.com/")
            if let unwrappedUrl = url {
                signInWebView.isHidden = false
                let request = URLRequest(url: unwrappedUrl)
                signInWebView.loadRequest(request)
            }
        } else {
            WaJinCoolServerService.sService.getCategories(callback: didGetCategories)
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
            
        case "ShowAllRecords":
            dataManagent.previousYearAndMonth = dataManagent.currentYearAndMonth
            dataManagent.currentYearAndMonth = dateTextField.text!
            guard let recordTableViewController = segue.destination as? RecordTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            recordTableViewController.navigationItem.title = dateTextField.text
        case "EditCatgory":
            break
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // category picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         let countRows: Int = dateList.count
        return countRows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let titleRow = dateList[row]
        return titleRow
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.dateTextField.text = self.dateList[row]
        dateTextField.resignFirstResponder()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if "SACSID" == cookie.name {
                    webView.isHidden = true
                    WaJinCoolServerService.sService.getCategories(callback: didGetCategories)
                    break
                }
            }
        }
    }
    
    func didGetCategories(categories: [String]) {
        activityIndicatorView.stopAnimating()
        editButton.isEnabled = true
        dateDropDow.isHidden = false
        for cate in categories {
            let cateArr = cate.components(separatedBy: ".")
            if "in" == cateArr[0] {
                dataManagent.categoryIn.append(String(cateArr[1]))
            } else if "out" == cateArr[0] {
                dataManagent.categoryOut.append(String(cateArr[1]))
            }
        }
        dataManagent.setupCategoryAll()
    }
}
