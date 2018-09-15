//
//  MyTripsTableViewController.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/24.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

class MyTripsViewController: MenuViewController, UITableViewDataSource, UITableViewDelegate {
    let myDriverToMyDetailSegueIdentifier = "myDriverToMyDetailSegue"
    let myPassengerToMyDetailSegueIdentifier = "myPassengerToMyDetailSegue"
    
    let myTripDriverCellIdentifier = "myTripDriverCell"
    let myTripPassengerCellIdentifier = "myTripPassengerCell"
    let myNoTripCellIdentifier = "myNoTripCell"
    
    let cellHeaderHeight: CGFloat = 10
    
    var currentUserCollectionRef: CollectionReference!
    var tripsListener: ListenerRegistration!
    var trips = [Trip]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        guard let currentUser = Auth.auth().currentUser else { return }
//        currentUserCollectionRef = Firestore.firestore().collection(currentUser.uid)
        currentUserCollectionRef = Firestore.firestore().collection("trips")
        
        trips.removeAll()
        tripsListener = currentUserCollectionRef.order(by: "time", descending: true).addSnapshotListener({ (tripSnapshot, error) in
            guard let snapshot = tripSnapshot else {
                print("Error fetching trips. \(error!.localizedDescription)")
                return
            }
            snapshot.documentChanges.forEach({ (docChange) in
                if (docChange.type == .added) {
                    print("New trip: \(docChange.document.data())")
                    self.tripAdded(docChange.document)
                } else if (docChange.type == .modified) {
                    print("Modified trip: \(docChange.document.data())")
                    self.tripUpdated(docChange.document)
                } else if (docChange.type == .removed) {
                    print("Removed trip: \(docChange.document.data())")
                    self.tripRemoved(docChange.document)
                }
                self.trips.sort(by: { (t1, t2) -> Bool in
                    return t1.time > t2.time
                })
                self.tableView.reloadData()
            })
        })
    }
    
    func tripAdded(_ document: DocumentSnapshot) {
        let newTrip = Trip(documentSnapshot: document)
        guard let currentUser = Auth.auth().currentUser else { return }
        if newTrip.driverKey == currentUser.uid || newTrip.contains(passenger: currentUser.uid) {
            trips.append(newTrip)
        }
    }
    
    func tripUpdated(_ document: DocumentSnapshot) {
        let modifiedTrip = Trip(documentSnapshot: document)
        guard let currentUser = Auth.auth().currentUser else { return }
        for trip in trips {
            if trip.id == modifiedTrip.id {
                if modifiedTrip.driverKey != currentUser.uid &&
                    !modifiedTrip.contains(passenger: currentUser.uid) {
                    for i in 0..<trips.count {
                        if trip.id == trips[i].id {
                            trips.remove(at: i)
                            return
                        }
                    }
                }
                trip.capacity = modifiedTrip.capacity
                trip.destination = modifiedTrip.destination
                trip.driverKey = modifiedTrip.driverKey
                trip.passengerKeys = modifiedTrip.passengerKeys
                trip.origin = modifiedTrip.origin
                trip.price = modifiedTrip.price
                trip.time = modifiedTrip.time
                return
            }
        }
    }
    
    func tripRemoved(_ document: DocumentSnapshot) {
        for i in 0 ..< trips.count {
            if trips[i].id == document.documentID {
                trips.remove(at: i)
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tripsListener.remove()
    }


    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        guard let currentUser = Auth.auth().currentUser else { return tableView.dequeueReusableCell(withIdentifier: myNoTripCellIdentifier, for: indexPath) }
        if trips.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: myNoTripCellIdentifier, for: indexPath)
        } else {
            if trips[indexPath.section].driverKey == currentUser.uid {
                cell = tableView.dequeueReusableCell(withIdentifier: myTripDriverCellIdentifier, for: indexPath)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: myTripPassengerCellIdentifier, for: indexPath)
            }
            
            cell.textLabel?.text = "\(trips[indexPath.section].origin) - \(trips[indexPath.section].destination)"
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mma"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            cell.detailTextLabel?.text = formatter.string(from: trips[indexPath.section].time)
        }
        cell.layer.cornerRadius = 5
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myDriverToMyDetailSegueIdentifier || segue.identifier == myPassengerToMyDetailSegueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! MyTripDetailViewController).trip = trips[indexPath.section]
            }
        }
    }

}
