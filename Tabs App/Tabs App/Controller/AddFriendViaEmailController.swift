//
//  AddFriendViaEmailController.swift
//  Tabs App
//
//  Created by Wania Shams on 29/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth




class AddFriendController: UIViewController, UITextFieldDelegate{
    
    
    //MARK: Global Variables
    
    var validAccounts : [String] = []
    var invalidAccounts : [String] = []
    var friendsUsernamesAndEmails : [String] = []
    
    //MARK: Persistent Data Variable
    let persistentData = UserDefaults() //Used to contain the persistent data in UserDefaults
    
    //MARK: Database Globals
    let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database
    
    
    
    //MARK: IBOutlets
    @IBOutlet weak var addFriendTitle: UILabel!                         //IBOutlet where user enters their email
    @IBOutlet weak var addFriendDescription: UILabel!
    @IBOutlet weak var txtUsernameOrEmail: UITextField!                           //IBOutlet where user enters their email
    @IBOutlet weak var btnRequestFriend: RoundedButton!                 //IBOutlet for the final register button
    @IBOutlet weak var stsEmailWrong: UIImageView!                      //IBOutlet for the Email text field status X mark
    @IBOutlet weak var stsEmailRight: UIImageView!                      //IBOutlet for the Email text field status check mark
    @IBOutlet weak var stsEmailLoading: UIActivityIndicatorView!        //IBOutlet for the Email text field loading sign
    @IBOutlet weak var viwCenterContainer: UIView!
    @IBOutlet weak var btnCloseAddFriendViaEmail: UIButton!
    
    //MARK: Overridden Functions
    
    override func viewDidLoad() {
        keyboardManagerInit()
    }
    
    
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
        self.txtUsernameOrEmail.delegate = self
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
        case self.txtUsernameOrEmail:
            self.txtUsernameOrEmail.resignFirstResponder()
        default:
            self.txtUsernameOrEmail.resignFirstResponder()
        }
    }
    
    
    
    
    
    // MARK: Database Management
    
    // Used to first check if the user is signed in, if they are, read the friends data
    // Params: NONE
    // Return: NONE
    func checkIfValidAccount(accountEmailOrUsername: String) {
        if (validAccounts.contains(accountEmailOrUsername)) {
            stsEmailWrong.alpha = 0
            stsEmailRight.alpha = 1
            stsEmailLoading.alpha = 0
            btnRequestFriend.setTitleColor(UIColor.label, for: .normal)
            btnRequestFriend.borderColor = UIColor.systemBlue
            btnRequestFriend.isEnabled = true
        }
        else if (invalidAccounts.contains(accountEmailOrUsername)) {
            stsEmailWrong.alpha = 1
            stsEmailRight.alpha = 0
            stsEmailLoading.alpha = 0
            btnRequestFriend.setTitleColor(UIColor.lightGray, for: .normal)
            btnRequestFriend.borderColor = UIColor.lightGray
            btnRequestFriend.isEnabled = false
        }
        else {
            checkIfSignedInThenGetData(accountEmailOrUsername: accountEmailOrUsername)
        }
    }
    
    
    //TODO: Account gets added as invalid for not username as well
    
    func checkIfSignedInThenGetData(accountEmailOrUsername : String) {
        if (!User.loggedIn) {   //If not logged in, log them in, then pull data, else just pull in data
            Auth.auth().signIn(withEmail: persistentData.string(forKey: "UserEmail")!, password: persistentData.string(forKey: "UserPassword")!) { (authResult, err) in
                if (err != nil) {
                    //TODO: Deal with errors (no wifi, invalid pass, invalid email, etc.)
                }
                else {
                    User.loggedIn = true
                    self.checkIfValidFriend(accountEmailOrUsername: accountEmailOrUsername)
                }
            }
        }
        else {
            checkIfValidFriend(accountEmailOrUsername: accountEmailOrUsername)
        }
    }
    
    
    
    
    func checkIfValidFriend(accountEmailOrUsername : String) {
        let accountAsArray = [accountEmailOrUsername]
        db.collection("Users").whereField("email", in: accountAsArray).getDocuments { (docs, err) in
            if (err != nil) {
                //TODO: Deal with errors (no wifi, invalid pass, invalid email, etc.)
                self.stsEmailWrong.alpha = 1
                self.stsEmailRight.alpha = 0
                self.stsEmailLoading.alpha = 0
                self.btnRequestFriend.setTitleColor(UIColor.lightGray, for: .normal)
                self.btnRequestFriend.borderColor = UIColor.lightGray
                self.btnRequestFriend.isEnabled = false
            }
            else {
                if(docs!.count > 0) {
                    var toAdd = true
                    for doc in docs!.documents {
                        if(self.friendsUsernamesAndEmails.contains(doc.data()["email"] as! String)) {
                            toAdd = false
                            break;
                        }
                    }
                    if (toAdd) {
                        self.validAccounts.append(accountEmailOrUsername)
                    }
                    else {
                        self.invalidAccounts.append(accountEmailOrUsername)
                    }
                }
                else {
                    self.invalidAccounts.append(accountEmailOrUsername)
                }
                self.checkIfValidAccount(accountEmailOrUsername: accountEmailOrUsername)
            }
        }
        
        db.collection("Users").whereField("username", in: accountAsArray).getDocuments { (docs, err) in
            if (err != nil) {
                //TODO: Deal with errors (no wifi, invalid pass, invalid email, etc.)
                self.stsEmailWrong.alpha = 1
                self.stsEmailRight.alpha = 0
                self.stsEmailLoading.alpha = 0
                self.btnRequestFriend.setTitleColor(UIColor.lightGray, for: .normal)
                self.btnRequestFriend.borderColor = UIColor.lightGray
                self.btnRequestFriend.isEnabled = false
            }
            else {
                if(docs!.count > 0) {
                    var toAdd = true
                    for doc in docs!.documents {
                        if(self.friendsUsernamesAndEmails.contains(doc.data()["username"] as! String)) {
                            toAdd = false
                            break;
                        }
                    }
                    if (toAdd) {
                        self.validAccounts.append(accountEmailOrUsername)
                    }
                    else {
                        self.invalidAccounts.append(accountEmailOrUsername)
                    }
                }
                else {
                    self.invalidAccounts.append(accountEmailOrUsername)
                }
                self.checkIfValidAccount(accountEmailOrUsername: accountEmailOrUsername)
            }
        }
    }
    
    
    
    
    
    @IBAction func txtUsernameOrEmail(_ sender: Any) {
        if(txtUsernameOrEmail.text! == "") {
            stsEmailWrong.alpha = 0
            stsEmailRight.alpha = 0
            stsEmailLoading.alpha = 0
            btnRequestFriend.setTitleColor(UIColor.lightGray, for: .normal)
            btnRequestFriend.borderColor = UIColor.lightGray
            btnRequestFriend.isEnabled = false
        }
        else {
            stsEmailWrong.alpha = 0
            stsEmailRight.alpha = 0
            stsEmailLoading.alpha = 1
            btnRequestFriend.isEnabled = false
            btnRequestFriend.setTitleColor(UIColor.lightGray, for: .normal)
            btnRequestFriend.borderColor = UIColor.lightGray
            checkIfValidAccount(accountEmailOrUsername: txtUsernameOrEmail.text!)
        }
    }
    
    @IBAction func sendFriendRequestPressed(_ sender: Any) {
        
    }
    
    @IBAction func closeAddFriendViaEmailPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}
