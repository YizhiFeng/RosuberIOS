//
//  TripDetailViewController.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/5/13.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class TripDetailViewController: UIViewController {

    var trip: Trip!
    var tripRef: DocumentReference!
    var tripListener: ListenerRegistration!
    
    var driver: User?
    var passengers = [User]()
    var contacts = [User]()
    
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripRef = Firestore.firestore().collection("trips").document(trip.id!)
        parseDriver()
        parsePassengers()
        parseContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripListener = tripRef.addSnapshotListener({ (documentSnapshot, error) in
            if let error = error {
                print("Error getting the document: \(error.localizedDescription)")
                return
            }
            if !documentSnapshot!.exists {
                print("This document got deleted by someone else!")
                return
            }
            self.trip = Trip(documentSnapshot: documentSnapshot!)
            self.updateView()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tripListener.remove()
    }
    
    func parseDriver() {
        if trip.driverKey != "" {
            Firestore.firestore().collection("users").document(trip.driverKey).getDocument { (documentSnapshot, error) in
                if let error = error {
                    print("Error getting driver \(self.trip.driverKey) from Firebase in Find Trip Detail page. Error: \(error.localizedDescription)")
                    return
                }
                if let document = documentSnapshot {
                    self.driver = User(documentSnapshot: document)
                    self.driverLabel.text = self.driver?.name
                    self.parseContacts()
                }
            }
        } else {
            self.driver = nil
        }
    }
    
    func parsePassengers() {
        passengers.removeAll()
        if !trip.passengersString.isEmpty {
            let passengersArr = trip.passengersString.split(separator: ",")
            for p in passengersArr {
                Firestore.firestore().collection("users").document(String(p)).getDocument { (documentSnapshot, error) in
                    if let error = error {
                        print("Error getting passenger \(p) from Firebase in Find Trip Detail page. Error: \(error.localizedDescription)")
                        return
                    }
                    if let document = documentSnapshot {
                        self.passengers.append(User(documentSnapshot: document))
                        self.updatePassengersLabel()
                        self.parseContacts()
                    }
                }
            }
        }
    }
    
    func parseContacts() {
        contacts.removeAll()
        guard let currentUser = Auth.auth().currentUser else {
            let errorAlert = UIAlertController(title: "Error", message: "Unable to recognize user authentication! Please check network connection!", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(errorAlert, animated: true)
            return
        }
        if let driver = driver {
            if driver.id != currentUser.uid {
                contacts.append(driver)
            }
        }
        for i in 0..<passengers.count {
            if passengers[i].id != currentUser.uid {
                contacts.append(passengers[i])
            }
        }
    }
    
    func updatePassengersLabel() {
        passengerLabel.text = ""
        var str = ""
        for i in 0..<self.passengers.count {
            str += self.passengers[i].name
            if i < self.passengers.count - 1 {
                str += "\n"
            }
        }
        passengerLabel.text = str
    }
    
    func updateView() {
        originLabel.text = trip.origin
        destinationLabel.text = trip.destination
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = formatter.string(from: trip.time)
        
        formatter.dateFormat = "HH:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        timeLabel.text = formatter.string(from: trip.time)
        
        if let driver = driver {
            driverLabel.text = driver.name
        } else {
            driverLabel.text = ""
        }
        
        if !passengers.isEmpty {
            updatePassengersLabel()
        } else {
            passengerLabel.text = ""
        }
        
        priceLabel.text = String(format: "%.2f", Float(trip.price))
        capacityLabel.text = "\(trip.capacity) passenger(s) max"
    }
    
    @IBAction func pressedMenu(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser else {
            let errorAlert = UIAlertController(title: "Error", message: "Unable to recognize user authentication! Please check network connection!", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(errorAlert, animated: true)
            return
        }
        
        let actionController = UIAlertController(title: "Find Trip Options", message: nil, preferredStyle: .actionSheet)
        
        contactDriver(currentUid: currentUser.uid, actionController: actionController)
        contactPassengers(currentUid: currentUser.uid, actionController: actionController)
        contactAll(actionController: actionController)
        
        joinTrip(currentUid: currentUser.uid, actionController: actionController)
        leaveTrip(currentUid: currentUser.uid, actionController: actionController)
        
        actionController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        present(actionController, animated: true)
    }
    
    func joinTrip(currentUid: String, actionController: UIAlertController) {
        print("Will be overriden by subclass")
    }
    
    func leaveTrip(currentUid: String, actionController: UIAlertController) {
        print("Will be overriden by subclass")
    }
}

// MARK: - Contact methods

extension TripDetailViewController {
    
    func contactDriver(currentUid: String, actionController: UIAlertController) {
        if let driver = driver {
            if driver.id != currentUid {
                actionController.addAction(UIAlertAction(title: "Contact Driver", style: .default, handler: { _ in
                    let contactController = UIAlertController(title: "Contact via", message: nil, preferredStyle: .alert)
                    
                    contactController.addAction(UIAlertAction(title: "SMS", style: .default, handler: { _ in
                        if driver.phoneNumber == "" {
                            let errorAlert = UIAlertController(title: "Not Available", message: "Driver has not updated his/her phone number.", preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self.present(errorAlert, animated: true)
                        } else {
                            self.sendMessage(recipients: [driver.phoneNumber])
                        }
                    }))
                    contactController.addAction(UIAlertAction(title: "Email", style: .default, handler: { _ in
                        self.sendEmail(recipients: [driver.email])
                    }))
                    
                    contactController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                    self.present(contactController, animated: true)
                }))
            }
        }
    }
    
    func contactPassengers(currentUid: String, actionController: UIAlertController) {
        if !passengers.isEmpty && !(passengers.count == 1 && passengers[0].id == currentUid) {
            var recipientsSMSs = [String]()
            var recipientsEmails = [String]()
            for i in 0..<passengers.count {
                if passengers[i].id != currentUid {
                    if passengers[i].phoneNumber != "" {
                        recipientsSMSs.append(passengers[i].phoneNumber)
                    }
                    recipientsEmails.append(passengers[i].email)
                }
            }
            
            actionController.addAction(UIAlertAction(title: "Contact Passenger(s)", style: .default, handler: { _ in
                let contactController = UIAlertController(title: "Contact via", message: nil, preferredStyle: .alert)
                
                contactController.addAction(UIAlertAction(title: "SMS", style: .default, handler: { _ in
                    if recipientsSMSs.isEmpty {
                        let errorAlert = UIAlertController(title: "Not Available", message: "Passengers have not updated their phone number.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(errorAlert, animated: true)
                    } else {
                        self.sendMessage(recipients: recipientsSMSs)
                    }
                }))
                contactController.addAction(UIAlertAction(title: "Email", style: .default, handler: { _ in
                    self.sendEmail(recipients: recipientsEmails)
                }))
                
                contactController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self.present(contactController, animated: true)
            }))
        }
    }
    
    func contactAll(actionController: UIAlertController) {
        if contacts.count > 1 {
            var recipientsSMSs = [String]()
            var recipientsEmails = [String]()
            for i in 0..<contacts.count {
                if contacts[i].phoneNumber != "" {
                    recipientsSMSs.append(contacts[i].phoneNumber)
                }
                recipientsEmails.append(contacts[i].email)
            }
            
            actionController.addAction(UIAlertAction(title: "Contact All", style: .default, handler: { _ in
                let contactController = UIAlertController(title: "Contact via", message: nil, preferredStyle: .alert)
                
                contactController.addAction(UIAlertAction(title: "SMS", style: .default, handler: { _ in
                    if recipientsSMSs.isEmpty {
                        let errorAlert = UIAlertController(title: "Not Available", message: "They have not updated their phone number.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(errorAlert, animated: true)
                    } else {
                        self.sendMessage(recipients: recipientsSMSs)
                    }
                }))
                contactController.addAction(UIAlertAction(title: "Email", style: .default, handler: { _ in
                    self.sendEmail(recipients: recipientsEmails)
                }))
                
                contactController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self.present(contactController, animated: true)
            }))
        }
    }
    
}

// MARK: - MFMessage and MFMail methods

extension TripDetailViewController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    func sendMessage(recipients: [String]) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            controller.recipients = recipients
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            var body = "Hello!"
            body += "Regarding to our trip to \(trip.destination) from \(trip.origin) on \(formatter.string(from: trip.time)), "
            controller.body = body
            
            controller.messageComposeDelegate = self
            present(controller, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertController(title: "Error", message: "No Message Service available!", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(errorAlert, animated: true)
        }
    }
    
    func sendEmail(recipients: [String]) {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setToRecipients(recipients)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            controller.setSubject("Rosuber: Trip on \(formatter.string(from: trip.time)) ")
            
            var body = "Hello!\n\n   "
            body += "Regarding to our trip to \(trip.destination) from \(trip.origin), "
            controller.setMessageBody(body, isHTML: false)
            
            present(controller, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertController(title: "Error", message: "No Mail Service available!", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(errorAlert, animated: true)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
