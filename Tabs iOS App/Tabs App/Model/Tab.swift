//  
//  Tab.swift
//  Tabs App
//
//  Created by Wania Shams on 28/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class Tab {
    
    var tabID : String = ""
    var totalAmount : Int = 0
    var personWhoOwes : String = ""
    var otherPersonsUID : String = ""
    
    
    init(tabID : String, totalAmount : Int, personWhoOwes : String, otherPersonsUID : String) {
        self.tabID = tabID
        self.totalAmount = totalAmount
        self.personWhoOwes = personWhoOwes
        self.otherPersonsUID = otherPersonsUID
    }
    
    init(FirebaseDoc : QueryDocumentSnapshot) {
        self.tabID = FirebaseDoc.documentID
        self.totalAmount = FirebaseDoc.data()["totalAmount"] as! Int
        self.personWhoOwes = FirebaseDoc.data()["personWhoOwes"] as! String
        self.otherPersonsUID = FirebaseDoc.data()["personWhoOwes"] as! String
    }
}
