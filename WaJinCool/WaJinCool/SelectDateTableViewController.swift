//
//  SelectDateTableViewController.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/14.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit

class SelectDateTableViewController: UITableViewController {

    var dates = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initAllDates()
        
        // TODO move to current month
        //moveToSpecificPosition(position: 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SelectDateTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SelectDateTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SelectDateTableViewCell.")
        }
        
        cell.dateLabel.text = dates[indexPath.row]
        return cell
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let recordTableViewController = segue.destination as? RecordTableViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectDateTableViewCell = sender as? SelectDateTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectDateTableViewCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let date = dates[indexPath.row]
        recordTableViewController.navigationItem.title = date
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initAllDates() {
        dates += ["2017-09", "2017-10", "2017-11", "2017-12"
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
    }

    func moveToSpecificPosition(position: Int) {
        let textIndexPath = IndexPath(row: position, section: 0)
        self.tableView.scrollToRow(at: textIndexPath, at: .top, animated: false)
    }
}
