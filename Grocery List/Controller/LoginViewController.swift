//
//  LoginViewController.swift
//  Grocery List
//
//  Created by Basma Alqethami on 08/04/1443 AH.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - variables
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - log in action
    
    @IBAction func loginAction(_ sender: UIButton) {
        //Check if the fields are not empty
        guard let Email = emailTextField.text, let Password = passwordTextField.text, !Email.isEmpty, !Password.isEmpty else {
            ErrorLabel.text = "please fill all fields"
            return
        }
        // Check if the password more than 6 digits
        guard Password.count >= 6 else {
            ErrorLabel.text = "The password must be 6 digits or more"
            return
        }
        
        // Firebase Login with email and password
        FirebaseAuth.Auth.auth().signIn(withEmail: Email, password: Password, completion: { [weak self] authResult, error in
            
            guard let strongSelf = self else { return }
            
            // Check if the email is registered or not
            guard error == nil else {
                strongSelf.ErrorLabel.text = "This email is not registered"
                print(error!.localizedDescription)
                return
            }
            
            //Add the email to the realtime database for (online user)
            DatabaseManager.shared.onlineUser(with: Email, id: Auth.auth().currentUser!.uid, completion: { success in
                if success{
                    print("email add")
                }else{
                    print("email not add")
                }
            })
            
            //Transfer to GroceriesTableViewController
            UserDefaults.standard.set(Email, forKey: "email")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    
    
    
    // MARK: - sign up action
    
    @IBAction func signupAction(_ sender: UIButton) {
        //Check if the fields are not empty
        guard let Email = emailTextField.text, let Password = passwordTextField.text, !Email.isEmpty, !Password.isEmpty else {
            ErrorLabel.text = "please fill all fields"
            return
        }
        // Check if the password more than 6 digits
        guard Password.count >= 6 else {
            ErrorLabel.text = "The password must be 6 digits or more"
            return
        }
        
        // Firebase sign up new user with email and password
        FirebaseAuth.Auth.auth().createUser(withEmail: Email, password: Password, completion: {[weak self] authResult , error  in
            
            guard let strongSelf = self else { return }
            
            guard authResult != nil, error == nil else {
                strongSelf.ErrorLabel.text = error!.localizedDescription
                return
            }
            
            //Add the email to the realtime database for (online user)
            DatabaseManager.shared.onlineUser(with: Email, id: Auth.auth().currentUser!.uid, completion: { success in
                if success{
                    print("email add")
                }else{
                    print("email not add")
                }
            })
            
            //Transfer to GroceriesTableViewController
            UserDefaults.standard.setValue(Email, forKey: "email")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
}




