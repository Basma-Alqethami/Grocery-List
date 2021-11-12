//
//  DatabaseManager.swift
//  Grocery List
//
//  Created by Basma Alqethami on 08/04/1443 AH.
//

import Foundation
import FirebaseDatabase


// MARK: - setup database
class DatabaseManager{
    
    static let shared = DatabaseManager()
    let database = Database.database(url: "https://grocery-list-905bb-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
}


// MARK: - online User
extension DatabaseManager {
    
    // Insert new user to database
    public func onlineUser(with email: String, id: String, completion: @escaping (Bool) -> Void){
        
        self.database.child("online").observeSingleEvent(of: .value) { snapshot in
            if var usersCollection = snapshot.value as? [[String : String]] {
                let newElement = [id: email]
                usersCollection.append(newElement)
                
                self.database.child("online").setValue(usersCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
                
            }else{
                // create that array
                let newCollection: [[String : String]] = [[id: email]]
                self.database.child("online").setValue(newCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
}


// MARK: - Grocery list CRUD
extension DatabaseManager {
    
    // Read
    public func RetrieveGroseries (completion: @escaping (Result<[Grocery], Error>) -> Void) {
        
        database.child("grocery-items").observe(.value ) { snapshot in
            
            guard let value = snapshot.children.allObjects as? [DataSnapshot] else { //contains all child nodes of grocery-items
                return
            }
            var AllGroceries = [Grocery]()
            
            for grocerySnap in value { //iterate over each item
                guard let GroceryItem = grocerySnap.childSnapshot(forPath: "name").value as? String,
                      let addedBy = grocerySnap.childSnapshot(forPath: "addedByUser").value as? String else {
                          return
                      }
                // Add to AllGrocery for send back to retrieveData in GroceriesTableViewController
                AllGroceries.append(Grocery(addedByUser: addedBy, name: GroceryItem))
            }
            // sent successfully
            completion(.success(AllGroceries))
        }
    }
    
    // Update
    public func UpdateGroseries (with text: String, prev:String, email: String, completion: @escaping (Bool) -> Void) {
        // First delete previous value
        database.child("grocery-items").child(prev).removeValue()
        // Second, add the modified value instead of the previous one
        database.child("grocery-items").child(text).setValue([ "addedByUser" : email,
                                                               "name" : text]){
                error, reference in
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    // Delete
    public func deleteGroseries (with text: String, completion: @escaping (Bool) -> Void) {
        // Remove item (text) from grocery-items
        database.child("grocery-items").child(text).removeValue {
            error, reference in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // Create
    public func NewGrocery(with text: String, email: String, completion: @escaping (Bool) -> Void){
        // add the new item to "grocery-items"
        database.child("grocery-items").child(text).setValue([ "addedByUser" : email,
                                                                "name" : text]){
                error, reference in
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }
                completion(true)
            }
    }
}
