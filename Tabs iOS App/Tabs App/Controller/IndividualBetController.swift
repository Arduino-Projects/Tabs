//
//  IndividualBetController.swift
//  Tabs App
//
//  Created by Araad Shams on 2020-09-08.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit

class IndividualBetController : UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblFriendName: UILabel!
    @IBOutlet weak var lblBetDescription: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var sgvBetState: UISegmentedControl!
    @IBOutlet weak var stsLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblInstructionIndicator: UILabel!
    @IBOutlet weak var btnCloseBetIndicator: UIButton!
    @IBOutlet weak var btnRefreshBet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self;
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipe(_:)))
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        
    }
    
    @objc func didSwipe(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true;
    }
    
    @IBAction func closeBetPressed(_ sender: Any) {
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
    }
    @IBAction func betStateChanged(_ sender: Any) {
    }
    
}

