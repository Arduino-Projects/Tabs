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

class ForgotPasswordController : UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var btnCloseForgotPassword: UIButton!
    @IBOutlet weak var lblErrorIndicator: UILabel!
    @IBOutlet weak var lblResetTitle: UILabel!
    @IBOutlet weak var lblForgottenDescription: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnResetPassword: RoundedButton!
    
    
    
    
    @IBAction func closeForgotPasswordScreen(_ sender: Any) {
    }
    
    @IBAction func resetPasswordButtonPressed(_ sender: Any) {
        
    }
    
    
}
