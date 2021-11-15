//
//  OnlineTableViewController.swift
//  Grocery List
//
//  Created by Basma Alqethami on 08/04/1443 AH.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit


class OnlineTableViewController: UITableViewController {
    
    // MARK: - variables
    var userlist = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllUsers() // function to retrieve data from realtime database
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Functions call by viewDidLoad

    // retrieve online user
    func getAllUsers () {
        DatabaseManager.shared.getAllUsers { result in
            switch result{
            case.success(let users):
                DispatchQueue.main.async {
                    self.userlist = users // set users to list
                    self.tableView.reloadData() // reload table to display users
                }
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Button action
    
    @IBAction func SignOutButton(_ sender: UIBarButtonItem) {
        
        // Log Out facebook
        FBSDKLoginKit.LoginManager().logOut()

        // Google Log out
        GIDSignIn.sharedInstance.signOut()

        do{
            // remove user from realtime database
            DatabaseManager.shared.deleteUser(with: Auth.auth().currentUser!.uid)  { success in
                if success{
                    print("deleted")
                }else{
                    print("not deleted")
                }
            }
            // log out the user
            try Auth.auth().signOut()
            
            // present login view controller
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            
            self.navigationController?.popViewController(animated: true) // before present login, pop the OnlineTableViewController.
            // If I don't do this step, when the user logs in, they will see this view instead of the GroceriesTableViewController
            
            present(nav, animated: true, completion: nil) // then present login view
            
        }catch{
            print("Could not log out")
        }
    }
    
    
    // MARK: - Table view data source
    
    // number Of Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlist.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell",for: indexPath)
        
        cell.textLabel?.text = userlist[indexPath.row].email // Add email to table
        
        return cell
    }
}
