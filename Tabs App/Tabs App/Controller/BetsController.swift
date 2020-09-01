//
//  TabsController.swift
//  Tabs App
//
//  Created by Wania Shams on 31/08/2020.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class BetsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    //MARK: IBOutlets
    
    @IBOutlet weak var sgvOngoingOrFinished: UISegmentedControl!
    @IBOutlet weak var lblBets: UILabel!
    
    @IBOutlet weak var btnAddBet: UIButton!
    
    @IBOutlet weak var tbvBets: UITableView!
    @IBOutlet weak var sbrSearchThroughBets: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvBets.register(UINib(nibName: "BetsCell", bundle: nil), forCellReuseIdentifier: "BetsCell")
        tbvBets.delegate = self
        tbvBets.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BetsCell", for: indexPath) as! BetsCell
        
        cell.lblBetDate.text! = "2 days ago"
        cell.lblBetName.text! = "Steal Beans"
        cell.lblBetWith.text! = "Abed White"
        cell.lblBetAmount.text! = "$640"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

