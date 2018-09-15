//
//  User.swift
//  Rosuber
//
//  Created by Ryan Greenlee on 4/21/18.
//  Copyright © 2018 FengYizhi. All rights reserved.
//
import UIKit
import Firebase

class User: NSObject {
    var id: String!
    var email: String
    var name: String
    var phoneNumber: String
    var created: Date!
    var imgUrl: String!
    
    let emailKey = "email"
    let nameKey = "name"
    let phoneNumberKey = "phoneNumber"
    let createdKey = "created"
    let imgUrlKey = "imgUrl"
    
    init(email: String, name: String, phoneNumber: String) {
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.created = Date()
        self.imgUrl = ""
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.name = data[nameKey] as! String
        self.email = data[emailKey] as! String
        self.phoneNumber = data[phoneNumberKey] as! String
        if data[createdKey] != nil {
            self.created = data[createdKey] as! Date
        }
        if data[imgUrlKey] != nil {
            self.imgUrl = data[imgUrlKey] as! String
        }
    }
    
    var data: [String: Any] {
        return [emailKey: self.email,
                nameKey: self.name,
                phoneNumberKey: self.phoneNumber,
                createdKey: self.created,
                imgUrlKey: self.imgUrl]
    }
}
