//
//  AppDelegate.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/17.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase
import Rosefire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var user: User?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        sleep(2)
        
        FirebaseApp.configure()
        
        if let currentUser = Auth.auth().currentUser {
            let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
            userRef.getDocument { (documentSnapshot, error) in
                if let error = error {
                    print("Error fetching user document.  \(error.localizedDescription)")
                    return
                }
                if let document = documentSnapshot {
                    if document.exists {
                        self.user = User(documentSnapshot: document)
                    }
                }
            }
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    func handleLogin(result: RosefireResult) {
        let userRef = Firestore.firestore().collection("users").document(result.username)
        userRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching user document.  \(error.localizedDescription)")
                return
            }
            if let document = documentSnapshot {
                if document.exists {
                    self.user = User(documentSnapshot: document)
                } else {
                    self.user = User(email: result.email, name: result.name, phoneNumber: "")
                    self.user!.id = result.username
                    userRef.setData(self.user!.data)
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
            }
        }
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error on sign out: \(error.localizedDescription)")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        showSignedOutSnackbar()
    }
}

extension UIViewController {
    var appDelegate : AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
}
