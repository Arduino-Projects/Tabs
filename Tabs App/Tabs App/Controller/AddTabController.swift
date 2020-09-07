//
//  AddTabController.swift
//  Tabs App
//
//  Created by Madhumita Mocharla on 2020-09-07.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit

class AddTabController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: IBOutlets
    @IBOutlet weak var btnCloseAddTab: UIButton!
    @IBOutlet weak var lblAddTabTitle: UILabel! 
    @IBOutlet weak var lblCurrencyMajor: UILabel!
    
    @IBOutlet weak var txtTabTitle: UITextField!
    @IBOutlet weak var txtTabDescription: UITextField!
    @IBOutlet weak var pkvDollarAmount: UIPickerView!
    
    @IBOutlet weak var sgvWhoLentMoney: UISegmentedControl!
    
    @IBOutlet weak var lblCurrencySeparator: UILabel!
    @IBOutlet weak var pkvCentAmount: UIPickerView!
    
    @IBOutlet weak var btnFriendSelect: RoundedButton!
    @IBOutlet weak var btnRequestTab: RoundedButton!
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        <#code#>
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        <#code#>
    }
    

    
}
