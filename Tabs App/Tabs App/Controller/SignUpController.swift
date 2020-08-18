//
//  SignUpController.swift
//
//  Description: The main sign up screen where users sign up with their name, username, email, and password
//  Creator: Araad Shams
//  Since: v1.0
//


import UIKit

class SignUpController: UIViewController {
    
    //GLOBALS
    let comingFromSignIn = false    //Used to track whether this controller is opening from the intro or sign-in screen
    
    
    //IBOutlets
    @IBOutlet weak var ToMoveLogo: UIImageView!         //IBOutlet for holding the img from last VC that needs shift
    @IBOutlet weak var PlaceholderLogo: UIImageView!    //IBOutlet for holding the resultant img to create a nice animation
    @IBOutlet weak var MainContainerView: UIView!       //IBOutlet that contains all of the other sign-up elements
    @IBOutlet weak var txtFullName: UITextField!        //IBOutlet where user enters their full name
    @IBOutlet weak var txtUsername: UITextField!        //IBOutlet where user enters their username
    @IBOutlet weak var txtEmail: UITextField!           //IBOutlet where user enters their email
    @IBOutlet weak var txtPassword: UITextField!        //IBOutlet where user sets a password
    @IBOutlet weak var btnRegister: RoundedButton!      //IBOutlet for the final register button
    @IBOutlet weak var btnAlreadyAUser: UIButton!       //IBOutlet in case user already has an existing account
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAnimation()
    }
    
    
    
    
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
    }
    
    
    
    // Used to fade out all of the components if the user needs to segue out
    // Params: NONE
    // Return: NONE
    func fadeOutComponents() {
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
    
    
    
    
    
    
    
    
    
    //IBActions
    @IBAction func btnRegisterClicked(_ sender: Any) {
        
    }
    
    
    @IBAction func btnAlreadyUserClicked(_ sender: Any) {
        fadeOutComponents()
    }
}

