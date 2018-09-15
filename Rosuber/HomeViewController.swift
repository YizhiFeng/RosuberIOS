//
//  HomeViewController.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/17.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase
import Rosefire
import MaterialComponents.MaterialSnackbar

class HomeViewController: MenuViewController {
    let ROSEFIRE_REGISTRY_TOKEN = "4cecdaba-e05f-435d-bbfe-8b111f2447f4"
    
    let homeToProfileSegueIdentifier = "homeToProfileSegue"
    let homeToMySegueIdentifier = "homeToMySegue"
    let homeToFindSegueIdentifier = "homeToFindSegue"
    let homeToAboutSegueIdentifier = "homeToAboutSegue"
    
    @IBOutlet weak var loginLogoutButton: UIBarButtonItem!
    @IBOutlet weak var spinnerStackView: UIStackView!
    @IBOutlet weak var spinnerLabel: UILabel!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var myTripsButton: UIButton!
    @IBOutlet weak var findTripsButton: UIButton!
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var helloDetailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tipsTitleLabel: UILabel!
    @IBOutlet weak var tipsContentLabel: UILabel!
    @IBOutlet weak var moreTipsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerStackView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewBasedOnAuth(Auth.auth().currentUser != nil)
    }
    
    func updateViewBasedOnAuth(_ signedIn: Bool) {
        loginLogoutButton.image = signedIn ? #imageLiteral(resourceName: "logout") : #imageLiteral(resourceName: "login")
        loginLogoutButton.tintColor = signedIn ? UIColor.red : UIColor.black
        profileButton.isEnabled = signedIn
        myTripsButton.isEnabled = signedIn
        findTripsButton.isEnabled = signedIn
        
        updateGreetingLabels(signedIn)
    }
    
    func updateGreetingLabels(_ signedIn: Bool) {
        if signedIn {
            if let currentUser = Auth.auth().currentUser {
                let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
                userRef.getDocument { (documentSnapshot, error) in
                    if let error = error {
                        print("Error fetching user document.  \(error.localizedDescription)")
                        return
                    }
                    if let document = documentSnapshot {
                        if document.exists {
                            let user = User(documentSnapshot: document)
                            let formatter = DateFormatter()
                            
                            formatter.dateFormat = "EEEE"
                            self.helloLabel.text = "Hi, \(user.name.split(separator: " ")[0])! Happy \(formatter.string(from: Date()))!"
                            
                            self.helloDetailLabel.text = "Thank you for using Rosuber"
                            formatter.dateFormat = "MMM dd, yyyy"
                            let date = formatter.string(from: user.created)
                            self.dateLabel.text = "since \(date)!"
                        }
                    }
                }
            }
            showTips()
        } else {
            helloLabel.text = "Dear Rose Family,"
            helloDetailLabel.text = "Please login to explore Rosuber!"
            dateLabel.text = ""
            hideTips()
        }
    }
    
    func hideTips() {
        tipsTitleLabel.text = ""
        tipsContentLabel.text = ""
        moreTipsButton.isHidden = true
    }
    
    func showTips() {
        tipsTitleLabel.text = "Tips❕"
        tipsContentLabel.text = TipsUtils.getRandomTips()
        moreTipsButton.isHidden = false
    }
    
    @IBAction func pressedMoreTips(_ sender: Any) {
        showTips()
    }
    
    @IBAction func pressedLoginLogout(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            loginViaRosefire()
            blackView.alpha = 1
            spinnerStackView.isHidden = false
            spinnerLabel.text = "Signing in Rosefire..."
        } else {
            let ac = UIAlertController(title: "Are you sure you want to logout?", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            ac.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
                self.appDelegate.handleLogout()
            }))
            present(ac, animated: true)
        }
    }
    
    func loginViaRosefire() {
        Rosefire.sharedDelegate().uiDelegate = self
        Rosefire.sharedDelegate().signIn(registryToken: ROSEFIRE_REGISTRY_TOKEN) {
            (error, result) in
            if let error = error {
                print("Error communicating with Rosefire! \(error.localizedDescription)")
                self.blackView.alpha = 0
                self.spinnerStackView.isHidden = true
                self.spinnerLabel.text = ""
                return
            }
            print("You are now signed in with Rosefire! username: \(result!.username)")
            Auth.auth().signIn(withCustomToken: result!.token, completion: { (user, error) in
                if let error = error {
                    print("Error during log in: \(error.localizedDescription)")
                    let ac = UIAlertController(title: "Login failed", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true)
                } else {
                    self.appDelegate.handleLogin(result: result!)
                }
            })
        }
    }
}

extension UIApplicationDelegate {
    func showSignedOutSnackbar() {
        let message = MDCSnackbarMessage()
        message.text = "You've signed out!"
        MDCSnackbarManager.show(message)
    }
}

