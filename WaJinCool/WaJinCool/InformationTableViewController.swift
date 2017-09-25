//
//  InformationTableViewController.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/20.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit

class InformationTableViewController: UITableViewController {

    let dataManagent = WaJinCoolDataManager.sDataManager
    var infos = [KeyValuePair]()
    var incomes = [KeyValuePair]()
    var expenses = [KeyValuePair]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = dataManagent.currentYearAndMonth + "-Information"
        calculateAllInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    @IBAction func clickBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
            case 0:
                return infos.count
            case 1:
                return incomes.count
            case 2:
                return expenses.count
            default:
                return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "InformationTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InformationTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RecordTableViewCell.")
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        switch indexPath.section {
        case 0:
            cell.keyLabel.text = infos[indexPath.row].key
            cell.valueLabel.text = String(infos[indexPath.row].value)
            break
        case 1:
            cell.keyLabel.text = incomes[indexPath.row].key
            cell.valueLabel.text = String(incomes[indexPath.row].value)
            break
        case 2:
            cell.keyLabel.text = expenses[indexPath.row].key
            cell.valueLabel.text = String(expenses[indexPath.row].value)
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Info"
            case 1:
                return "Income"
            case 2:
                return "Expense"
            default:
                return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 35
        } else {
            return 18
        }
    }
    
    func calculateAllInfo() {
        // init
        infos.append(KeyValuePair(key: "本月尚餘", value: 0))
        infos.append(KeyValuePair(key: "本月總收入", value: 0))
        infos.append(KeyValuePair(key: "本月總支出", value: 0))
        for ci in dataManagent.categoryIn {
            incomes.append(KeyValuePair(key: ci, value: 0))
        }
        for co in dataManagent.categoryOut {
            expenses.append(KeyValuePair(key: co, value: 0))
        }
        
        var totalIncome = 0
        var totalExpense = 0
        for record in dataManagent.records {
            if dataManagent.categoryIn.contains(record.category) {
                for kvp in incomes {
                    if kvp.key == record.category {
                        kvp.value = kvp.value + record.money
                        totalIncome = totalIncome + record.money
                        break
                    }
                }
            } else if dataManagent.categoryOut.contains(record.category) {
                for kvp in expenses {
                    if kvp.key == record.category {
                        kvp.value = kvp.value + record.money
                        totalExpense = totalExpense + record.money
                        break
                    }
                }
            }
        }
        
        infos[0].value = totalIncome - totalExpense
        infos[1].value = totalIncome
        infos[2].value = totalExpense
    }
    
    class KeyValuePair {
        var key: String
        var value: Int
        
        init(key: String, value: Int) {
            self.key = key
            self.value = value
        }
    }
}
