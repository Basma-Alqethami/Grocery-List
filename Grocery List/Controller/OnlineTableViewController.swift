//
//  OnlineTableViewController.swift
//  Grocery List
//
//  Created by Basma Alqethami on 08/04/1443 AH.
//

import UIKit
import FirebaseAuth


class OnlineTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func SignOutButton(_ sender: UIBarButtonItem) {
//        print("logout")
//        do {
//                print("logout")
//                try Auth.auth().signOut()
//                self.navigationController?.popViewController(animated: true)
//            }
//            catch {
//                print("failed to logout")
//            }
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}
