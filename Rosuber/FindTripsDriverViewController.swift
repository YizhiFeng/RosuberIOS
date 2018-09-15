//
//  FindTripsDriverViewController.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/5/2.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

class FindTripsDriverViewController: MenuViewController, UITableViewDataSource, UITableViewDelegate {
    let driverToHomeSegueIdentifier = "driverToHomeSegue"
    let driverToCreateSegueIdentifier = "driverToCreateSegue"
    let driverToFindDetailSegueIdentifier = "driverToFindDetailSegue"
    
    let findTripDriverCellIdentifier = "findTripDriverCell"
    let findNoTripDriverCellIdentifier = "findNoTripDriverCell"
    
    let cellHeaderHeight: CGFloat = 10
    
    var tripsRef: CollectionReference!
    var tripsQuery: Query!
    var tripsListener: ListenerRegistration!
    var trips = [Trip]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tripsRef = Firestore.firestore().collection("trips")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tripsQuery = tripsRef.whereField("time", isGreaterThanOrEqualTo: Date()).whereField("driverKey", isEqualTo: "")
        self.trips.removeAll()
        tripsListener = tripsQuery.order(by: "time", descending: false).limit(to: 50).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching trips. error: \(error!.localizedDescription)")
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
                    return t1.time < t2.time
                })
                self.tableView.reloadData()
            })
        })
    }
    
    func tripAdded(_ document: DocumentSnapshot) {
        let newTrip = Trip(documentSnapshot: document)
        trips.append(newTrip)
    }
    
    func tripUpdated(_ document: DocumentSnapshot) {
        let modifiedTrip = Trip(documentSnapshot: document)
        for trip in trips {
            if (trip.id == modifiedTrip.id) {
                for i in 0..<trips.count {
                    if trip.id == trips[i].id {
                        trips.remove(at: i)
                        return
                    }
                }
                trip.capacity = modifiedTrip.capacity
                trip.destination = modifiedTrip.destination
                trip.driverKey = modifiedTrip.driverKey
                trip.passengerKeys = modifiedTrip.passengerKeys
                trip.origin = modifiedTrip.origin
                trip.price = modifiedTrip.price
                trip.time = modifiedTrip.time
                break
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
        if trips.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: findNoTripDriverCellIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: findTripDriverCellIdentifier, for: indexPath)
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
        if segue.identifier == driverToFindDetailSegueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! FindTripDetailViewController).trip = trips[indexPath.section]
            }
        }
    }

}
