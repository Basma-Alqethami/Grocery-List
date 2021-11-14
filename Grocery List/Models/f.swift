//
//  f.swift
//  Grocery List
//
//  Created by Basma Alqethami on 09/04/1443 AH.
//

import Foundation


struct Grocery {
    let addedByUser: String
    let name: String
}

struct User{
    let email: String
}

extension Notification.Name {
    /// Notificaiton  when user logs in
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
