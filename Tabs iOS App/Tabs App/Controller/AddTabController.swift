//
//  AddTabController.swift
//  Tabs App
//
//  Created by Madhumita Mocharla on 2020-09-07.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit

class AddTabController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
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
    
    
    let currencyMajor = "$"
    let currencyMinor = "¢"
    
    var friendSelected = false
    var chosenFriendName = ""
    var chosenFriendUID = ""
    
    //MARK: Overridden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardManagerInit()
        pickerViewInit()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if going to signin screen, make sure it knows to do all necessary changes
        if segue.identifier == "addTabToChooseFriend" {
            if let nextViewController = segue.destination as? ChooseFriendController {
                    nextViewController.createItemVCOther = self
            }
        }
    }
    
    
    
    
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
        self.txtTabTitle.delegate = self
        self.txtTabDescription.delegate = self
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
        case self.txtTabTitle:
            self.txtTabDescription.becomeFirstResponder()
        case self.txtTabDescription:
            self.txtTabDescription.resignFirstResponder()
        default:
            self.txtTabDescription.resignFirstResponder()
        }
    }
    
    

    
    
    //MARK: Picker View Management
    
    func pickerViewInit() {
        pkvCentAmount.delegate = self
        pkvCentAmount.dataSource = self
        pkvDollarAmount.delegate = self
        pkvDollarAmount.dataSource = self
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == pkvDollarAmount) {
            return 20000
        }
        
        else if (pickerView == pkvCentAmount) {
            return 100
        }
        return 0
    }

    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
       let label = (view as? UILabel) ?? UILabel()

       label.textColor = .label
       label.textAlignment = .center
       label.font = UIFont(name: "Barlow-SemiBold", size: 25)
        
        
        
        if (pickerView == pkvDollarAmount) {
            label.text = currencyMajor + String(row)
        }
            
        else if (pickerView == pkvCentAmount) {
            label.text = String(row) + currencyMinor
        }
       return label
     }
    
    
    
    
    func disableButtonWhenFieldsIncomplete() {
        if(checkIfFieldsComplete()) {
            btnRequestTab.setTitleColor(UIColor.label, for: .normal)
            btnRequestTab.borderColor = UIColor.systemBlue
            btnRequestTab.isEnabled = true
        }
        else {
            btnRequestTab.setTitleColor(UIColor.lightGray, for: .normal)
            btnRequestTab.borderColor = UIColor.lightGray
            btnRequestTab.isEnabled = false
        }
    }
    
    
    
    
    func checkIfFieldsComplete() -> Bool {
        if(txtTabTitle.text! != "" && friendSelected) {
            return true
        }
        return false
    }
    
    
    func friendWasChosen() {
        if(friendSelected) {
            btnFriendSelect.setTitleColor(.label, for: .normal)
            btnFriendSelect.setTitle("Friend: " + chosenFriendName, for: .normal)
        }
        else {
            btnFriendSelect.setTitleColor(.systemGray2, for: .normal)
            btnFriendSelect.setTitle("Tap To Select A Friend", for: .normal)
        }
        disableButtonWhenFieldsIncomplete()
    }
    
    
    //MARK: IBActions
    
    @IBAction func closeAddBetPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func titleFieldChanged(_ sender: Any) {
        disableButtonWhenFieldsIncomplete()
    }
    
    
    @IBAction func descriptionFieldChanged(_ sender: Any) {
        
    }
    
    
    
    @IBAction func addFriendPressed(_ sender: Any) {
        performSegue(withIdentifier: "addTabToChooseFriend", sender: self)
    }
    
    @IBAction func tabStateChanged(_ sender: Any) {
        sgvWhoLentMoney.selectedSegmentTintColor = [UIColor.systemGreen, UIColor.systemRed][sgvWhoLentMoney.selectedSegmentIndex]
    }
    
    
    @IBAction func addTabPressed(_ sender: Any) {
        
    }
    

    
}
