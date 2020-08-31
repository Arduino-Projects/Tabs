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

class TabsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tbvTabs: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvTabs.register(UINib(nibName: "TabsCell", bundle: nil), forCellReuseIdentifier: "TabsCell")
        tbvTabs.delegate = self
        tbvTabs.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TabsCell", for: indexPath) as! TabsCell
        
        cell.lblName.text! = "Abed Nadir"
        cell.lblWhoOwes.text! = "you owe"
        cell.lblAmount.text! = "$69420"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

