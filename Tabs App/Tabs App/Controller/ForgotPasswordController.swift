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
    
    
    
    //MARK: Global Variables
    
    //MARK: Internet Connection Globals
    var noInternetNotification : UIView? = nil  //Used to create a UIView to store the noInternet banner
    var noInternetLabel : UILabel? = nil    //Used to create the label that says no internet on the banner
    var noInternetConnected : Bool = false  //Keeps track of whether there is an active internet connection
    var noInternetConnectionViewPresent : Bool = false  //Keeps track of whether the internet connection banner is currently being displayed
    var reachability: Reachability!     //Used to run an async check of whether there is a live internet connection
    
    //MARK: Database Globals
    let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database
    
    var isDoneSending = false
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var btnCloseForgotPassword: UIButton!
    @IBOutlet weak var lblErrorIndicator: UILabel!
    @IBOutlet weak var lblResetTitle: UILabel!
    @IBOutlet weak var lblForgottenDescription: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnResetPassword: RoundedButton!
    @IBOutlet weak var stsLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblEmailSentSuccessfully: UILabel!
    @IBOutlet weak var icnEmailSentSuccessfully: UIImageView!
    
    
    
    //MARK: Overridden Functions
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        internetConnectionManagerInit()
        keyboardManagerInit()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if going to signin screen, make sure it knows to do all necessary changes
        if segue.identifier == "forgotPasswordToSignin" {
            if let nextViewController = segue.destination as? SignInController {
                    nextViewController.comingFromVerificationOrForgotPassword = true
            }
        }
    }
    
    
    
    
    
    
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
    
    
    
    
    
    
    //MARK: Network Management
    
    // Used to initialize the no internet connection view, as well as start the observer that keeps track of the network connectivity
    // Params: NONE
    // Return: NONE
    func internetConnectionManagerInit() {
        noInternetNotification = UIView(frame: CGRect(x: 0, y: -80, width: self.view.frame.width, height: 70))
        noInternetNotification!.backgroundColor = UIColor.red
        
        noInternetLabel = UILabel(frame: CGRect(x: self.view.frame.width/2 - (200)/2, y: 30, width: 200, height: 50))
        noInternetLabel!.textColor = UIColor.white
        noInternetLabel!.textAlignment = NSTextAlignment.center
        noInternetLabel!.font = noInternetLabel!.font.withSize(14)
        noInternetLabel!.text = "No Internet Connection"
        
        noInternetNotification!.addSubview(noInternetLabel!)
        self.view.addSubview(self.noInternetNotification!)
        do {
            try reachability = Reachability()
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
            try reachability.startNotifier()
        } catch {
            //UNKNOWN ERROR
        }
        
    }
    
    
    
    // Called when the internet connectivity state changes
    // Params: NONE
    // Return: NONE
    func internetConnectionStateChange() {
        if(noInternetConnected && !noInternetConnectionViewPresent) {
            noInternetConnectionViewPresent = true
            UIView.animate(withDuration: 0.5) {
                self.noInternetNotification!.frame.origin.y += self.noInternetNotification!.frame.height
            }
        }
        else if(!noInternetConnected && noInternetConnectionViewPresent) {
            noInternetConnectionViewPresent = false
            UIView.animate(withDuration: 0.5) {
                self.noInternetNotification!.frame.origin.y -= self.noInternetNotification!.frame.height
            }
        }
    }
    
    
    
    
    // The async function that keeps track of the current network connection status
    // Params: note : contains information about the connectivity status
    // Return: NONE
    @objc func reachabilityChanged(_ note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .unavailable {
            self.internetConnectionFound()
        }
            
        else {
            self.internetConnectionLost()
        }
    }
    
    
    
    // Used to call the function that adds in the no internet view
    // Params: NONE
    // Return: NONE
    func internetConnectionLost() {
        self.noInternetConnected = true
        self.internetConnectionStateChange()
    }
    
    
    // Used to call the function that removes in the no internet view
    // Params: NONE
    // Return: NONE
    func internetConnectionFound() {
        self.noInternetConnected = false
        self.internetConnectionStateChange()
    }
    
    
    
    
    
    
    //MARK: Forgot Password Manangement
    
    
    
    
    
    
    
    //MARK: IBActions
    
    @IBAction func closeForgotPasswordScreen(_ sender: Any) {
        performSegue(withIdentifier: "forgotPasswordToSignin", sender: self)
    }
    
    @IBAction func resetPasswordButtonPressed(_ sender: Any) {
        if(isDoneSending) {
            performSegue(withIdentifier: "forgotPasswordToSignin", sender: self)
        }
        else {
            let emailStr = txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            btnCloseForgotPassword.isEnabled = false
            btnResetPassword.isEnabled = false
            txtEmail.isEnabled = false
            stsLoadingIndicator.alpha = 1
            
            
            if (emailStr == "") {
                btnCloseForgotPassword.isEnabled = true
                btnResetPassword.isEnabled = true
                txtEmail.isEnabled = true
                stsLoadingIndicator.alpha = 0
                lblErrorIndicator.text = "Email field is empty!"
            }
            else {
                Auth.auth().sendPasswordReset(withEmail: emailStr) { (error) in
                    if (error != nil) {
                        
                        self.btnCloseForgotPassword.isEnabled = true
                        self.btnResetPassword.isEnabled = true
                        self.txtEmail.isEnabled = true
                        self.stsLoadingIndicator.alpha = 0
                        
                        if(error!._code == 17020) {
                            self.lblErrorIndicator.text! = "No internet connection!"
                        }
                        else if (error!._code == 17010) {
                            self.lblErrorIndicator.text! = "Too many requests, try again in a bit!"
                        }
                        else if (error!._code == 17011 || error!._code == 17008) {
                            self.lblErrorIndicator.text! = "There is no account with this email!"
                        }
                        else {
                            self.lblErrorIndicator.text! = "Unknown error code: " + String(error!._code)
                        }
                    }
                    else {
                        self.btnCloseForgotPassword.isEnabled = true
                        self.stsLoadingIndicator.alpha = 0
                        self.btnResetPassword.setTitle("Go Back", for: .normal)
                        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                            
                            self.txtEmail.alpha = 0
                            self.lblForgottenDescription.alpha = 0
                            self.lblEmailSentSuccessfully.alpha = 1
                            self.icnEmailSentSuccessfully.alpha = 1
                        }, completion: { (err) in
                            self.btnResetPassword.isEnabled = true
                            self.isDoneSending = true
                        })
                    }
                }
            }
        }
    }
    
    
}
