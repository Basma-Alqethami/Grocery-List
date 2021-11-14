//
//  LoginViewController.swift
//  Grocery List
//
//  Created by Basma Alqethami on 08/04/1443 AH.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    
    // MARK: - variables
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - log in action

    // Google login
    @IBAction func googlePressButton(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let signInConfig = appDelegate.signInConfig else {
            return
        }
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard let user = user, error == nil else { return }
            appDelegate.handleSessionRestore(user: user)
        }
    }
    
    // facebook login
    @IBAction func facebookLoginButton(_ sender: UIButton) {
        FBSDKLoginKit.LoginManager().logIn(permissions: ["email", "public_profile"], from: self){ (result, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let token = result?.token?.tokenString else {
                        print("User failed to log in with facebook")
                        return
                    }

                    let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                                     parameters: ["fields":
                                                                        "email"],
                                                                     tokenString: token,
                                                                     version: nil,
                                                                     httpMethod: .get)

                    facebookRequest.start(completionHandler: { _, result, error in
                        guard let result = result as? [String: Any],
                            error == nil else {
                                print("Failed to make facebook graph request")
                                return
                        }

                        print(result)

                        guard let email = result["email"] as? String else {
                                print("Faield to get email and name from fb result")
                                return
                        }

                        UserDefaults.standard.set(email, forKey: "email")

                        let credential = FacebookAuthProvider.credential(withAccessToken: token)
                        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                            guard let strongSelf = self else {
                                return
                            }

                            guard authResult != nil, error == nil else {
                                if let error = error {
                                    print("Facebook credential login failed, MFA may be needed - \(error)")
                                }
                                return
                            }
                            
                            DatabaseManager.shared.onlineUser(with: email, id: Auth.auth().currentUser!.uid , completion: { success in
                                if success{
                                    print("email add")
                                }else{
                                    print("email not add")
                                }
                            })

                            print("Successfully logged user in")
                            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                        })
                    })
                }
        }
        
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




