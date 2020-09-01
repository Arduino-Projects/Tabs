//
//  User.swift
//
//  Description: The User model, used for holding the user structure and storing the user data
//  Creator: Araad Shams
//  Since: v1.0
//

import Foundation
import FirebaseFirestore
class User {

    //MARK: Properties
    var displayName: String     //The users full name
    var username: String    //The users chosen username
    var email: String   //The users email
    var verified: Bool  //The users email verification status
    var accountCreated: FirebaseFirestore.Timestamp //When the user created their account
    static var loggedIn = false
    static var friendsLoaded = false
    static var tabsLoaded = false
    static var betsLoaded = false
    
    
    
    
    // MARK: Initializer
    init(displayName: String, username: String, email: String, verified: Bool, accountCreated: Date) {
        self.displayName = displayName
        self.username = username
        self.email = email
        self.verified = verified
        self.accountCreated = FirebaseFirestore.Timestamp.init(date: accountCreated)
    }
    
    
    
    
    //MARK: Getters
    
    // Used to get a firebase usable format of the user
    // Params: NONE
    // Return: Dictionary containing the key/value pairs for Firestore
    func getFirebaseFormat() -> [String:Any] {
        return ["displayName": displayName, "username": username, "email": email, "verified": verified, "accountCreated": accountCreated]
    }
    
    
    
    //MARK: Setters

}
