//
//  ViewController.swift
//  Academic Officer
//
//  Created by Evan Delvaux on 9/5/18.
//  Copyright © 2018 Evan Delvaux. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Task lists
    
    let dailyTasks = ["Check ESP",]
    
    let weeklyTasks = ["Lates & absences",
                       "Check tutoring progress",
                       "Notify deficiencies",
                       "Inspect study room",]
    
    let monthlyTasks = ["Get periodic GPAs",
                        "Counsel NCO",]
    
    
    // Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        //print(cell?.textLabel?.text) // for testing
        
        //Toggles checkmark next to task
        if cell?.accessoryType == UITableViewCellAccessoryType.none {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else { cell?.accessoryType = UITableViewCellAccessoryType.none }
    }
    
    
    // Table View Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dailyTasks.count
        case 1:
            return weeklyTasks.count
        case 2:
            return monthlyTasks.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = dailyTasks[indexPath.row]
        case 1:
            cell.textLabel?.text = weeklyTasks[indexPath.row]
        case 2:
            cell.textLabel?.text = monthlyTasks[indexPath.row]
        default:
            cell.textLabel?.text = "This shouldn't happen"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Daily Tasks (\(String(dailyTasks.count)))"
        case 1:
            return "Weekly Tasks (\(String(weeklyTasks.count)))"
        case 2:
            return "Monthly Tasks (\(String(monthlyTasks.count)))"
        default:
            return nil
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

