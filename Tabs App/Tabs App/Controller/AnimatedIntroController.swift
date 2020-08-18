//
//  AnimatedIntroController.swift
//
//  Description: Used for creating the rolling icon and then fading logo on the startup screen
//  Creator: Araad Shams
//  Since: v1.0
//


import UIKit

class AnimatedIntroController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var LogoImage: UIImageView!  // IBOutlet for the fixed logo
    @IBOutlet weak var IconImage: UIImageView!  // IBOutlet for the rolling icon
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAnimation()
    }
    
    
    
    
    
    // Used to create the animation sequence of the rolling icon, then fading in logo, and perform some calculations on exact positions of components
    // Params: NONE
    // Return: NONE
    func runAnimation() {
        //Resizing and repositioning the frame for the rolling icon image, just outside of the view, and in vertical center
        IconImage.frame = CGRect(x: -LogoImage.frame.height, y: LogoImage.frame.origin.y, width: LogoImage.frame.height, height: LogoImage.frame.height)
        
        //Calculating the rotation amount to rotate the icon, to create the rolling effect, and then rotating the icon
        let rotationAmount : CGFloat = (((LogoImage.frame.origin.x - IconImage.frame.origin.x)/(IconImage.frame.width*3.141592))*360)
        IconImage.transform = CGAffineTransform(rotationAngle: (rotationAmount * .pi) / 180.0)
        
        //Making the icon visible
        IconImage.isHidden = false
        
        //Run the Animation sequence
        introAnimationSequence()
    }
    
    
    
    
    
    // Used to create the animation sequence of the rolling icon
    // Params: NONE
    // Return: NONE
    func introAnimationSequence() {
        UIView.animate(withDuration: 1, delay: 0.5, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            //Bringing the rolling icon on top of the hidden logo, with offset of -1.5 because it wasn't aligning properly
            self.IconImage.frame.origin.x = self.LogoImage.frame.origin.x - 1.5
            
            //Rotating the icon back to 0 degrees
            self.IconImage.transform = CGAffineTransform(rotationAngle: (0 * .pi) / 180.0)
            
        }, completion: { (notUsed) in
            
            //notUsed is the boolean needed to be declared but not needed for use
            //Once completed moving icon into position and rotating it, fade in the logo
            self.fadeInLogoAnimationSequence()
            
        })
    }
    
    
    
    
    
    
    
    // Used to make the fading in logo animation once icon has rolled into place
    // Params: NONE
    // Return: NONE
    func fadeInLogoAnimationSequence() {
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            //Set logo image alpha to 1 to create fading in effect
            self.LogoImage.alpha = 1.0
            
        }, completion: { (EX) in
            
            //Once completed, erase the rolling icon image
            self.IconImage.alpha = 0
            self.performSegue(withIdentifier: "introToSignup", sender: self)
            
        })
    }
}

