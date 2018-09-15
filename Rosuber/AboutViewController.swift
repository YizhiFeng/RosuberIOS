//
//  AboutViewController.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/24.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: MenuViewController, MFMailComposeViewControllerDelegate {
    let aboutToHomeSegueIdentifier = "aboutToHomeSegue"
    
    @IBOutlet weak var creditViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var creditView: UIView!
    
    @IBOutlet weak var developerOneImageView: UIImageView!
    @IBOutlet weak var developerTwoImageView: UIImageView!
    @IBOutlet weak var instructorImageView: UIImageView!
    @IBOutlet weak var launchImageView: UIImageView!
    
    var imageViews: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creditViewTopConstraint.constant = creditView.frame.height
        imageViews = [developerOneImageView, developerTwoImageView, instructorImageView, launchImageView]
        for view in imageViews {
            view.image = view.image!.withRenderingMode(.alwaysTemplate)
            view.tintColor = UIColor.white
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        creditViewTopConstraint.constant = -20
        UIView.animate(withDuration: 3.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @IBAction func pressedContactUs(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setToRecipients(["fengy2@rose-hulman.edu",
                                        "greenlrt@rose-hulman.edu"])
            
            controller.setSubject("Rosuber")
            
            let body = "Hi, Yizhi and Ryan!\n\n   "
            controller.setMessageBody(body, isHTML: false)
            
            present(controller, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertController(title: "Error", message: "No Mail Service available!", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(errorAlert, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
