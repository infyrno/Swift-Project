//  VictoryController.swift
//  CompletionIsAStretchGoel
//  Created by CISStudents
//  Copyleft 2015

import UIKit

// this is the victory screen at the end of the game
// it is accessed by a tab once the finalboss has been defeated
// includes a popup message letting you know you are a badass

class VictoryController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let alertController = UIAlertController(title: "Congratulations!", message: "You've swiftly defeated the tyranny of the UIView and escaped the clutches of evil!", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Of course. I'm badass.", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}