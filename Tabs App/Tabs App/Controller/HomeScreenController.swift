//
//  HomeScreenController.swift
//  Tabs App
//
//  Created by Madhumita Mocharla on 2020-08-28.
//  Copyright © 2020 Araad Shams. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore

class HomeScreenController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var btnDM: UIButton!
    @IBOutlet weak var lblYourBalance: UILabel!
    @IBOutlet weak var lblOverallMoney: UILabel!
    @IBOutlet weak var imgGraph: UIImageView!
    @IBOutlet weak var btnTotalOwed: UIButton!
    @IBOutlet weak var btnTotalEarned: UIButton!
    @IBOutlet weak var tbvOwedOrEarned: UITableView!
}
