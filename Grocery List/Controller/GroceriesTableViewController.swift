//
//  GroceriesTableViewController.swift
//  Grocery List
//
//  Created by Basma Alqethami on 08/04/1443 AH.
//

import UIKit
import FirebaseAuth

class GroceriesTableViewController: UITableViewController {
    
    // MARK: - variables
    var list = [Grocery]()
    @IBOutlet weak var userBarButton: UIBarButtonItem!
    var userlist = [User]() // list of user

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllUsers() // function to retrieve online user from realtime database
        retrieveData() // function to retrieve grocery items from realtime database
    }
    
    override func viewDidAppear(_ animated: Bool) {
        validateAuth()
        tableView.reloadData()
    }
    
    // MARK: - Functions call by viewDidAppear and viewDidLoad
    
    // function to check if the user log in or not
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if Auth.auth().currentUser == nil {
            // present login view controller
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    // function to retrieve from realtime database
    func retrieveData () {
        // retrieve all Grocery items from realtime database thet seved before
        DatabaseManager.shared.RetrieveGroseries { result in
            switch result{
            case.success(let Groceries):
                DispatchQueue.main.async {
                    self.list = Groceries // set result to list
                    self.tableView.reloadData() // reload table to display items
                }
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // retrieve online user
    func getAllUsers () {
        DatabaseManager.shared.getAllUsers { result in
            switch result{
            case.success(let users):
                DispatchQueue.main.async {
                    self.userlist = users // set result to list
                    self.userBarButton.title = "\(self.userlist.count)" // set the number of online user to bar buttom
                }
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Button action
    
    // add new Item to grocery list
    @IBAction func AddNewItemToList(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Grocery Item",
                                      message: "Add the foods you want to buy",
                                      preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        // save items from text alart to database
        let saveAction = UIAlertAction(title: "Save", style: .default)
        { _ in
            let textField = alert.textFields![0]
            textField.placeholder = "Food name."
            // Find the logged in user who added this item
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            // add to datebase and create new grocery item
            DatabaseManager.shared.NewGrocery(with: textField.text!, email: email) { success in
                if success{
                    print("saved")
                }else{
                    print("not saved")
                }
            }
        }
        // cancel add the item
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        // show the alart
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    // number Of Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryCell",for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row].name // Add item name to table
        cell.detailTextLabel?.text = list[indexPath.row].addedByUser // Add who created this item
        
        return cell
    }
    
    // edit item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edie Item",
                                      message: "",
                                      preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        let textField = alert.textFields![0]
        textField.placeholder = "Food name."
        
        let item = list[indexPath.row]
        textField.text = item.name // make text alert equal item name that will edit
        let prevItem = item.name // Save the value before editing to delete it later
        
        let saveAction = UIAlertAction(title: "Save", style: .default)
        { _ in
            
            // Find the logged in user who update this item
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            // save the new value to database
            DatabaseManager.shared.UpdateGroseries(with: textField.text!, prev: prevItem, email: email){ success in
                if success{
                    print("updated")
                }else{
                    print("not updated")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // delete item from database and table
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        DatabaseManager.shared.deleteGroseries(with: list[indexPath.row].name) { success in
            if success{
                print("deleted")
            }else{
                print("not deleted")
            }
        }
        list.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
}
