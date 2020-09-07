//
//  AddBetController.swift
//  Tabs App
//
//  Created by Madhumita Mocharla on 2020-09-07.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit

class AddBetController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
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
    
    let possibleDollarValues = Array(0...20000)
    
    //MARK: Overridden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardManagerInit()
        pickerViewInit()
    }
    
    
    
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
        self.lblBetTitle.delegate = self
        self.lblDescriptionText.delegate = self
        //Added as an extension, to hide the keyboard when tapped outside of the keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    
    // Called through Search Bar Delegate, whenever return key is pressed, move to next text field
    // Params: textField : The text field object that return was pressed on
    // Return: NONE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchBasedNextTextField(textField)
        return true
    }
    
    
    
    // Used to determine which textfield should be set as focus when return key is pressed
    // Params: textField : The text field object that return was pressed on
    // Return: NONE
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.lblBetTitle:
            self.lblDescriptionText.becomeFirstResponder()
        case self.lblDescriptionText:
            self.lblDescriptionText.resignFirstResponder()
        default:
            self.lblDescriptionText.resignFirstResponder()
        }
    }
    
    
    
    
    
    //MARK: Picker View Management
    
    func pickerViewInit() {
        pkvCentValue.delegate = self
        pkvCentValue.dataSource = self
        pkvDollarValue.delegate = self
        pkvDollarValue.dataSource = self
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return possibleDollarValues.count
    }

    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
       let label = (view as? UILabel) ?? UILabel()

       label.textColor = .label
       label.textAlignment = .center
       label.font = UIFont(name: "Barlow-Bold", size: 18)

       // where data is an Array of String
       label.text = "$" + String(possibleDollarValues[row])

       return label
     }
    
    
    //MARK: IBActions
    
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
