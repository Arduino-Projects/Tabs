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




class AddFriendViaEmailController: UIViewController{
    
    
    //MARK: Global Variables
    
    var validEmails : [String] = []
    var invalidEmails : [String] = []
    
    //MARK: Persistent Data Variable
    let persistentData = UserDefaults() //Used to contain the persistent data in UserDefaults
    
    //MARK: Database Globals
    let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database
    
    
    
    //MARK: IBOutlets
    @IBOutlet weak var addFriendTitle: UILabel!                         //IBOutlet where user enters their email
    @IBOutlet weak var txtEmail: UITextField!                           //IBOutlet where user enters their email
    @IBOutlet weak var btnRequestFriend: RoundedButton!                 //IBOutlet for the final register button
    @IBOutlet weak var stsEmailWrong: UIImageView!                      //IBOutlet for the Email text field status X mark
    @IBOutlet weak var stsEmailRight: UIImageView!                      //IBOutlet for the Email text field status check mark
    @IBOutlet weak var stsEmailLoading: UIActivityIndicatorView!        //IBOutlet for the Email text field loading sign
    @IBOutlet weak var viwCenterContainer: UIView!
    
    @IBOutlet weak var btnCloseAddFriendViaEmail: UIButton!
    
    //MARK: Overridden Functions
    
    
    
    
    
    // MARK: Database Management
    
    // Used to first check if the user is signed in, if they are, read the friends data
    // Params: NONE
    // Return: NONE
    func checkIfValidEmail(email: String) {
        if (validEmails.contains(email)) {
            stsEmailWrong.alpha = 0
            stsEmailRight.alpha = 1
            stsEmailLoading.alpha = 0
            btnRequestFriend.isEnabled = true
        }
        else if (invalidEmails.contains(email)) {
            stsEmailWrong.alpha = 1
            stsEmailRight.alpha = 0
            stsEmailLoading.alpha = 0
            btnRequestFriend.isEnabled = false
        }
        else {
            checkIfSignedInThenGetData(email: email)
        }
    }
    
    
    
    
    func checkIfSignedInThenGetData(email : String) {
        if (!User.loggedIn) {   //If not logged in, log them in, then pull data, else just pull in data
            Auth.auth().signIn(withEmail: persistentData.string(forKey: "UserEmail")!, password: persistentData.string(forKey: "UserPassword")!) { (authResult, err) in
                if (err != nil) {
                    //TODO: Deal with errors (no wifi, invalid pass, invalid email, etc.)
                }
                else {
                    User.loggedIn = true
                    self.checkIfValidFriend(email: email)
                }
            }
        }
        else {
            checkIfValidFriend(email: email)
        }
    }
    
    
    
    
    func checkIfValidFriend(email : String) {
        let emailAsArray = [email]
        db.collection("Users").whereField("email", in: emailAsArray).getDocuments { (docs, err) in
            if (err != nil) {
                //TODO: Deal with errors (no wifi, invalid pass, invalid email, etc.)
                self.stsEmailWrong.alpha = 1
                self.stsEmailRight.alpha = 0
                self.stsEmailLoading.alpha = 0
                self.btnRequestFriend.isEnabled = false
            }
            else {
                if(docs!.count > 0) {
                    self.validEmails.append(email)
                }
                else {
                    self.invalidEmails.append(email)
                }
            }
        }
    }
    
    
    
    
    
    @IBAction func txtEmailEdited(_ sender: Any) {
        if(txtEmail.text! == "") {
            stsEmailWrong.alpha = 0
            stsEmailRight.alpha = 0
            stsEmailLoading.alpha = 0
            btnRequestFriend.isEnabled = false
        }
        else {
            stsEmailWrong.alpha = 0
            stsEmailRight.alpha = 0
            stsEmailLoading.alpha = 1
            btnRequestFriend.isEnabled = false
            checkIfValidEmail(email: txtEmail.text!)
        }
    }
    
    @IBAction func sendFriendRequestPressed(_ sender: Any) {
    }
    
    @IBAction func closeAddFriendViaEmailPressed(_ sender: Any) {
    }
    
    
}
