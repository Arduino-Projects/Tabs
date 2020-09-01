//
//  BetsController.swift
//  Bets App
//
//  Created by Wania Shams on 31/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class BetsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    
    let currencyMajor = "$"
    let currencyMinor = "¢"
    
    //MARK: Internet Connection Globals
    var noInternetNotification : UIView? = nil  //Used to create a UIView to store the noInternet banner
    var noInternetLabel : UILabel? = nil    //Used to create the label that says no internet on the banner
    var noInternetConnected : Bool = false  //Keeps track of whether there is an active internet connection
    var noInternetConnectionViewPresent : Bool = false  //Keeps track of whether the internet connection banner is currently being displayed
    var reachability: Reachability!     //Used to run an async check of whether there is a live internet connection
    
    //MARK: Table Refresh Controller
      var refreshControl = UIRefreshControl() //Used to perform the drag down to refresh
      
      //MARK: Persistent Data Variable
      let persistentData = UserDefaults() //Used to contain the persistent data in UserDefaults
      
      //MARK: Database Globals
      let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database

      //MARK: Bets Variables
      var betsData : [[String:Any]] = []
      var betsFiltered : [[String:Any]] = []
    //MARK: IBOutlets
    
    @IBOutlet weak var sgvOngoingOrFinished: UISegmentedControl!
    @IBOutlet weak var lblBets: UILabel!
    
    @IBOutlet weak var btnAddBet: UIButton!
    
    @IBOutlet weak var tbvBets: UITableView!
    @IBOutlet weak var sbrSearchThroughBets: UISearchBar!
    
    override func viewDidLoad() {
          super.viewDidLoad()
          internetConnectionManagerInit()
          keyboardManagerInit()
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
           self.sbrSearchThroughBets.delegate = self
           tbvBets.keyboardDismissMode = .interactive
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
           case self.sbrSearchThroughBets:
               self.sbrSearchThroughBets.resignFirstResponder()
           default:
               self.sbrSearchThroughBets.resignFirstResponder()
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
           tbvBets.addSubview(refreshControl)
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
                        self.pullBetsFromDB()
                    }
                }
            }
            else {
                pullBetsFromDB()
            }
        }
        
        // Read the actual friends data from the DB
        // Params: NONE
        // Return: NONE
        func pullBetsFromDB() {
            db.collection("Bets").whereField("uids", arrayContains: Auth.auth().currentUser!.uid).getDocuments { (docs, err) in
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

                                self.usePersistentDataToPresentAndStoreBets(Bets: docs!, friendsUIDs: self.persistentData.array(forKey: "FriendsUIDsList")!, friendsNames: self.persistentData.array(forKey: "FriendsNamesList")!)
                            }
                        }
                    }
                    else {
                        self.usePersistentDataToPresentAndStoreBets(Bets: docs!, friendsUIDs: self.persistentData.array(forKey: "FriendsUIDsList")!, friendsNames: self.persistentData.array(forKey: "FriendsNamesList")!)
                    }
                }
            }
        }
        
        
        func usePersistentDataToPresentAndStoreBets(Bets: QuerySnapshot, friendsUIDs : [Any], friendsNames : [Any]) {
            betsData = []
            var counter = 0
            for doc in Bets.documents {
                betsData.append([:])
                print(doc.data())
                if((doc.data()["uids"] as! [String])[0] == Auth.auth().currentUser!.uid) {
                    let index = friendsUIDs.firstIndex{ $0 as! String == (doc.data()["uids"] as! [String])[1]}
                    
                    betsData[counter]["otherUserUID"] = (doc.data()["uids"] as! [String])[1]
                    betsData[counter]["otherUserName"] = (friendsNames as! [String])[index!]
                }
                else {
                    let index = friendsUIDs.firstIndex{ $0 as! String == (doc.data()["uids"] as! [String])[0]}
                    
                    betsData[counter]["otherUserUID"] = (doc.data()["uids"] as! [String])[0]
                    betsData[counter]["otherUserName"] = (friendsNames as! [String])[index!]
                }
                
                betsData[counter]["confirmed"] = (doc.data()["confirmed"] as! Bool)
                betsData[counter]["amount"] = (doc.data()["money"] as! NSNumber).floatValue
                betsData[counter]["docID"] = doc.documentID
                betsData[counter]["status"] = (doc.data()["status"] as! String)
                betsData[counter]["time"] = (doc.data()["time"] as! FirebaseFirestore.Timestamp).dateValue()
                print(betsData[counter]["time"])
                betsData[counter]["title"] = (doc.data()["title"] as! String)
                counter += 1
            }
            
            betsData = betsData.sorted { ($0["time"] as! Date) < ($1["time"]  as! Date)}
            betsFiltered = betsData
            
            self.persistentData.set(betsData, forKey: "BetsList")
            User.betsLoaded = true
            self.refreshControl.endRefreshing()
            tbvBets.reloadData()
        }
        
        
        
        
        
        //MARK: Table View Management
        
        // Initialize the table view, add the delegate declaration, and temporarily read in data from storage if available
        // Params: NONE
        // Return: NONE
        func tableViewInit() {
            if(persistentData.array(forKey: "BetsList") != nil) {
                betsData = persistentData.array(forKey: "BetsList") as! [[String : Any]]
                betsFiltered = betsData
            }
            
    //        if(persistentData.array(forKey: "FriendsUsernamesAndEmailsList") != nil) {
    //            friendsUsernamesAndEmails = persistentData.array(forKey: "FriendsUsernamesAndEmailsList") as! [String]
    //            btnAddATab.isEnabled = true
    //        }
            tbvBets.register(UINib(nibName: "BetsCell", bundle: nil), forCellReuseIdentifier: "BetsCell")
            tbvBets.delegate = self
            tbvBets.dataSource = self
            
            if(!User.betsLoaded) {
                checkIfSignedInThenGetData()
            }
        }
        
        
        // Function to check the number of rows in each section
        // Params: UNNEEDED
        // Return: UNNEEDED
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return betsFiltered.count
        }
        
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "BetsCell", for: indexPath) as! BetsCell
//
//            cell.lblBetDate.text! = "2 days ago"
//            cell.lblBetName.text! = "Steal Beans"
//            cell.lblBetWith.text! = "Abed White"
//            cell.lblBetAmount.text! = "$640"
//
//            return cell
//        }
        

        
        // Function to retrieve the cell object for each cell at an indexpath
        // Params: UNNEEDED
        // Return: UNNEEDED
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BetsCell", for: indexPath) as! BetsCell
            let currentCellData = betsFiltered[indexPath.row]

            cell.lblBetWith.text! = currentCellData["otherUserName"] as! String
            cell.lblBetName.text! = currentCellData["title"] as! String

            if((currentCellData["amount"] as! Float) < 1) {
                cell.lblBetAmount.text! = String(Int((currentCellData["amount"] as! Float)*100)) + currencyMinor
            }
            else if((currentCellData["totalAmount"] as! Float) < 100) {
                cell.lblBetAmount.text! = currencyMajor + String((currentCellData["amount"] as! Float))
            }
            else {
                cell.lblBetAmount.text! = currencyMajor + String(Int(currentCellData["amount"] as! Float))
            }
            
            //up to 60s ago: 60 seconds ago
            //up to 60 minutes: 60minutes ago
            //up to 24 hours: 24 hours ago
            //up to 7 days: 2d ago/1 day ago
            //after that, date
            //more than a year ago: date, year
            
            var date = (currentCellData["time"] as! Date)
            var dateInSeconds = (currentCellData["time"] as! Date).timeIntervalSinceNow
            let currentYear = Calendar.current.component(.year, from: Date())
            let dateFormatter = DateFormatter()

            if(dateInSeconds < 60){
                if(dateInSeconds == 1){
                    cell.lblBetDate.text! = String(dateInSeconds) + " second ago"
                }
                else{
                    cell.lblBetDate.text! = String(dateInSeconds) + " seconds ago"
                }
            }
            else if(dateInSeconds.truncatingRemainder(dividingBy: 60) < 60){
                if(dateInSeconds.truncatingRemainder(dividingBy: 60) == 1){
                    cell.lblBetDate.text! = String(dateInSeconds)  + " minute ago"
                }
                else{
                    cell.lblBetDate.text! = String(dateInSeconds.truncatingRemainder(dividingBy: 60)) + " minutes ago"
                }
            }
            else if(dateInSeconds.truncatingRemainder(dividingBy: 60).truncatingRemainder(dividingBy: 60) < 24){
                if(dateInSeconds.truncatingRemainder(dividingBy: 3600) == 1){
                    cell.lblBetDate.text! = String(dateInSeconds.truncatingRemainder(dividingBy: 3600))  + " hour ago"
                }
                else{
                    cell.lblBetDate.text! = String(dateInSeconds.truncatingRemainder(dividingBy: 3600)) + " hours ago"
                }
            }
            else if(dateInSeconds.truncatingRemainder(dividingBy: 86400) < 7){
                if(dateInSeconds.truncatingRemainder(dividingBy: 86400) == 1){
                    cell.lblBetDate.text! = String(dateInSeconds.truncatingRemainder(dividingBy: 86400))  + " day ago"
                }
                else{
                    cell.lblBetDate.text! = String(dateInSeconds.truncatingRemainder(dividingBy: 86400)) + " days ago"
                }
            }
            else if(Calendar.current.component(.year, from: date) < currentYear){

                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                cell.lblBetDate.text! = dateFormatter.string(from: date)
            }
            else if(dateInSeconds < 0){
                print("Something has gone very wrong")
            }
            else{
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
                cell.lblBetDate.text! = dateFormatter.string(from: date)
                
            }
            
            return cell
        }
//
        
        // Function to retrieve the total number of sections eg.("A", "B", "F")
        // Params: UNNEEDED
        // Return: UNNEEDED
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
        
        
        
        //MARK: Data Sorting & Search Bar
        
        
        // Function that is called whenever the text in the text bar is changed
        // Params: UNNEEDED
        // Return: UNNEEDED
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if(searchText == "") {
                betsFiltered = betsData
            }
            else {
                betsFiltered = []
    //            var counter = 0
    //            for element in arrayOfFriendsData {
    //                if element.lowercased().contains(searchText.lowercased()) {
    //                    arrayOfFriends.append(element)
    //                    arrayOfFriendsUIDs.append(arrayOfFriendsUIDsData[counter])
    //                }
    //                counter += 1
    //            }
            }
            tbvBets.reloadData()
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
        


    
}

