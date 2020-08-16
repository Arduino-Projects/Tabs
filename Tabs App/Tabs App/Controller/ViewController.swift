//
//  ViewController.swift
//  Tabs App
//
//  Created by Wania Shams on 15/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var LogoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 2, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
             self.LogoImage.frame.origin.y = self.LogoImage.frame.origin.y - 150
        })
        
    }

}

