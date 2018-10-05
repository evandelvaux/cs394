//
//  ViewController.swift
//  The Night Porter
//
//  Created by Evan Delvaux on 8/31/18.
//  Copyright © 2018 Evan Delvaux. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var myTask: UILabel!
    
    @IBAction func lowerImportance(_ sender: Any) {
        myTask.text = "Less important task"
    }
    
    @IBAction func changeBackground(_ sender: Any) {
        view.backgroundColor = UIColor.darkGray
        
        let everything = view.subviews
        
        for eachView in everything {
            if eachView is UILabel {
                let currentLabel = eachView as! UILabel
                currentLabel.textColor = UIColor.white
            }
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

