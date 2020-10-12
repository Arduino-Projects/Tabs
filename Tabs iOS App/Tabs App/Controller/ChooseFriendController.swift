//
//  ChooseFriendController.swift
//  Tabs App
//
//  Created by Araad Shams on 2020-09-07.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ChooseFriendController : UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    //MARK: Friends Variables
    var arrayOfFriendsUIDsData : [String] = []  //Used to contain all of the friends UID's
    var arrayOfFriendsData : [String] = []  //Used to contain all of the friends names
    var arrayOfFriendsUIDs : [String] = []  //Used to contain all of the friends UID's after filtering
    var arrayOfFriends : [String] = []  //Used to contain all of the friends names after filtering
    var differentStartingLetters : [String] = []    //Used to contain all of the different first letters for sectioning
    var amountOfSpecificStartingLetterTracker : [Int] = []  //Used to contain amt of each first letter for sectioning
    
    
    //MARK: Persistent Data Variable
    let persistentData = UserDefaults() //Used to contain the persistent data in UserDefaults
    
    
    //MARK: Database Globals
    let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database
    
    var createItemVC: AddBetController?
    var createItemVCOther: AddTabController?
    
    
    
    @IBOutlet weak var sbrSearchFriends: UISearchBar!
    @IBOutlet weak var tbvFriends: UITableView!
    @IBOutlet weak var stsReloadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnReloadFriends: UIButton!
    
    //MARK: Overridden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardManagerInit()
        tableViewInit()
    }
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
        self.sbrSearchFriends.delegate = self
        tbvFriends.keyboardDismissMode = .interactive
        //Added as an extension, to hide the keyboard when tapped outside of the keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    
    // Called through Search Bar Delegate, whenever return key is pressed, move to next text field
    // Params: textField : The text field object that return was pressed on
    // Return: NONE
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        switchBasedNextTextField(searchBar)
    }
    
    
    
    // Used to determine which textfield should be set as focus when return key is pressed
    // Params: textField : The text field object that return was pressed on
    // Return: NONE
    private func switchBasedNextTextField(_ textField: UISearchBar) {
        switch textField {
        case self.sbrSearchFriends:
            self.sbrSearchFriends.resignFirstResponder()
        default:
            self.sbrSearchFriends.resignFirstResponder()
        }
    }
    
    
    
    
    // MARK: Database Management
    
    // Used to first check if the user is signed in, if they are, read the friends data
    // Params: NONE
    // Return: NONE
    func checkIfSignedInThenGetData() {
        if (!User.loggedIn) {   //If not logged in, log them in, then pull data, else just pull in data
            Auth.auth().signIn(withEmail: persistentData.string(forKey: "UserEmail")!, password: persistentData.string(forKey: "UserPassword")!) { (authResult, err) in
                if (err != nil) {
                    if (err!._code == FirebaseAuth.AuthErrorCode.networkError.rawValue){
                        
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
                    self.pullFriendsFromDB()
                }
            }
        }
        else {
            pullFriendsFromDB()
        }
    }
    
    // Read the actual friends data from the DB
    // Params: NONE
    // Return: NONE
    func pullFriendsFromDB() {
        db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (doc, err) in
            if(err != nil) {
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
                self.btnReloadFriends.alpha = 1
                self.stsReloadingIndicator.alpha = 0
            }
            else {
                
                self.arrayOfFriendsUIDsData = doc?.data()!["friends"] as! [String]
                
                //From the UID list, grab all the friends details
                self.db.collection("Users").whereField(FieldPath.documentID(), in: self.arrayOfFriendsUIDsData).getDocuments { (docs, err) in
                    if(err != nil) {
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
                        self.arrayOfFriendsData = []
                        self.arrayOfFriendsUIDsData = []
                        for doc in docs!.documents {
                            self.arrayOfFriendsData.append(doc.data()["displayName"] as! String)
                            self.arrayOfFriendsUIDsData.append(doc.documentID)
                        }
                        //Sorting the friends array while also keeping UID's array matching
                        let combined = zip(self.arrayOfFriendsData, self.arrayOfFriendsUIDsData).sorted {$0.0.uppercased() < $1.0.uppercased()}
                        self.arrayOfFriendsData = combined.map {$0.0}
                        self.arrayOfFriendsUIDsData = combined.map {$0.1}
                        
                        self.persistentData.set(self.arrayOfFriendsData, forKey: "FriendsNamesList")
                        self.persistentData.set(self.arrayOfFriendsUIDsData, forKey: "FriendsUIDsList")
                        self.arrayOfFriends = self.arrayOfFriendsData
                        self.arrayOfFriendsUIDs = self.arrayOfFriendsUIDsData
                        self.calculateDifferentFirstLetters()
                        self.tbvFriends.reloadData()
                        User.friendsLoaded = true
                    }
                    self.btnReloadFriends.alpha = 1
                    self.stsReloadingIndicator.alpha = 0
                }
            }
        }
    }
    
    
    
    
    
    //MARK: Table View Management
    
    // Initialize the table view, add the delegate declaration, and temporarily read in data from storage if available
    // Params: NONE
    // Return: NONE
    func tableViewInit() {
        if(persistentData.array(forKey: "FriendsNamesList") != nil && persistentData.array(forKey: "FriendsUIDsList") != nil) {
            arrayOfFriendsData = (persistentData.array(forKey: "FriendsNamesList")! as? [String])!
            arrayOfFriendsUIDsData = (persistentData.array(forKey: "FriendsUIDsList")! as? [String])!
            arrayOfFriends = arrayOfFriendsData
            arrayOfFriendsUIDs = arrayOfFriendsUIDsData
        }
        calculateDifferentFirstLetters()
        tbvFriends.delegate = self
        tbvFriends.dataSource = self
        
        if(!User.friendsLoaded) {
            checkIfSignedInThenGetData()
        }
    }
    
    
    // Function to check the number of rows in each section
    // Params: UNNEEDED
    // Return: UNNEEDED
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amountOfSpecificStartingLetterTracker[section]
    }
    
    
    // Function to retrieve the cell object for each cell at an indexpath
    // Params: UNNEEDED
    // Return: UNNEEDED
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        
        var sumSections = 0
        for i in stride(from: 0, to: indexPath.section, by: 1) {
            sumSections += tableView.numberOfRows(inSection: i);
        }

        cell.textLabel?.text = arrayOfFriends[indexPath.row + sumSections]
        
        return cell
    }
    
    
    // Function to retrieve the total number of sections eg.("A", "B", "F")
    // Params: UNNEEDED
    // Return: UNNEEDED
    func numberOfSections(in tableView: UITableView) -> Int {
        return differentStartingLetters.count
    }
    
    
    // Function to retrieve the title for each section
    // Params: UNNEEDED
    // Return: UNNEEDED
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return differentStartingLetters[section]
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sumSections = 0
        for i in stride(from: 0, to: indexPath.section, by: 1) {
            sumSections += tableView.numberOfRows(inSection: i);
        }

        createItemVC?.friendSelected = true
        createItemVC?.chosenFriendUID = arrayOfFriendsUIDs[indexPath.row + sumSections]
        createItemVC?.chosenFriendName = arrayOfFriends[indexPath.row + sumSections]
        createItemVC?.friendWasChosen()
        
        createItemVCOther?.friendSelected = true
        createItemVCOther?.chosenFriendUID = arrayOfFriendsUIDs[indexPath.row + sumSections]
        createItemVCOther?.chosenFriendName = arrayOfFriends[indexPath.row + sumSections]
        createItemVCOther?.friendWasChosen()
        
        dismiss(animated: true)
    }
    
    //MARK: Data Sorting & Search Bar
    
    // Function to divide up the names into sections based on first name letters
    // Params: NONE
    // Return: NONE
    func calculateDifferentFirstLetters() {
        var curIndex = -1
        differentStartingLetters = []
        amountOfSpecificStartingLetterTracker = []
        
        for friend in arrayOfFriends {
            if(!differentStartingLetters.contains(friend[0 ..< 1].uppercased())) {
                differentStartingLetters.append(friend[0 ..< 1].uppercased())
                curIndex += 1
                amountOfSpecificStartingLetterTracker.append(1)
            }
            else {
                amountOfSpecificStartingLetterTracker[curIndex] += 1
            }
        }
    }
    
    
    // Function that is called whenever the text in the text bar is changed
    // Params: UNNEEDED
    // Return: UNNEEDED
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == "") {
            arrayOfFriends = arrayOfFriendsData
            arrayOfFriendsUIDs = arrayOfFriendsUIDsData
        }
        else {
            arrayOfFriends = []
            arrayOfFriendsUIDs = []
            var counter = 0
            for element in arrayOfFriendsData {
                if element.lowercased().contains(searchText.lowercased()) {
                    arrayOfFriends.append(element)
                    arrayOfFriendsUIDs.append(arrayOfFriendsUIDsData[counter])
                }
                counter += 1
            }
        }
        calculateDifferentFirstLetters()
        tbvFriends.reloadData()
    }
    
    
    
    //MARK: Persistent Data Wipe
    
    // Wipe all the data and go to sign in if there are any errors
    // Params: UNNEEDED
    // Return: UNNEEDED
    func wipePersistentDataAndGoToSignIn() {
        persistentData.removeObject(forKey: "UserEmail")
        persistentData.removeObject(forKey: "UserPassword")
        persistentData.removeObject(forKey: "FriendsNamesList")
        persistentData.removeObject(forKey: "FriendsUIDsList")
        persistentData.removeObject(forKey: "FriendsUsernamesAndEmailsList")
        performSegue(withIdentifier: "chooseFriendsToSignIn", sender: self)
    }
    
    
    
    //MARK: Table Refresh Management
     
     // Used to create and add the refresh functionality on the table view
     // Params: NONE
     // Return: NONE

     
     // Called when actually refreshing the UITableView
     // Params: NONE
     // Return: NONE
     func refresh() {
         btnReloadFriends.alpha = 0
         stsReloadingIndicator.alpha = 1
         checkIfSignedInThenGetData()
     }
    
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        refresh()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        createItemVC?.friendSelected = false
        createItemVC?.chosenFriendUID = ""
        createItemVC?.chosenFriendName = ""
        createItemVC?.friendWasChosen()
        
        createItemVCOther?.friendSelected = false
        createItemVCOther?.chosenFriendUID = ""
        createItemVCOther?.chosenFriendName = ""
        createItemVCOther?.friendWasChosen()
        
        dismiss(animated: true)
    }
    
    
}
