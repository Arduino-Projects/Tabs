//
//  ForgotPasswordController.swift
//  Tabs App
//
//  Created by Wania Shams on 25/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ForgotPasswordController : UIViewController, UITextFieldDelegate {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var btnCloseForgotPassword: UIButton!
    @IBOutlet weak var lblErrorIndicator: UILabel!
    @IBOutlet weak var lblResetTitle: UILabel!
    @IBOutlet weak var lblForgottenDescription: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnResetPassword: RoundedButton!
    
    
    
    
    
    
    
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
        self.txtEmail.delegate = self
        
        //Added as an extension, to hide the keyboard when tapped outside of the keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    
    // Called through Text Field Delegate, whenever return key is pressed, move to next text field
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
        case self.txtEmail:
            self.txtEmail.resignFirstResponder()
        default:
            self.txtEmail.resignFirstResponder()
        }
    }
    
    
    
    
    
    //MARK: IBActions
    
    @IBAction func closeForgotPasswordScreen(_ sender: Any) {
    }
    
    @IBAction func resetPasswordButtonPressed(_ sender: Any) {
        
    }
    
    
}
