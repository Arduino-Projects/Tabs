//
//  SignInController.swift
//
//  Description: The sign ip screen where users sign ip with their username/email and password
//  Creator: Araad Shams
//  Since: v1.0
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignInController: UIViewController, UITextFieldDelegate {
    
    //Defined in the prepareForSegue method in previous VC
    var comingFromVerification = false

    

    //MARK: Global Variables
    
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
    @IBOutlet weak var imgToBeMoved: UIImageView!               //IBOutlet for holding the img from last VC that needs shift
    @IBOutlet weak var imgPlaceholder: UIImageView!             //IBOutlet for holding the resultant img to create a nice animation
    @IBOutlet weak var txtEmail: UITextField!                   //IBOutlet where user enters their email
    @IBOutlet weak var txtPassword: UITextField!                //IBOutlet where user sets a password
    @IBOutlet weak var btnLoginButton: RoundedButton!           //IBOutlet for the final login button
    @IBOutlet weak var btnNotAUser: UIButton!                   //IBOutlet in case user does not already have an existing account
    @IBOutlet weak var btnForgottenPassword: UIButton!          //IBOutlet in case user forgets password
    @IBOutlet weak var stsEmailRight: UIImageView!              //IBOutlet indicating that the email provided meets the conditions
    @IBOutlet weak var stsEmailWrong: UIImageView!              //IBOutlet indicating that the email provided doesn't meet the conditions
    @IBOutlet weak var stsPasswordRight: UIImageView!           //IBOutlet indicating that the password provided meets the conditions
    @IBOutlet weak var stsPasswordWrong: UIImageView!           //IBOutlet indicating that the password provided doesn't meet the conditions
    @IBOutlet weak var lblErrorIndicator: UILabel!              //IBOutlet used to indicate errors to the user
    @IBOutlet weak var stsLoggingIn: UIActivityIndicatorView!   //IBOutlet to indicate the user is logging in
    
    
    
    
    //MARK: Overidden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performComingFromVerifyComponentSetup()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardManagerInit()
        internetConnectionManagerInit()
        runAnimationOnCondition()
    }
    
    
    
    
    
    //MARK: Keyboard + TextField UI Management
    
    // Used to manage all keyboard spacing functionality (moving view up, hiding keyboard when tap outside)
    // Params: NONE
    // Return: NONE
    func keyboardManagerInit() {
        //Setting all text field delegates as SignUpController
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
            
            //Used to calculate the end X and Y coordinates for the Logo image to create animation effect
            self.imgToBeMoved.frame.origin.x = self.imgPlaceholder.frame.origin.x
            self.imgToBeMoved.frame.origin.y = self.imgPlaceholder.frame.origin.y
            
            //Setting all components to visible
            self.setAllComponentAlphas(alpha : 1)
            
        }, completion: { (notUsed) in
            
            //Once complete, replace moving image with locked image
            self.imgToBeMoved.alpha = 0
            self.imgPlaceholder.alpha = 1
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
        self.txtEmail.alpha = alpha
        self.txtPassword.alpha = alpha
        self.btnLoginButton.alpha = alpha
        self.btnNotAUser.alpha = alpha
        self.btnForgottenPassword.alpha = alpha
        if(alpha == 0) {
            stsEmailRight.alpha = alpha
            stsEmailWrong.alpha = alpha
            stsPasswordRight.alpha = alpha
            stsPasswordWrong.alpha = alpha
            lblErrorIndicator.alpha = alpha
        }
    }
    
    
    
    
    // Used to fade out all of the components if the user needs to segue out
    // Params: NONE
    // Return: NONE
    func fadeOutComponents() {
        //To remove the no internet banner when leaving the view controller
        if(noInternetConnected) {
            self.noInternetConnected = false
            self.internetConnectionStateChange()
        }
        
        btnLoginButton.isEnabled = false
        btnLoginButton.setTitleColor(UIColor.lightGray, for: .normal)
        btnLoginButton.borderColor = UIColor.lightGray
        
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.setAllComponentAlphas(alpha : 0)
        }, completion: { (notUsed) in
            self.performSegue(withIdentifier: "signinToSignup", sender: Any.self)
        })
    }
    
    
    
    // Used to fix the setup to no animation mode when coming from verify controller
    // Params: NONE
    // Return: NONE
    func performComingFromVerifyComponentSetup() {
        //Setup all of these components in advance for different appearance when coming from verify VC
        if(comingFromVerification) {
            imgToBeMoved.alpha = 0
            imgPlaceholder.alpha = 1
            txtEmail.alpha = 1
            txtEmail.text = ""
            txtEmail.isEnabled = true
            txtPassword.alpha = 1
            txtPassword.text = ""
            txtPassword.isEnabled = true
            btnLoginButton.setTitleColor(textColorStorer, for: .normal)
            btnLoginButton.borderColor = borderColorStorer
            btnLoginButton.isEnabled = true
            btnLoginButton.alpha = 1
            btnNotAUser.isEnabled = true
            btnNotAUser.alpha = 1
            btnForgottenPassword.isEnabled = true
            btnForgottenPassword.alpha = 1
            stsEmailRight.alpha = 0
            stsEmailWrong.alpha = 0
            stsPasswordRight.alpha = 0
            stsPasswordWrong.alpha = 0
            lblErrorIndicator.text = ""
            stsLoggingIn.alpha = 0
        }
    }
    
    
    
    
    // Only runs the animation if not coming from the verify VC
    // Params: NONE
    // Return: NONE
    func runAnimationOnCondition() {
        if(!comingFromVerification) {
            runAnimation()
        }
        else {
            self.view.addSubview(self.noInternetNotification!)
            self.noInternetConnectionSubviewAdded = true
            if(self.showNoInternetBannerWhenAvailable) {
                self.internetConnectionStateChange()
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
    
    
    
    
    
    
    
    // Sets the email and password indicator alphas to simulate appearing and dissappearing
    // Params: emailRight: The alpha value for the email correct indicator, passwordRight: The alpha value for the password correct indicator
    // Return: NONE
    func setEmailPasswordStatusIndicators(emailRight : CGFloat, passwordRight : CGFloat) {
        stsEmailWrong.alpha = 1 - emailRight
        stsEmailRight.alpha = emailRight
        stsPasswordWrong.alpha = 1 - passwordRight
        stsPasswordRight.alpha = passwordRight
    }
    
    
    
    
    
    // Used to log in the user!
    // Params: emailStr: the users email, passwordStr: the users password
    // Return: NONE
    func login(emailStr : String, passwordStr: String) {
        
        //Once all preliminary checks are complete, this method is used to check the email and password with the database
        Auth.auth().signIn(withEmail: emailStr, password: passwordStr) { (user, error) in
            if error != nil {
                if (error!._code == 17009) {
                    self.setEmailPasswordStatusIndicators(emailRight: 1, passwordRight: 0)
                    self.lblErrorIndicator.text = "Password is incorrect!"
                }
                else if(error!._code == 17010) {
                    self.setEmailPasswordStatusIndicators(emailRight: 1, passwordRight: 0)
                    self.lblErrorIndicator.text = "Too many incorrect attempts, try again in a few minutes"
                }
                else if(error!._code == 17011 || error!._code == 17008) {
                    self.setEmailPasswordStatusIndicators(emailRight: 0, passwordRight: 0)
                    self.lblErrorIndicator.text = "Email and password are both incorrect!"
                }
                else if(error!._code == 17020) {
                    self.lblErrorIndicator.text = "No internet correction!"
                }
                else if(error!._code == 17005) {
                    self.lblErrorIndicator.text = "Your account has been disabled for misconduct!"
                }
                else {
                    //UNKNOWN ERROR
                    self.setEmailPasswordStatusIndicators(emailRight: 0, passwordRight: 0)
                    self.lblErrorIndicator.text = "Unknown Error Code: " + String(error!._code)
                }
                self.btnLoginButton.isEnabled = true
                self.btnLoginButton.setTitleColor(self.textColorStorer, for: .normal)
                self.btnLoginButton.borderColor = self.borderColorStorer
                self.btnNotAUser.isEnabled = true
                self.btnForgottenPassword.isEnabled = true
                self.txtEmail.isEnabled = true
                self.txtPassword.isEnabled = true
            }
            else {
                //SUCCESFUL SIGNIN
                if(!Auth.auth().currentUser!.isEmailVerified) {
                    //IF NOT VERIFIED, SEND VERIFICATION EMAIL!
                    Auth.auth().currentUser!.sendEmailVerification(completion: { (error) in
                      if(error != nil) {
                        if(error!._code == 17010) {
                            //Means verification email was just sent, so it won't send another one too fast
                            self.performSegue(withIdentifier: "signinToVerify", sender: self)
                        }
                        else {
                            //UNKNOWN ERROR
                            self.setEmailPasswordStatusIndicators(emailRight: 1, passwordRight: 1)
                            self.lblErrorIndicator.text = "Unknown Error Code: " + String(error!._code)
                            self.btnLoginButton.isEnabled = true
                            self.btnLoginButton.setTitleColor(self.textColorStorer, for: .normal)
                            self.btnLoginButton.borderColor = self.borderColorStorer
                            self.btnNotAUser.isEnabled = true
                            self.btnForgottenPassword.isEnabled = true
                            self.txtEmail.isEnabled = true
                            self.txtPassword.isEnabled = true
                        }
                      }
                      else {
                          //If all successful, open the verification screen
                          self.performSegue(withIdentifier: "signinToVerify", sender: self)
                      }
                    })
                }
                else {
                    //TODO: Verified, open app
                }
            }
            self.stsLoggingIn.alpha = 0
        }
    }
    
    

    
    
    // Run when the login button is pressed, to handle all of the condition checking, and disabling components
    // Params: NONE
    // Return: NONE
    @IBAction func btnLoginPressed(_ sender: Any) {
        if(txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" && txtPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
            self.setEmailPasswordStatusIndicators(emailRight: 0, passwordRight: 0)
            lblErrorIndicator.text = "Email and password fields are empty!"
        }
        else if(txtPassword.text! == "") {
            self.setEmailPasswordStatusIndicators(emailRight: 0, passwordRight: 0)
            stsEmailWrong.alpha = 0
            stsEmailRight.alpha = 0
            lblErrorIndicator.text = "Password field is empty!"
        }
        else if(txtEmail.text! == "") {
            self.setEmailPasswordStatusIndicators(emailRight: 0, passwordRight: 0)
            stsPasswordWrong.alpha = 0
            stsPasswordRight.alpha = 0
            lblErrorIndicator.text = "Password field is empty!"
        }
        else {
            //MEETS ALL THE PRELIMINARY REQUIREMENTS, BRING TO DB
            btnNotAUser.isEnabled = false
            btnForgottenPassword.isEnabled = false
            stsEmailWrong.alpha = 0
            stsEmailRight.alpha = 0
            stsPasswordWrong.alpha = 0
            stsPasswordRight.alpha = 0
            lblErrorIndicator.text = ""
            stsLoggingIn.alpha = 1
            btnLoginButton.isEnabled = false
            btnLoginButton.setTitleColor(UIColor.lightGray, for: .normal)
            btnLoginButton.borderColor = UIColor.lightGray
            txtEmail.isEnabled = false
            txtPassword.isEnabled = false
            login(emailStr: txtEmail.text!, passwordStr: txtPassword.text!)
        }
    }
    
    
    
    
    
    //MARK: IBActions
    
    @IBAction func btnNotAUserPressed(_ sender: Any) {
        btnNotAUser.isEnabled = false
        btnForgottenPassword.isEnabled = false
        txtEmail.isEnabled = false
        txtPassword.isEnabled = false
        fadeOutComponents()
    }
    
    
    @IBAction func btnForgotPasswordPressed(_ sender: Any) {
        //TODO: Create forgot password screen!
    }
    
    
    //TODO: Remove un-necessary outlets
    @IBAction func txtEmailEdited(_ sender: Any) {
        
    }
    
    @IBAction func txtPasswordEdited(_ sender: Any) {
        
    }
    
    
}
