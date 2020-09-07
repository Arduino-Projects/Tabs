//
//  AddBetController.swift
//  Tabs App
//
//  Created by Madhumita Mocharla on 2020-09-07.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit

class AddBetController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var btnCloseAddTabs: UIButton!
    @IBOutlet weak var lblAddBet: UILabel!
    @IBOutlet weak var lblBetTitle: UITextField!
    @IBOutlet weak var lblDescriptionText: UITextField!
    @IBOutlet weak var lblCurrencyMajor: UILabel!
    @IBOutlet weak var lblMoneySeperator: UILabel!
    @IBOutlet weak var pkvDollarValue: UIPickerView!
    @IBOutlet weak var pkvCentValue: UIPickerView!
    @IBOutlet weak var btnSelectFriend: RoundedButton!
    @IBOutlet weak var sgvBetState: UISegmentedControl!
    @IBOutlet weak var btnRequestBet: RoundedButton!
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        <#code#>
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        <#code#>
    }
    
    @IBAction func closeAddBetPressed(_ sender: Any) {
    }
    
    @IBAction func titleFieldChanged(_ sender: Any) {
        
    }
    
    
    @IBAction func descriptionFieldChanged(_ sender: Any) {
    }
    
    
    
    @IBAction func addFriendPressed(_ sender: Any) {
    }
    
    @IBAction func betStateChanged(_ sender: Any) {
    }
    
    
    @IBAction func addBetPressed(_ sender: Any) {
    }
    
    
    }
