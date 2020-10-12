//
//  VerifyEmailController.swift
//
//  Description: The email verification screen used to wait and check for email verification
//  Creator: Araad Shams
//  Since: v1.0
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class VerifyEmailController : UIViewController {
    
    
    
    //MARK: Global Variables
    
    //MARK: Internet Connection Globals
     var noInternetNotification : UIView? = nil  //Used to create a UIView to store the noInternet banner
     var noInternetLabel : UILabel? = nil    //Used to create the label that says no internet on the banner
     var noInternetConnected : Bool = false  //Keeps track of whether there is an active internet connection
     var noInternetConnectionViewPresent : Bool = false  //Keeps track of whether the internet connection banner is currently being displayed
     var reachability: Reachability!     //Used to run an async check of whether there is a live internet connection
    
    //MARK: Database Globals
    let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database
    
    //MARK: Persistent Data Variable
    let persistentData = UserDefaults() //Used to contain the persistent data in UserDefaults
    
    //MARK: Email & Password Trackers
    var userEmail = ""  //Will be used to add email to the persistent data
    var userPassword = ""   //Will be used to add password to the persistent data
    
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var verifyEmailTitle: UILabel!                           //IBOutlet for the "Verify Your Email" main title
    @IBOutlet weak var verifyEmailDescription: UILabel!                     //IBOutlet for the short verify email description
    @IBOutlet weak var stsWaitingForVerification: UIActivityIndicatorView!  //IBOutlet for the status circle that indicates checking for verification
    @IBOutlet weak var lblWaitingForVerificationStatusDescription: UILabel! //IBOutlet for indicator that contains the action the user should perform
    @IBOutlet weak var btnOpenMailButton: RoundedButton!                    //IBOutlet for the open mail app button
    @IBOutlet weak var btnCloseVerifyScreen: UIButton!                      //IBOutlet for the close verification screen button
    @IBOutlet weak var btnRefreshVerificationStatus: UIButton!              //IBOutlet for the refresh verification status button
    @IBOutlet weak var lblEmailVerificationStatus: UILabel!                 //IBOutlet for the label that indicates the user on the status of their account
    @IBOutlet weak var icnEmailVerifySuccess: UIImageView!                  //IBOutlet for the icon that indicates succesful verification
    
    
    
    
    
    //MARK: Overridden Functions
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        internetConnectionManagerInit()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if going to signin screen, make sure it knows to do all necessary changes
        if segue.identifier == "verifyToSignin" {
            if let nextViewController = segue.destination as? SignInController {
                    nextViewController.comingFromVerificationOrForgotPassword = true
            }
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
    
    
    
    
    //MARK: Verification Manager
    
    // Used to check if email is verified when the reload button is clicked!
    // Params: NONE
    // Return: NONE
    func checkIfEmailVerified() {
        btnRefreshVerificationStatus.alpha = 0
        btnCloseVerifyScreen.isEnabled = false
        stsWaitingForVerification.alpha = 1
        lblWaitingForVerificationStatusDescription.text = "Checking Verification"
        lblEmailVerificationStatus.textColor = UIColor.label
        lblEmailVerificationStatus.text = "Refreshing..."
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            if (error == nil) {
                if (Auth.auth().currentUser!.isEmailVerified) {
                    //Successful verification check
                    self.db.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["verified": true])
                    self.btnRefreshVerificationStatus.alpha = 0
                    self.icnEmailVerifySuccess.alpha = 1
                    self.stsWaitingForVerification.alpha = 0
                    self.lblWaitingForVerificationStatusDescription.text = "Continue to App"
                    self.lblEmailVerificationStatus.textColor = UIColor.systemGreen
                    self.lblEmailVerificationStatus.text = "Email IS Verified"
                    
                    self.persistentData.set(self.userEmail, forKey: "UserEmail")
                    self.persistentData.set(self.userPassword, forKey: "UserPassword")
                    //TODO: Go to tutorial
                    
                }
                else {
                    self.btnCloseVerifyScreen.isEnabled = true
                    self.btnRefreshVerificationStatus.alpha = 1
                    self.stsWaitingForVerification.alpha = 0
                    self.lblWaitingForVerificationStatusDescription.text = "Tap to Refresh"
                    self.lblEmailVerificationStatus.textColor = UIColor.systemRed
                    self.lblEmailVerificationStatus.text = "Email NOT Verified"
                }
            }
            else {
                self.btnCloseVerifyScreen.isEnabled = true
                self.btnRefreshVerificationStatus.alpha = 1
                self.stsWaitingForVerification.alpha = 0
                self.lblWaitingForVerificationStatusDescription.text = "Tap to Refresh"
                self.lblEmailVerificationStatus.textColor = UIColor.systemRed
                self.lblEmailVerificationStatus.text = "Email NOT Verified"
                if(error!._code == 17020) {
                    self.lblWaitingForVerificationStatusDescription.text = "No Internet!"
                }
                else {
                    //UNKNOWN ERROR
                    self.lblWaitingForVerificationStatusDescription.text = "Unknown Error Code: " + String(error!._code)
                }
            }
        })
    }
    
    
    
    
    //MARK: IBActions
    
    @IBAction func openMailButtonPressed(_ sender: Any) {
        let mailURL = URL(string: "message://")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
         }
    }
    
    
    @IBAction func closeVerifyScreenPressed(_ sender: Any) {
        performSegue(withIdentifier: "verifyToSignin", sender: self)
    }
    
    
    @IBAction func refreshVerificationStatusPressed(_ sender: Any) {
        checkIfEmailVerified()
    }
    
    
}
