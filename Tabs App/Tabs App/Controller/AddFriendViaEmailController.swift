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
    
    //MARK: Internet Connection Globals
    var noInternetConnected : Bool = false  //Keeps track of whether there is an active internet connection
    var noInternetConnectionViewPresent : Bool = false  //Keeps track of whether the internet connection banner is currently being displayed
    var reachability: Reachability!     //Used to run an async check of whether there is a live internet connection
    
    
    
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
    
    
    
    
    
    //MARK: Network Management
    
    // Used to initialize the no internet connection view, as well as start the observer that keeps track of the network connectivity
    // Params: NONE
    // Return: NONE
    func internetConnectionManagerInit() {
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
        }
        else if(!noInternetConnected && noInternetConnectionViewPresent) {
            noInternetConnectionViewPresent = false
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
                    if (err!._code == FirebaseAuth.AuthErrorCode.networkError.rawValue){
                        self.internetConnectionLost()
                    }
                    //FIRAuthErrorCodeNetworkError
                    
                    else if (err!._code == FirebaseAuth.AuthErrorCode.userNotFound.rawValue){
                        self.wipePersistentDataAndGoToSignIn()
                    }
                    //FIRAuthErrorCodeUserNotFound
                    
                    else if (err!._code == FirebaseAuth.AuthErrorCode.userTokenExpired.rawValue){
                        self.wipePersistentDataAndGoToSignIn()
                    }
                    //FIRAuthErrorCodeUserTokenExpired
                    
                    else if (err!._code == FirebaseAuth.AuthErrorCode.tooManyRequests.rawValue){
                        self.wipePersistentDataAndGoToSignIn()
                    }
                    //FIRAuthErrorCodeTooManyRequests
                    
                    else if (err!._code == FirebaseAuth.AuthErrorCode.invalidEmail.rawValue){
                        self.wipePersistentDataAndGoToSignIn()
                    }
                    //FIRAuthErrorCodeInvalidEmail
                    
                    else if (err!._code == FirebaseAuth.AuthErrorCode.userDisabled.rawValue){
                        self.wipePersistentDataAndGoToSignIn()
                    }
                    //FIRAuthErrorCodeUserDisabled
                    
                    else if (err!._code == FirebaseAuth.AuthErrorCode.wrongPassword.rawValue){
                        self.wipePersistentDataAndGoToSignIn()
                    }
                    //FIRAuthErrorCodeWrongPassword
                    
                    else {
                        //UNKNOWN ERROR
                    }
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
                if(err!._code == FirebaseFirestore.FirestoreErrorCode.notFound.rawValue) {
                    self.wipePersistentDataAndGoToSignIn()
                }
                //CODE 5 - DOC NOT FOUND - to sign in
                
                else if(err!._code == FirebaseFirestore.FirestoreErrorCode.alreadyExists.rawValue) {
                    
                }
                //CODE 6 - ATTEMPT TO ADD DOCUMENT THAT ALREADY EXISTS - ignore for this
                
                else if(err!._code == FirebaseFirestore.FirestoreErrorCode.permissionDenied.rawValue) {
                    self.wipePersistentDataAndGoToSignIn()
                }
                //CODE 7 - INSUFFICIENT PERMISSIONS - to sign in
                
                else if(err!._code == FirebaseFirestore.FirestoreErrorCode.unauthenticated.rawValue) {
                    self.wipePersistentDataAndGoToSignIn()
                }
                //CODE 16 - USER UNAUTHENTICATED - to sign in
                
                else {
                    //UNKNOWN ERROR
                }
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
                if(err!._code == FirebaseFirestore.FirestoreErrorCode.notFound.rawValue) {
                    self.wipePersistentDataAndGoToSignIn()
                }
                //CODE 5 - DOC NOT FOUND - to sign in
                
                else if(err!._code == FirebaseFirestore.FirestoreErrorCode.alreadyExists.rawValue) {
                    
                }
                //CODE 6 - ATTEMPT TO ADD DOCUMENT THAT ALREADY EXISTS - ignore for this
                
                else if(err!._code == FirebaseFirestore.FirestoreErrorCode.permissionDenied.rawValue) {
                    self.wipePersistentDataAndGoToSignIn()
                }
                //CODE 7 - INSUFFICIENT PERMISSIONS - to sign in
                
                else if(err!._code == FirebaseFirestore.FirestoreErrorCode.unauthenticated.rawValue) {
                    self.wipePersistentDataAndGoToSignIn()
                }
                //CODE 16 - USER UNAUTHENTICATED - to sign in
                
                else {
                    //UNKNOWN ERROR
                }
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
    
    
    
    
    //MARK: Persistent Data Wipe
    
    func wipePersistentDataAndGoToSignIn() {
        persistentData.removeObject(forKey: "UserEmail")
        persistentData.removeObject(forKey: "UserPassword")
        persistentData.removeObject(forKey: "FriendsNamesList")
        persistentData.removeObject(forKey: "FriendsUIDsList")
        persistentData.removeObject(forKey: "FriendsUsernamesAndEmailsList")
        performSegue(withIdentifier: "friendsToSignIn", sender: self)
    }
    
    
    
    @IBAction func sendFriendRequestPressed(_ sender: Any) {
        
    }
    
    @IBAction func closeAddFriendViaEmailPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}
