//
//  TabsController.swift
//  Tabs App
//
//  Created by Wania Shams on 31/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


class TabsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tbvTabs: UITableView!
    @IBOutlet weak var sbrSearchTabs: UISearchBar!
    @IBOutlet weak var btnAddATab: UIButton!
    
    
    
    
    let currencyMajor = "$"
    let currencyMinor = "¢"
    
    //MARK: Internet Connection Globals
    var noInternetNotification : UIView? = nil  //Used to create a UIView to store the noInternet banner
    var noInternetLabel : UILabel? = nil    //Used to create the label that says no internet on the banner
    var noInternetConnected : Bool = false  //Keeps track of whether there is an active internet connection
    var noInternetConnectionViewPresent : Bool = false  //Keeps track of whether the internet connection banner is currently being displayed
    var reachability: Reachability!     //Used to run an async check of whether there is a live internet connection
    

    //MARK: Tabs Variables
    var tabsData : [[String:Any]] = []
    var tabsFiltered : [[String:Any]] = []
    
    //MARK: Table Refresh Controller
    var refreshControl = UIRefreshControl() //Used to perform the drag down to refresh
    
    //MARK: Persistent Data Variable
    let persistentData = UserDefaults() //Used to contain the persistent data in UserDefaults
    
    //MARK: Database Globals
    let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        internetConnectionManagerInit()
        keyboardManagerInit()
        refreshControllerInit()
        tableViewInit()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        refreshControl.endRefreshing()
    }
    
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
        self.sbrSearchTabs.delegate = self
        tbvTabs.keyboardDismissMode = .interactive
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
        case self.sbrSearchTabs:
            self.sbrSearchTabs.resignFirstResponder()
        default:
            self.sbrSearchTabs.resignFirstResponder()
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
            checkIfSignedInThenGetData()
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
        tbvTabs.addSubview(refreshControl)
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
                    self.refreshControl.endRefreshing()
                }
                else {
                    User.loggedIn = true
                    self.pullTabsFromDB()
                }
            }
        }
        else {
            pullTabsFromDB()
        }
    }
    
    // Read the actual friends data from the DB
    // Params: NONE
    // Return: NONE
    func pullTabsFromDB() {
        db.collection("Tabs").whereField("uids", arrayContains: Auth.auth().currentUser!.uid).getDocuments { (docs, err) in
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
                self.refreshControl.endRefreshing()
            }
            else {
                var skipNameRetrieval = false
                if(self.persistentData.array(forKey: "FriendsUIDsList") != nil && self.persistentData.array(forKey: "FriendsNamesList") != nil) {
                    skipNameRetrieval = true
                    for doc in docs!.documents {
                        if(!(self.persistentData.array(forKey: "FriendsUIDsList") as! [String]).contains(doc.documentID)) {
                            skipNameRetrieval = false
                            break
                        }
                    }
                }
                
                var userUIDs : [String] = []
                for doc in docs!.documents {
                    if((doc.data()["uids"] as! [String])[0] == Auth.auth().currentUser!.uid) {
                        userUIDs.append((doc.data()["uids"] as! [String])[1])
                    }
                    else {
                        userUIDs.append((doc.data()["uids"] as! [String])[0])
                    }
                }
                
                if(!skipNameRetrieval) {
                    self.db.collection("Users").whereField(FieldPath.documentID(), in: userUIDs).getDocuments { (userDocs, err) in
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
                            self.refreshControl.endRefreshing()
                        }
                        else {
                            var names : [String] = []
                            var uids : [String] = []
                            for doc in userDocs!.documents {
                                uids.append(doc.documentID)
                                names.append(doc.data()["displayName"] as! String)
                            }

                            self.usePersistentDataToPresentAndStoreTabs(tabs: docs!, friendsUIDs: self.persistentData.array(forKey: "FriendsUIDsList")!, friendsNames: self.persistentData.array(forKey: "FriendsNamesList")!)
                        }
                    }
                }
                else {
                    self.usePersistentDataToPresentAndStoreTabs(tabs: docs!, friendsUIDs: self.persistentData.array(forKey: "FriendsUIDsList")!, friendsNames: self.persistentData.array(forKey: "FriendsNamesList")!)
                }
            }
        }
    }
    
    
    func usePersistentDataToPresentAndStoreTabs(tabs: QuerySnapshot, friendsUIDs : [Any], friendsNames : [Any]) {
        tabsData = []
        var counter = 0
        for doc in tabs.documents {
            tabsData.append([:])
            print(doc.data())
            if((doc.data()["uids"] as! [String])[0] == Auth.auth().currentUser!.uid) {
                let index = friendsUIDs.firstIndex{ $0 as! String == (doc.data()["uids"] as! [String])[1]}
                
                tabsData[counter]["otherUserUID"] = (doc.data()["uids"] as! [String])[1]
                tabsData[counter]["otherUserName"] = (friendsNames as! [String])[index!]
            }
            else {
                let index = friendsUIDs.firstIndex{ $0 as! String == (doc.data()["uids"] as! [String])[0]}
                
                tabsData[counter]["otherUserUID"] = (doc.data()["uids"] as! [String])[0]
                tabsData[counter]["otherUserName"] = (friendsNames as! [String])[index!]
            }
            
            tabsData[counter]["isUserTheOwer"] = (doc.data()["personWhoOwes"] as! String) == Auth.auth().currentUser!.uid
            tabsData[counter]["totalAmount"] = (doc.data()["overallMoney"] as! NSNumber).floatValue
            tabsData[counter]["docID"] = doc.documentID
            
            counter += 1
        }
        
        tabsData = tabsData.sorted { ($0["otherUserName"] as! String) < ($1["otherUserName"]  as! String)}
        tabsFiltered = tabsData
        
        self.persistentData.set(tabsData, forKey: "TabsList")
        User.tabsLoaded = true
        self.refreshControl.endRefreshing()
        tbvTabs.reloadData()
    }
    
    
    
    
    
    //MARK: Table View Management
    
    // Initialize the table view, add the delegate declaration, and temporarily read in data from storage if available
    // Params: NONE
    // Return: NONE
    func tableViewInit() {
        if(persistentData.array(forKey: "TabsList") != nil) {
            tabsData = persistentData.array(forKey: "TabsList") as! [[String : Any]]
            tabsFiltered = tabsData
        }
        
//        if(persistentData.array(forKey: "FriendsUsernamesAndEmailsList") != nil) {
//            friendsUsernamesAndEmails = persistentData.array(forKey: "FriendsUsernamesAndEmailsList") as! [String]
//            btnAddATab.isEnabled = true
//        }
        tbvTabs.register(UINib(nibName: "TabsCell", bundle: nil), forCellReuseIdentifier: "TabsCell")
        tbvTabs.delegate = self
        tbvTabs.dataSource = self
        
        if(!User.tabsLoaded) {
            checkIfSignedInThenGetData()
        }
    }
    
    
    // Function to check the number of rows in each section
    // Params: UNNEEDED
    // Return: UNNEEDED
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabsFiltered.count
    }
    
    
    // Function to retrieve the cell object for each cell at an indexpath
    // Params: UNNEEDED
    // Return: UNNEEDED
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TabsCell", for: indexPath) as! TabsCell
        let currentCellData = tabsFiltered[indexPath.row]
        
        cell.lblName.text! = currentCellData["otherUserName"] as! String
        cell.lblWhoOwes.text! = (currentCellData["isUserTheOwer"] as! Bool) ? "you owe" : "they owe"
        cell.lblAmount.textColor! = (currentCellData["isUserTheOwer"] as! Bool) ? UIColor.systemRed : UIColor.systemGreen
        
        if((currentCellData["totalAmount"] as! Float) < 1) {
            cell.lblAmount.text! = String(Int((currentCellData["totalAmount"] as! Float)*100)) + currencyMinor
        }
        else if((currentCellData["totalAmount"] as! Float) < 100) {
            cell.lblAmount.text! = currencyMajor + String((currentCellData["totalAmount"] as! Float))
        }
        else {
            cell.lblAmount.text! = currencyMajor + String(Int(currentCellData["totalAmount"] as! Float))
        }
        
        return cell
    }
    
    
    // Function to retrieve the total number of sections eg.("A", "B", "F")
    // Params: UNNEEDED
    // Return: UNNEEDED
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    
    //MARK: Data Sorting & Search Bar
    
    
    // Function that is called whenever the text in the text bar is changed
    // Params: UNNEEDED
    // Return: UNNEEDED
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == "") {
            tabsFiltered = tabsData
        }
        else {
            tabsFiltered = []
//            var counter = 0
//            for element in arrayOfFriendsData {
//                if element.lowercased().contains(searchText.lowercased()) {
//                    arrayOfFriends.append(element)
//                    arrayOfFriendsUIDs.append(arrayOfFriendsUIDsData[counter])
//                }
//                counter += 1
//            }
        }
        tbvTabs.reloadData()
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
        performSegue(withIdentifier: "friendsToSignIn", sender: self)
    }
    
    
    
    
    
    //MARK: IBActions
    
    @IBAction func addATabPressed(_ sender: Any) {
        
    }
    
}


