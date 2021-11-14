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
        // add the new user to "online"
        database.child("online").child(id).setValue([ "email" : email]){
                error, reference in
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    // Delete user from database
    public func deleteUser (with id: String, completion: @escaping (Bool) -> Void) {

        database.child("online").child(id).removeValue {
            error, reference in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // Read all user
    public func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void){
        
        database.child("online").observe(.value ) { snapshot in
            
            guard let value = snapshot.children.allObjects as? [DataSnapshot] else { //contains all child nodes of online
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            var AllUsers = [User]()
            
            for grocerySnap in value { //iterate over each item
                guard let userEmail = grocerySnap.childSnapshot(forPath: "email").value as? String else {
                          return
                      }
                // Add to AllUsers, for send back to retrieveusers in OnlineTableViewController
                AllUsers.append(User(email: userEmail))
            }
            // sent successfully
            completion(.success(AllUsers))
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}


// MARK: - Grocery list CRUD
extension DatabaseManager {
    
    // Read
    public func RetrieveGroseries (completion: @escaping (Result<[Grocery], Error>) -> Void) {
        
        database.child("grocery-items").observe(.value ) { snapshot in
            
            guard let value = snapshot.children.allObjects as? [DataSnapshot] else { //contains all child nodes of grocery-items
                completion(.failure(DatabaseError.failedToFetch))
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
