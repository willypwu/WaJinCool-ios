//
//  CategoryTableViewController.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/20.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit

class CategoryTableViewController: UITableViewController {

    var cateInfoList = [CategoryInfo]()
    let dataManager = WaJinCoolDataManager.sDataManager
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem
        
        var toolBarItems = [UIBarButtonItem]()
        let systemButton1 = UIBarButtonItem(title: "New [Income]", style: .plain, target: self, action: #selector(self.clickIncome))
        toolBarItems.append(systemButton1)
        let systemButton2 = UIBarButtonItem(title: "New [expense]", style: .plain, target: self, action: #selector(self.clickExpense))
        toolBarItems.append(systemButton2)
        self.setToolbarItems(toolBarItems, animated: true)
        
        setupCategoryList()
        
    }

    @IBAction func clickBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
        
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.navigationController?.isToolbarHidden = false
        } else {
            self.navigationController?.isToolbarHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cateInfoList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CategoryTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CategoryTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RecordTableViewCell.")
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let categoryInfo = cateInfoList[indexPath.row]
        if categoryInfo.type == "in" {
            cell.typeLabel.text = "[收入]"
        } else if categoryInfo.type == "out" {
            cell.typeLabel.text = "[支出]"
        }
        cell.categoryLabel.text = categoryInfo.label
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO delete from server
            WaJinCoolServerService.sService.deleteCategory(failedCallback: failedDeleteCategory)
            //let cateInfo = cateInfoList[indexPath.row]
            //dataManager.removeCategory(type: cateInfo.type, cate: cateInfo.label)
           
            
            // Delete the row from the data source
            //cateInfoList.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func clickIncome()  {
        let alertController = UIAlertController(title: "New Income Category", message: "Please input category:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                self.addCategory(type: "in", cate: field.text!)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Category"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func clickExpense() {
        let alertController = UIAlertController(title: "New Expense Category", message: "Please input category:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                self.addCategory(type: "out", cate: field.text!)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Category"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addCategory(type: String, cate: String) {
        WaJinCoolServerService.sService.addCategory(type: type, cate: cate, successCallback: didAddCategory, failedCallback: failedAddCategory)
    }
    
    func didAddCategory(type: String, cate: String) {
        if cate != nil && cate != "" {
            dataManager.addCategory(type: type, cate: cate)
        }
        
        setupCategoryList()
        tableView.reloadData()
    }
    
    func failedAddCategory() {
        let alert = UIAlertController(title: "Add Failed",
                                      message: "Add this category failed .",
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
    
    func failedDeleteCategory() {
        let alert = UIAlertController(title: "Delete Failed",
                                      message: "Delete this category failed .",
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
    
    func setupCategoryList() {
        cateInfoList.removeAll()
        for ci in dataManager.categoryIn {
            cateInfoList.append(CategoryInfo(type: "in", label: ci))
        }
        for co in dataManager.categoryOut {
            cateInfoList.append(CategoryInfo(type: "out", label: co))
        }
    }

    class CategoryInfo {
        var type: String
        var label: String
        
        init(type: String, label: String) {
            self.type = type
            self.label = label
        }
    }
}
