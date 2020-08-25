//
//  SignUpFromSigninController.swift
//
//  Description: The main sign up screen where users sign up with their name, username, email, and password
//  Creator: Araad Shams
//  Since: v1.0
//


import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore

class SignUpFromSignInController: UIViewController, UITextFieldDelegate {
    
    
    let comingFromSignIn = true    //Used to track whether this controller is opening from the intro or sign-in screen
    

    
    //MARK: Global Variables
    
    //MARK: Text Field Requirement Tracking Globals
    var textFieldParemeterCorrectTracker : Array = [0, 0, 0, 0]     //Used to track the states of the 4 text fields
    var canRegisterEmails : [String] = []     //Keeps track of all of the emails checked that can be used to register
    var canNotRegisterEmails : [String] = []     //Keeps track of all of the emails checked that can NOT be used to register
    var canRegisterUsernames : [String] = []     //Keeps track of all of the usernames checked that can be used to register
    var canNotRegisterUsernames : [String] = []     //Keeps track of all of the usernames checked that can NOT be used to register
    
    //MARK: Inactive/Active Register/Login Butotn Globals
    var textColorStorer : UIColor = UIColor.label   //Used to set the text color of the register button once all fields are ready
    var borderColorStorer : UIColor = UIColor(red: (115.0/255.0), green: (220/255.0), blue: (68.0/255.0), alpha: 1.0)   //Used to set the border color of the register button once all fields are ready
    
    //MARK: Internet Connection Globals
    var noInternetNotification : UIView? = nil  //Used to create a UIView to store the noInternet banner
    var noInternetLabel : UILabel? = nil    //Used to create the label that says no internet on the banner
    var noInternetConnected : Bool = false  //Keeps track of whether there is an active internet connection
    var noInternetConnectionViewPresent : Bool = false  //Keeps track of whether the internet connection banner is currently being displayed
    var reachability: Reachability!     //Used to run an async check of whether there is a live internet connection
    var noInternetConnectionSubviewAdded = false    // Used to track whether the subview has been added yet, in order to cleanly introduce the no internet banner when program starts
    var showNoInternetBannerWhenAvailable = false   // Used to track if the no internet banner was declined as a result of the intro animation!
    
    //MARK: Database Globals
    let db = Firestore.firestore()      //The Database reference which allows reading and writing to the database
    
    
    
    
    
    //MARK: IBOutlets
    @IBOutlet weak var ToMoveLogo: UIImageView!                         //IBOutlet for holding the img from last VC that needs shift
    @IBOutlet weak var PlaceholderLogo: UIImageView!                    //IBOutlet for holding the resultant img to create a nice animation
    @IBOutlet weak var MainContainerView: UIView!                       //IBOutlet that contains all of the other sign-up elements
    @IBOutlet weak var txtFullName: UITextField!                        //IBOutlet where user enters their full name
    @IBOutlet weak var txtUsername: UITextField!                        //IBOutlet where user enters their username
    @IBOutlet weak var txtEmail: UITextField!                           //IBOutlet where user enters their email
    @IBOutlet weak var txtPassword: UITextField!                        //IBOutlet where user sets a password
    @IBOutlet weak var btnRegister: RoundedButton!                      //IBOutlet for the final register button
    @IBOutlet weak var btnAlreadyAUser: UIButton!                       //IBOutlet in case user already has an existing account
    @IBOutlet weak var stsFullNameWrong: UIImageView!                   //IBOutlet for the Full Name text field status X mark
    @IBOutlet weak var stsFullNameRight: UIImageView!                   //IBOutlet for the Full Name text field status check mark
    @IBOutlet weak var stsUsernameWrong: UIImageView!                   //IBOutlet for the Usermame text field status X mark
    @IBOutlet weak var stsUsernameRight: UIImageView!                   //IBOutlet for the Usermame text field status check mark
    @IBOutlet weak var stsUsernameLoading: UIActivityIndicatorView!     //IBOutlet for the Usermame text field loading sign
    @IBOutlet weak var stsEmailWrong: UIImageView!                      //IBOutlet for the Email text field status X mark
    @IBOutlet weak var stsEmailRight: UIImageView!                      //IBOutlet for the Email text field status check mark
    @IBOutlet weak var stsEmailLoading: UIActivityIndicatorView!        //IBOutlet for the Email text field loading sign
    @IBOutlet weak var stsPasswordWrong: UIImageView!                   //IBOutlet for the Password text field status X mark
    @IBOutlet weak var stsPasswordRight: UIImageView!                   //IBOutlet for the Password text field status check mark
    @IBOutlet weak var lblErrorIndicator: UILabel!                      //IBOutlet used to display the current top-priority error
    @IBOutlet weak var stsSigningUp: UIActivityIndicatorView!           //IBOutlet to show the spinning circle when signing up
    
    
    
    //MARK: Overidden Functions
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardManagerInit()
        internetConnectionManagerInit()
        runAnimation()
    }
    
    
    
    
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
        self.txtFullName.delegate = self
        self.txtUsername.delegate = self
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
        
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
        case self.txtFullName:
            self.txtUsername.becomeFirstResponder()
        case self.txtUsername:
            self.txtEmail.becomeFirstResponder()
        case self.txtEmail:
            self.txtPassword.becomeFirstResponder()
        default:
            self.txtPassword.resignFirstResponder()
        }
    }
    
    
    
    
    
    
    
    //MARK: Animations
    
    // Used to create the animation sequence of the moving logo, then fading in icons
    // Params: NONE
    // Return: NONE
    func runAnimation() {
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            //If the user is coming in from intro screen, do intro animation, otherwise, do sign-in to sign-up animation
            if (!self.comingFromSignIn) {
                
                //Used to calculate the end X and Y coordinates for the Logo image to create animation effect
                self.ToMoveLogo.frame.origin.x = (self.PlaceholderLogo.frame.origin.x + self.MainContainerView.frame.origin.x) - ((self.ToMoveLogo.frame.width - self.PlaceholderLogo.frame.width)/2)
                self.ToMoveLogo.frame.origin.y = (self.PlaceholderLogo.frame.origin.y + self.MainContainerView.frame.origin.y) - ((self.ToMoveLogo.frame.height - self.PlaceholderLogo.frame.height)/2)
                
                //Used to calculate the scaling transformation for the logo image to create animation effect
                self.ToMoveLogo.transform = CGAffineTransform(scaleX: (self.PlaceholderLogo.frame.width / self.ToMoveLogo.frame.width) , y: (self.PlaceholderLogo.frame.height / self.ToMoveLogo.frame.height))
            }
            else {
                
                //Used to calculate the end X and Y coordinates for the Logo image to create animation effect
                self.ToMoveLogo.frame.origin.x = self.PlaceholderLogo.frame.origin.x
                self.ToMoveLogo.frame.origin.y = self.PlaceholderLogo.frame.origin.y
                
                //Set all alphas to 1 to make all components visible on first animation
                self.setAllComponentAlphas(alpha: 1)
            }
        }, completion: { (notUsed) in
            
            //If coming from intro, fade in components, otherwise, change the moving logo to placeholder logo to lock in
            if(!self.comingFromSignIn) {
                self.fadeInComponents()
            }
            else {
                self.ToMoveLogo.alpha = 0
                self.PlaceholderLogo.alpha = 1
                self.view.addSubview(self.noInternetNotification!)
                self.noInternetConnectionSubviewAdded = true
                if(self.showNoInternetBannerWhenAvailable) {
                    self.internetConnectionStateChange()
                }
            }
        })
    }
    
    
    
    
    
    
    // Used to fade in all of the components once logo movement animation is done
    // Params: NONE
    // Return: NONE
    func fadeInComponents() {
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.PlaceholderLogo.alpha = 1
            self.setAllComponentAlphas(alpha: 1)
        }, completion: { (notUsed) in
            self.ToMoveLogo.alpha = 0
            self.view.addSubview(self.noInternetNotification!)
            self.noInternetConnectionSubviewAdded = true
            if(self.showNoInternetBannerWhenAvailable) {
                self.internetConnectionStateChange()
            }
        })
    }
    
    
    
    
    
    
    
    // Used to easily set all the main component alphas
    // Params: alpha - The alpha float value to set all the componenets alphas to
    // Return: NONE
    func setAllComponentAlphas(alpha : CGFloat) {
        self.txtFullName.alpha = alpha
        self.txtUsername.alpha = alpha
        self.txtEmail.alpha = alpha
        self.txtPassword.alpha = alpha
        self.btnRegister.alpha = alpha
        self.btnAlreadyAUser.alpha = alpha
        if (alpha == 0) {
            self.stsFullNameWrong.alpha = alpha
            self.stsFullNameRight.alpha = alpha
            self.stsUsernameWrong.alpha = alpha
            self.stsUsernameRight.alpha = alpha
            self.stsUsernameLoading.alpha = alpha
            self.stsEmailWrong.alpha = alpha
            self.stsEmailRight.alpha = alpha
            self.stsEmailLoading.alpha = alpha
            self.stsPasswordWrong.alpha = alpha
            self.stsPasswordRight.alpha = alpha
            self.lblErrorIndicator.alpha = alpha
        }
    }
    
    
    
    // Used to fade out all of the components if the user needs to segue out
    // Params: NONE
    // Return: NONE
    func fadeOutComponents() {
        //To remove the no internet banner when leaving the view controller
        if(noInternetConnected) {
            internetConnectionFound()
        }
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.setAllComponentAlphas(alpha: 0)
            
        }, completion: { (notUsed) in
            
            //If the user is coming from the signin page already, take them back, otherwise, take them forward
            if(!self.comingFromSignIn) {
                self.performSegue(withIdentifier: "signupToSignin", sender: Any.self)
            }
            else {
                self.performSegue(withIdentifier: "signupsubToSignin", sender: Any.self)
            }
        })
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
        
        do {
            try reachability = Reachability()
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
            try reachability.startNotifier()
        } catch {
            print("This is not working.")
        }
        
    }
    
    
    // Called when the internet connectivity state changes
    // Params: NONE
    // Return: NONE
    func internetConnectionStateChange() {
        if(noInternetConnectionSubviewAdded) {
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
            showNoInternetBannerWhenAvailable = false
        }
        else {
            showNoInternetBannerWhenAvailable = true
        }
    }
    
    
    
    
    // The async function that keeps track of the current network connection status
    // Params: note : contains information about the connectivity status
    // Return: NONE
    @objc func reachabilityChanged(_ note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .unavailable {
            self.internetConnectionFound()
            
            //This is needed so that when the connection comes back alive, we can update the field checks
            if(textFieldParemeterCorrectTracker[1] != 0) {
                textFieldParameterChecker(textFieldNum:2)
            }
            if(textFieldParemeterCorrectTracker[2] != 0) {
                textFieldParameterChecker(textFieldNum:3)
            }
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
    

    
    
    
    //MARK: Text Field Requirement Checker
    
    // Used to check the status of all the text fields, and if they meet all the set requirements, called when any textfield value is changed
    // Params: textFieldNum : which text field was changed (1-4)
    // Return: NONE
    func textFieldParameterChecker(textFieldNum:Int) {
        switch(textFieldNum) {
        case 1:
            if let text = txtFullName.text {
                if (text.trimmingCharacters(in: .whitespacesAndNewlines).specificLetterCount(char: " ") == 1) {
                    if(!text.trimmingCharacters(in: .whitespacesAndNewlines).containsNonLetter) {
                        textFieldParemeterCorrectTracker[0] = 2
                        stsFullNameWrong.alpha = 0
                        stsFullNameRight.alpha = 1
                        lblErrorIndicator.text = ""
                        if(textFieldParemeterCorrectTracker[1] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 2)
                        }
                        else if(textFieldParemeterCorrectTracker[2] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 3)
                        }
                        else if(textFieldParemeterCorrectTracker[3] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 4)
                        }
                    }
                    else {
                        textFieldParemeterCorrectTracker[0] = 1
                        stsFullNameRight.alpha = 0
                        stsFullNameWrong.alpha = 1
                        lblErrorIndicator.text = "Full Name cannot contain special characters or numbers"
                    }
                }
                else {
                    textFieldParemeterCorrectTracker[0] = 1
                    stsFullNameRight.alpha = 0
                    stsFullNameWrong.alpha = 1
                    lblErrorIndicator.text = "Full Name must contain first and last name (ex. Bob Smith)"
                }
            }
            
            break;
            
        case 2:
            if var text = txtUsername.text {
                text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if(text.count >= 5 && text.count <= 15) {
                    if(!text.containsSpecialCharacter) {
                        stsUsernameLoading.alpha = 1
                        stsUsernameRight.alpha = 0
                        stsUsernameWrong.alpha = 0
                        
                        if(canRegisterUsernames.contains(text)) {
                            textFieldParemeterCorrectTracker[1] = 2
                            stsUsernameRight.alpha = 1
                            stsUsernameLoading.alpha = 0
                            stsUsernameWrong.alpha = 0
                            if(textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) {
                                lblErrorIndicator.text = ""
                            }
                            if(textFieldParemeterCorrectTracker[0] == 1)
                            {
                                textFieldParameterChecker(textFieldNum: 1)
                            }
                            else if(textFieldParemeterCorrectTracker[2] == 1)
                            {
                                textFieldParameterChecker(textFieldNum: 3)
                            }
                            else if(textFieldParemeterCorrectTracker[3] == 1)
                            {
                                textFieldParameterChecker(textFieldNum: 4)
                            }
                        }
                            
                        else if(canNotRegisterUsernames.contains(text)) {
                            textFieldParemeterCorrectTracker[1] = 1
                            stsUsernameRight.alpha = 0
                            stsUsernameLoading.alpha = 0
                            stsUsernameWrong.alpha = 1
                            if(textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) {
                                lblErrorIndicator.text = "Username already in use!"
                            }
                        }
                            
                        else {
                            if(textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) {
                                lblErrorIndicator.text = ""
                            }
                            db.collection("Usernames").document(text).getDocument { (document, error) in
                                
                                if error != nil {
                                    if (error!._code == 14) {
                                        self.internetConnectionLost()
                                    }
                                    else {
                                        self.internetConnectionFound()
                                    }
                                }
                                else {
                                    self.internetConnectionFound()
                                    
                                    if let document = document, document.exists {
                                        self.canNotRegisterUsernames.append(text)
                                        self.textFieldParameterChecker(textFieldNum: 2)
                                    }
                                    else {
                                        self.canRegisterUsernames.append(text)
                                        self.textFieldParameterChecker(textFieldNum: 2)
                                    }
                                }
                                
                            }
                        }
                        
                    }
                    else {
                        textFieldParemeterCorrectTracker[1] = 1
                        stsUsernameLoading.alpha = 0
                        stsUsernameRight.alpha = 0
                        stsUsernameWrong.alpha = 1
                        if(textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) {
                            lblErrorIndicator.text = "Username cannot contain special characters"
                        }
                    }
                }
                else {
                    textFieldParemeterCorrectTracker[1] = 1
                    stsUsernameLoading.alpha = 0
                    stsUsernameRight.alpha = 0
                    stsUsernameWrong.alpha = 1
                    if(textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) {
                        lblErrorIndicator.text = "Username must be between 5 and 15 characters in length"
                    }
                }
            }
            break;
            
        case 3:
            if var text = txtEmail.text {
                text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if (text.isValidEmail && text.contains("@")) {
                    textFieldParemeterCorrectTracker[2] = 1
                    stsEmailRight.alpha = 0
                    stsEmailLoading.alpha = 1
                    stsEmailWrong.alpha = 0
                    if((textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) && (textFieldParemeterCorrectTracker[1] == 2 || textFieldParemeterCorrectTracker[1] == 0)) {
                        lblErrorIndicator.text = ""
                    }
                    
                    if(canRegisterEmails.contains(text)) {
                        textFieldParemeterCorrectTracker[2] = 2
                        stsEmailRight.alpha = 1
                        stsEmailLoading.alpha = 0
                        stsEmailWrong.alpha = 0
                        if((textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) && (textFieldParemeterCorrectTracker[1] == 2 || textFieldParemeterCorrectTracker[1] == 0)) {
                            lblErrorIndicator.text = ""
                        }
                        if(textFieldParemeterCorrectTracker[0] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 1)
                        }
                        else if(textFieldParemeterCorrectTracker[1] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 2)
                        }
                        else if(textFieldParemeterCorrectTracker[3] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 4)
                        }
                    }
                        
                    else if(canNotRegisterEmails.contains(text)) {
                        textFieldParemeterCorrectTracker[2] = 1
                        stsEmailRight.alpha = 0
                        stsEmailLoading.alpha = 0
                        stsEmailWrong.alpha = 1
                        if((textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) && (textFieldParemeterCorrectTracker[1] == 2 || textFieldParemeterCorrectTracker[1] == 0)) {
                            lblErrorIndicator.text = "Email already in use!"
                        }
                    }
                        
                    else {
                        Auth.auth().signIn(withEmail: text, password: " ") { (user, error) in
                            if error != nil {
                                if (error!._code == 17020) {
                                    self.internetConnectionLost()
                                }
                                else {
                                    self.internetConnectionFound()
                                }
                                if (error!._code == 17009) {
                                    self.canNotRegisterEmails.append(text)
                                    self.textFieldParameterChecker(textFieldNum: 3)
                                } else if(error!._code == 17011) {
                                    //email doesn't exist
                                    self.canRegisterEmails.append(text)
                                    self.textFieldParameterChecker(textFieldNum: 3)
                                }
                            }
                        }
                    }
                    
                }
                else {
                    textFieldParemeterCorrectTracker[2] = 1
                    stsEmailRight.alpha = 0
                    stsEmailLoading.alpha = 0
                    stsEmailWrong.alpha = 1
                    if((textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) && (textFieldParemeterCorrectTracker[1] == 2 || textFieldParemeterCorrectTracker[1] == 0)) {
                        lblErrorIndicator.text = "Email must be valid. You will be required to verify!"
                    }
                }
            }
            else {
                textFieldParemeterCorrectTracker[1] = 1
                stsUsernameLoading.alpha = 0
                stsUsernameRight.alpha = 0
                stsUsernameWrong.alpha = 1
                if(textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) {
                    lblErrorIndicator.text = "Username cannot contain special characters"
                }
            }
            break;
            
        case 4:
            if var text = txtPassword.text {
                text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if(text.count >= 8 && text.count <= 25) {
                    if(!(text.lowercased() == text)) {
                        textFieldParemeterCorrectTracker[3] = 2
                        stsPasswordRight.alpha = 1
                        stsPasswordWrong.alpha = 0
                        if((textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) && (textFieldParemeterCorrectTracker[1] == 2 || textFieldParemeterCorrectTracker[1] == 0) && (textFieldParemeterCorrectTracker[2] == 2 || textFieldParemeterCorrectTracker[2] == 0)) {
                            lblErrorIndicator.text = ""
                        }
                        if(textFieldParemeterCorrectTracker[0] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 1)
                        }
                        else if(textFieldParemeterCorrectTracker[1] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 2)
                        }
                        else if(textFieldParemeterCorrectTracker[2] == 1)
                        {
                            textFieldParameterChecker(textFieldNum: 3)
                        }
                    }
                    else {
                        textFieldParemeterCorrectTracker[3] = 1
                        stsPasswordRight.alpha = 0
                        stsPasswordWrong.alpha = 1
                        if((textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) && (textFieldParemeterCorrectTracker[1] == 2 || textFieldParemeterCorrectTracker[1] == 0) && (textFieldParemeterCorrectTracker[2] == 2 || textFieldParemeterCorrectTracker[2] == 0)) {
                            lblErrorIndicator.text = "Password must contain at least one uppercase"
                        }
                    }
                }
                else {
                    textFieldParemeterCorrectTracker[3] = 1
                    stsPasswordRight.alpha = 0
                    stsPasswordWrong.alpha = 1
                    if((textFieldParemeterCorrectTracker[0] == 2 || textFieldParemeterCorrectTracker[0] == 0) && (textFieldParemeterCorrectTracker[1] == 2 || textFieldParemeterCorrectTracker[1] == 0) && (textFieldParemeterCorrectTracker[2] == 2 || textFieldParemeterCorrectTracker[2] == 0)) {
                        lblErrorIndicator.text = "Password must be between 8 and 25 characters in length"
                    }
                }
            }
            break;
            
        default:
            
            break;
        }
        
        //If all parameters are satisfied, then make register button clickable, else don't
        if(textFieldParemeterCorrectTracker[0] == 2 && textFieldParemeterCorrectTracker[1] == 2 && textFieldParemeterCorrectTracker[2] == 2 && textFieldParemeterCorrectTracker[3] == 2) {
            btnRegister.setTitleColor(textColorStorer, for: .normal)
            btnRegister.borderColor = borderColorStorer
            btnRegister.isEnabled = true
        }
        else {
            btnRegister.setTitleColor(UIColor.lightGray, for: .normal)
            btnRegister.borderColor = UIColor.lightGray
            btnRegister.isEnabled = false
        }
    }
    
    
    
    
    
    
    // MARK: Sign Up Logic
    
    // Used to sign up the user once the sign up button has been pressed
    // Params: all of the UITextField string values
    // Return: NONE
    func signUp(fullNameStr: String, usernameStr: String, emailStr: String, passwordStr: String) {
        
        //Disabling the components when loading
        stsSigningUp.alpha = 1
        btnRegister.setTitleColor(UIColor.lightGray, for: .normal)
        btnRegister.borderColor = UIColor.lightGray
        btnRegister.isEnabled = false
        txtFullName.isEnabled = false
        txtUsername.isEnabled = false
        txtEmail.isEnabled = false
        txtPassword.isEnabled = false
        
        Auth.auth().createUser(withEmail: emailStr, password: passwordStr) { authResult, error in
            
            if error != nil {
                self.stsSigningUp.alpha = 0
                self.btnAlreadyAUser.isEnabled = true
                self.btnRegister.setTitleColor(self.textColorStorer, for: .normal)
                self.btnRegister.borderColor = self.borderColorStorer
                self.btnRegister.isEnabled = true
                self.txtFullName.isEnabled = true
                self.txtUsername.isEnabled = true
                self.txtEmail.isEnabled = true
                self.txtPassword.isEnabled = true
                
                if (error!._code == 17020) {
                    self.internetConnectionLost()
                    self.lblErrorIndicator.text = "No internet connection!"
                }
                else {
                    self.internetConnectionFound()
                }
                
                if (error!._code == 17008 || error!._code == 17007) {
                    self.lblErrorIndicator.text = "Email address is invalid!"
                }
                else if(error!._code == 17026) {
                    self.lblErrorIndicator.text = "Password is too weak!"
                }
                else {
                    //UNKNOWN ERROR!
                    self.lblErrorIndicator.text = "Unknown Error Code: " + String(error!._code)
                }
            }
            else if authResult != nil{
                //Succesfully created the user!
                
                //Making the new user object from User model
                let newUser = User(displayName: fullNameStr, username: usernameStr, email: emailStr, verified: false, accountCreated: Date.init())
                
                //Setting appropriate collections, Users and Usernames for new user
                self.db.collection("Usernames").document(usernameStr).setData(["used": true])
                self.db.collection("Users").document(authResult!.user.uid).setData(newUser.getFirebaseFormat())
                
                //Send the verification email to the user
                authResult!.user.sendEmailVerification(completion: { (error) in
                    if(error != nil) {
                        //UNKNOWN ERROR
                        self.lblErrorIndicator.text = "Unknown Error Code: " + String(error!._code)
                    }
                    else {
                        //If all successful, open the verification screen
                        if(!self.comingFromSignIn) {
                            self.performSegue(withIdentifier: "signupToVerify", sender: self)
                        }
                        else {
                            self.performSegue(withIdentifier: "signupFromSigninToVerify", sender: self)
                        }
                    }
                  })
            }
            else {
                //UNKNOWN ERROR!
                self.stsSigningUp.alpha = 0
                self.btnAlreadyAUser.isEnabled = true
                self.btnRegister.setTitleColor(self.textColorStorer, for: .normal)
                self.btnRegister.borderColor = self.borderColorStorer
                self.btnRegister.isEnabled = true
                self.txtFullName.isEnabled = true
                self.txtUsername.isEnabled = true
                self.txtEmail.isEnabled = true
                self.txtPassword.isEnabled = true
                self.lblErrorIndicator.text = "Please try again!"
            }
        }
    }
    
    
    
    
    // MARK: IBActions
    
    @IBAction func btnRegisterClicked(_ sender: Any) {
        btnAlreadyAUser.isEnabled = false
        signUp(fullNameStr: txtFullName.text!, usernameStr: txtUsername.text!, emailStr: txtEmail.text!, passwordStr: txtPassword.text!)
    }
    
    @IBAction func btnAlreadyUserClicked(_ sender: Any) {
        btnAlreadyAUser.isEnabled = false
        btnRegister.isEnabled = false
        txtFullName.isEnabled = false
        txtUsername.isEnabled = false
        txtEmail.isEnabled = false
        txtPassword.isEnabled = false
        fadeOutComponents()
    }
    
    
    
    @IBAction func txtFullNameEdited(_ sender: Any) {
        textFieldParameterChecker(textFieldNum:1)
    }
    
    @IBAction func txtUsernameEdited(_ sender: Any) {
        textFieldParameterChecker(textFieldNum:2)
    }
    
    @IBAction func txtEmailEdited(_ sender: Any) {
        textFieldParameterChecker(textFieldNum:3)
    }
    
    @IBAction func txtPasswordEdited(_ sender: Any) {
        textFieldParameterChecker(textFieldNum:4)
    }
}





















