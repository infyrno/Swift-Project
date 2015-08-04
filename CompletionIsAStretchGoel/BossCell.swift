//
//  BossCell.swift
//  CompletionIsAStretchGoel
//
//  Created by cisstudents on 6/10/15.
//  Copyright (c) 2015 MuscleManish. All rights reserved.
//

import UIKit

class BossCell: UITableViewCell {
    
    @IBOutlet var ButObj: UIButton!
    @IBOutlet var SwObj: UISwitch!
    @IBOutlet var PlsObj: UIStepper!
    
    var Outlets : [String] = ["ButObj", "SwObj", "PlsObj"]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func buttonPress(sender: AnyObject) {
    }
}
