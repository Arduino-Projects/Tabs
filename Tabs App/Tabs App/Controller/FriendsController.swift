//
//  FriendsController.swift
//  Tabs App
//
//  Created by Wania Shams on 26/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FriendsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    //MARK: Global Variables
    
    //MARK: Internet Connection Globals
    var noInternetNotification : UIView? = nil  //Used to create a UIView to store the noInternet banner
    var noInternetLabel : UILabel? = nil    //Used to create the label that says no internet on the banner
    var noInternetConnected : Bool = false  //Keeps track of whether there is an active internet connection
    var noInternetConnectionViewPresent : Bool = false  //Keeps track of whether the internet connection banner is currently being displayed
    var reachability: Reachability!     //Used to run an async check of whether there is a live internet connection
    
    
    //MARK: Friends Variables
    var arrayOfFriendsUIDsData : [String] = []  //Used to contain all of the friends UID's
    var arrayOfFriendsData : [String] = []  //Used to contain all of the friends names
    var arrayOfFriendsUIDs : [String] = []  //Used to contain all of the friends UID's after filtering
    var arrayOfFriends : [String] = []  //Used to contain all of the friends names after filtering
    var differentStartingLetters : [String] = []    //Used to contain all of the different first letters for sectioning
    var amountOfSpecificStartingLetterTracker : [Int] = []  //Used to contain amt of each first letter for sectioning
    
    
    //MARK: Table Refresh Controller
    var refreshControl = UIRefreshControl() //Used to perform the drag down to refresh
    
    //MARK: Persistent Data Variable
    let persistentData = UserDefaults() //Used to contain the persistent data in UserDefaults
    
    
    //MARK: Database Globals
    let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database
    
    
    
    //MARK: IBOutlets
    @IBOutlet weak var tbvFriends: UITableView!                     //The main table view that contains the friends
    @IBOutlet weak var sbrSearchThroughFriends: UISearchBar!        //The search bar used to search friends
    
    
    //MARK: Overridden Functions
    
    override func viewDidLoad() {
        internetConnectionManagerInit()
        keyboardManagerInit()
        refreshControllerInit()
        tableViewInit()
    }
    

    
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
        self.sbrSearchThroughFriends.delegate = self
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
        case self.sbrSearchThroughFriends:
            self.sbrSearchThroughFriends.resignFirstResponder()
        default:
            self.sbrSearchThroughFriends.resignFirstResponder()
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
    
    
    
    
    
    //MARK: Table Refresh Management
    
    // Used to create and add the refresh functionality on the table view
    // Params: NONE
    // Return: NONE
    func refreshControllerInit() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tbvFriends.addSubview(refreshControl)
    }
    
    
    // Called when actually refreshing the UITableView
    // Params: sender: the object that is calling to be refreshed
    // Return: NONE
    @objc func refresh(_ sender: AnyObject) {
        checkIfSignedInThenGetData()
    }
    
    
    
    
    
    
    
    // MARK: Database Management
    
    // Used to first check if the user is signed in, if they are, read the friends data
    // Params: NONE
    // Return: NONE
    func checkIfSignedInThenGetData() {
        if (!User.loggedIn) {   //If not logged in, log them in, then pull data, else just pull in data
            Auth.auth().signIn(withEmail: persistentData.string(forKey: "UserEmail")!, password: persistentData.string(forKey: "UserPassword")!) { (authResult, err) in
                if (err != nil) {
                    //TODO: Deal with errors (no wifi, invalid pass, invalid email, etc.)
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
                //TODO: Deal with errors (no wifi, no document, no access, etc.)
            }
            else {
                self.arrayOfFriendsUIDsData = doc?.data()!["friends"] as! [String]
                
                //From the UID list, grab all the friends details
                self.db.collection("Users").whereField(FieldPath.documentID(), in: self.arrayOfFriendsUIDsData).getDocuments { (docs, err) in
                    if(err != nil) {
                        //TODO: Deal with errors (no wifi, no document, no access, etc.)
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
                        self.refreshControl.endRefreshing()
                        User.friendsLoaded = true
                    }
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
        
        var sumSections = 0;
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
    
    
    
    
}
