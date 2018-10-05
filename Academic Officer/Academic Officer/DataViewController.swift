//
//  DataViewController.swift
//  Academic Officer
//
//  Created by Evan Delvaux on 9/5/18.
//  Copyright © 2018 Evan Delvaux. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Data sections
    
    let section0 = ["Failed ESP Check",]
    
    @IBOutlet weak var failCount: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
    @IBAction func failCounter(_ sender: Any) {
        failCount.text = String(Int(stepper.value))
    }
    @IBAction func resetButton(_ sender: Any) {
        stepper.value = Double(0)
        failCounter(0)
    }
    
    // Table view data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return section0.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = section0[indexPath.row]
        default:
            cell.textLabel?.text = "This shouldn't happen"
        }
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
