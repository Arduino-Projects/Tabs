//
//  FriendsController.swift
//  Tabs App
//
//  Created by Wania Shams on 26/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit

class FriendsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tbvFriends: UITableView!
    
    
    let arrayOfFriends = ["Abed Nadir", "Arthur Coolkid", "Cool Kid", "John White", "White John", "Mark Succerberg"]
    var differentStartingLetters : [String] = []
    var amountOfSpecificStartingLetterTracker : [Int] = []
    
    override func viewDidLoad() {
        calculateDifferentFirstLetters()
        tbvFriends.delegate = self
        tbvFriends.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amountOfSpecificStartingLetterTracker[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        
        var sumSections = 0;
        for i in stride(from: 0, to: indexPath.section, by: 1) {
            sumSections += tableView.numberOfRows(inSection: i);
        }
        
        cell.textLabel?.text = arrayOfFriends[indexPath.row + sumSections]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return differentStartingLetters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return differentStartingLetters[section]
    }
    
    
    func calculateDifferentFirstLetters() {
        var curIndex = -1
        for friend in arrayOfFriends {
            if(!find(value: friend[0 ..< 1], in: differentStartingLetters)) {
                differentStartingLetters.append(friend[0 ..< 1])
                curIndex += 1
                amountOfSpecificStartingLetterTracker.append(1)
            }
            else {
                amountOfSpecificStartingLetterTracker[curIndex] += 1
            }
        }
    }
    
    
    
    func find(value searchValue: String, in array: [String]) -> Bool
    {
        for val in array {
            if val == searchValue {
                return true
            }
        }
        return false
    }
    
}
