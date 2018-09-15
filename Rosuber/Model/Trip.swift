//
//  Trip.swift
//  Rosuber
//
//  Created by Ryan Greenlee on 4/20/18.
//  Copyright © 2018 FengYizhi. All rights reserved.
//
import UIKit
import Firebase

class Trip: NSObject {
    var id: String?
    var capacity: Int
    var destination: String
    var driverKey: String
    var passengerKeys: [String: Any]
    var origin: String
    var price: Float
    var time: Date
    var created: Date
    
    let capacityKey = "capacity"
    let destinationKey = "destination"
    let driverKeyKey = "driverKey"
    let passengerKeysKey = "passengerKeys"
    let originKey = "origin"
    let priceKey = "price"
    let timeKey = "time"
    let createdKey = "created"
    
    init(isDriver: Bool, capacity: Int, destination: String, origin: String, price: Float, time: Date) {
        let currentUser = Auth.auth().currentUser
        if isDriver {
            driverKey = (currentUser?.uid)!
            passengerKeys = [timeKey: time]
        } else {
            driverKey = ""
            passengerKeys = [timeKey: time,
                             (currentUser?.uid)!: true]
        }
        self.capacity = capacity
        self.destination = destination
        self.origin = origin
        self.price = price
        self.time = time
        created = Date()
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        
        destination = data[destinationKey] as! String
        driverKey = data[driverKeyKey] as! String
        passengerKeys = data[passengerKeysKey] as! [String: Any]
        capacity = documentSnapshot.get(capacityKey) as? Int ?? 0
        origin = data[originKey] as! String
        price = data[priceKey] as? Float ?? 0.00
        time = data[timeKey] as! Date
        created = data[createdKey] as! Date
    }
    
    var data: [String: Any] {
        return [capacityKey: self.capacity,
                destinationKey: self.destination,
                originKey: self.origin,
                priceKey: self.price,
                timeKey: self.time,
                createdKey: self.created,
                driverKeyKey: self.driverKey,
                passengerKeysKey: self.passengerKeys]
    }
    
    var passengersString: String {
        var str = ""
        for (key, _) in passengerKeys {
            if key != "time" {
                str += "\(key),"
            }
        }
        if str.hasSuffix(",") {
            let start = str.startIndex
            let end = str.index(str.endIndex, offsetBy: -1)
            let range = start..<end
            return "\(str[range])"
        } else {
            return str
        }
    }
    
    func contains(passenger: String) -> Bool {
        return passengerKeys.keys.contains(passenger)
    }
    
    func remove(passenger: String) {
        passengerKeys.removeValue(forKey: passenger)
    }
}
