//
//  FindTripDetailViewController.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/24.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

class FindTripDetailViewController: TripDetailViewController {
    let findDetailToFindSegueIdentifier = "findDetailToFindSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func joinTrip(currentUid: String, actionController: UIAlertController) {
        if ((trip.driverKey == "") || (trip.driverKey != currentUid && trip.capacity > trip.passengerKeys.count - 1)) && !trip.contains(passenger: currentUid) {
            actionController.addAction(UIAlertAction(title: "Join", style: .default, handler: { _ in
                let alertController = UIAlertController(title: "Are you sure you want to join this trip?", message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Join", style: .default, handler: { _ in
                    self.join(currentUid: currentUid)
                }))
                self.present(alertController, animated: true)
            }))
        } 
    }
    
    func join(currentUid: String) {
        let alertController = UIAlertController(title: "Join as a", message: "", preferredStyle: .alert)
        if (trip.driverKey == "") {
            alertController.addAction(UIAlertAction(title: "Driver", style: .destructive, handler: { _ in
                self.trip.driverKey = currentUid
                self.tripRef.setData(self.trip.data)
                self.parseDriver()
            }))
        }
        if (trip.capacity > trip.passengerKeys.count - 1) {
            alertController.addAction(UIAlertAction(title: "Passenger", style: .destructive, handler: { _ in
                self.trip.passengerKeys[currentUid] = true
                self.tripRef.setData(self.trip.data)
                self.parsePassengers()
            }))
        }
        self.present(alertController, animated: true)
    }
    
    override func leaveTrip(currentUid: String, actionController: UIAlertController) {
        if trip.driverKey == currentUid || trip.contains(passenger: currentUid) {
            actionController.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
                let alertController = UIAlertController(title: "Are you sure you want to leave this trip?", message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
                    self.leave(currentUid: currentUid)
                }))
                self.present(alertController, animated: true)
            }))
        }
    }
    
    func leave(currentUid: String) {
        if (trip.driverKey == currentUid) {
            trip.driverKey = ""
            parseDriver()
        } else {
            trip.remove(passenger: currentUid)
            parsePassengers()
        }
        if (trip.driverKey == "" && trip.passengersString == "") {
            let alertController = UIAlertController(title: "No occupants registered for this trip. This trip will be deleted.", message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {_ in
                self.tripRef.delete()
                self.performSegue(withIdentifier: self.findDetailToFindSegueIdentifier, sender: nil)
            }))
            self.present(alertController, animated: true)
            
        } else {
            tripRef.setData(trip.data)
        }
    }
}
