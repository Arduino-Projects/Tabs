//
//  SignInController.swift
//
//  Description: The sign ip screen where users sign ip with their username/email and password
//  Creator: Araad Shams
//  Since: v1.0
//

import UIKit

class SignInController: UIViewController {
    
    
    //IBOutlets
    @IBOutlet weak var imgToBeMoved: UIImageView!           //IBOutlet for holding the img from last VC that needs shift
    @IBOutlet weak var imgPlaceholder: UIImageView!         //IBOutlet for holding the resultant img to create a nice animation
    @IBOutlet weak var txtUsernameOrEmail: UITextField!     //IBOutlet where user enters their email or username
    @IBOutlet weak var txtPassword: UITextField!            //IBOutlet where user sets a password
    @IBOutlet weak var btnLoginButton: RoundedButton!       //IBOutlet for the final login button
    @IBOutlet weak var btnNotAUser: UIButton!               //IBOutlet in case user does not already have an existing account
    @IBOutlet weak var btnForgottenPassword: UIButton!      //IBOutlet in case user forgets password
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAnimation()
    }
    
    
    
    
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
        })
    }
    
    
    
    
    
    
    // Used to easily set all the main component alphas
    // Params: alpha - The alpha float value to set all the componenets alphas to
    // Return: NONE
    func setAllComponentAlphas(alpha : CGFloat) {
        self.txtUsernameOrEmail.alpha = alpha
        self.txtPassword.alpha = alpha
        self.btnLoginButton.alpha = alpha
        self.btnNotAUser.alpha = alpha
        self.btnForgottenPassword.alpha = alpha
    }
    
    
    
    
    
    
    
    // Used to fade out all of the components if the user needs to segue out
    // Params: NONE
    // Return: NONE
    func fadeOutComponents() {
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.setAllComponentAlphas(alpha : 0)
        }, completion: { (notUsed) in
            self.performSegue(withIdentifier: "signinToSignup", sender: Any.self)
        })
    }
    
    
    
    
    
    
    
    
    
    //IBActions
    
    @IBAction func btnLoginPressed(_ sender: Any) {
        
    }
    
    
    
    @IBAction func btnNotAUserPressed(_ sender: Any) {
        fadeOutComponents()
    }
    
    
    
    @IBAction func btnForgotPasswordPressed(_ sender: Any) {
        
    }
}

