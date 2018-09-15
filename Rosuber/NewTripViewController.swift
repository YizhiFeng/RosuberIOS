//
//  NewTripViewController.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/26.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

class NewTripViewController: UIViewController, UITextFieldDelegate {
    let createToFindSegueIdentifier = "createToFindSegue"
    
    var tripRef: DocumentReference!
    var activeField: UITextField?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var driverSwitch: UISwitch!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var capacityField: UILabel!
    @IBOutlet weak var capacitySlider: UISlider!
    @IBOutlet weak var priceField: UITextField!
    
    var textFields: [UITextField]!

    override func viewDidLoad() {
        super.viewDidLoad()
        capacitySlider.value = 1
        datePicker.minimumDate = Date()
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        fromField.delegate = self
        toField.delegate = self
        priceField.delegate = self
        priceField.addDoneButtonToKeyboard(myAction:  #selector(self.priceField.resignFirstResponder))
        updateView()
        textFields = [fromField, toField, priceField]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    @IBAction func pressedDone(_ sender: Any) {
        for tf in textFields {
            unhighligh(textField: tf)
        }
        var isValid = true
        for tf in textFields {
            if tf.text!.isEmpty {
                isValid = false
                highlight(textField: tf)
            }
        }
        
        if isValid {
            let alertController = UIAlertController(title: "Please Confirm Your New Trip", message: getConfirmMessage(), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
                self.addNewTrip()
            }))
            present(alertController, animated: true)
        } else {
            let errorAlert = UIAlertController(title: "Required Field(s) Empty", message: "", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(errorAlert, animated: true)
        }
    }
    
    @IBAction func changedSlider(_ sender: Any) {
        let fixed = roundf(capacitySlider.value / 1.0) * 1.0;
        capacitySlider.setValue(fixed, animated: true)
        updateView()
    }
    
    func getConfirmMessage() -> String {
        var msg = ""
        
        if driverSwitch.isOn {
            msg += "I would like to "
        } else {
            msg += "I am looking for a driver who can "
        }
        
        msg += "offer \(Int(capacitySlider.value)) "
        if Int(capacitySlider.value) == 1 {
            msg += "passenger "
        } else {
            msg += "passengers "
        }
        
        msg += "a ride from \(fromField.text!) to \(toField.text!) "
        msg += "for $\((Float(priceField.text!)! * 100).rounded() / 100) (per passenger) "
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        msg += "on \(formatter.string(from: datePicker.date)) "
        formatter.dateFormat = "HH:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        msg += "at \(formatter.string(from: datePicker.date))."
        
        return msg
    }
    
    func addNewTrip() {
        let newTrip = Trip(isDriver: driverSwitch.isOn,
                       capacity: Int(self.capacitySlider.value),
                       destination: toField.text!,
                       origin: fromField.text!,
                       price: (Float(priceField.text!)! * 100).rounded() / 100,
                       time: datePicker.date)
        tripRef = Firestore.firestore().collection("trips").addDocument(data: newTrip.data) { (error) in
            if let error = error {
                print("Error when add document to firestore. Error: \(error.localizedDescription)")
                return
            }
            newTrip.id = self.tripRef.documentID
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTripDetailViewController = storyBoard.instantiateViewController(withIdentifier: "myTripDetailViewController") as! MyTripDetailViewController
            myTripDetailViewController.trip = newTrip
            self.present(myTripDetailViewController, animated: true)
        }
    }
    
    func highlight(textField: UITextField) {
        textField.layer.borderWidth = 3.0
        textField.layer.borderColor = UIColor.red.cgColor
    }
    
    func unhighligh(textField: UITextField) {
        textField.layer.borderWidth = 0.0
        textField.layer.borderColor = UIColor.black.cgColor
    }
    
    func updateView() {
        if Int(capacitySlider.value) == 1 {
            capacityField.text = "1 passenger"
        } else {
            capacityField.text = "\(Int(capacitySlider.value)) passengers"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// Credit: https://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field
extension NewTripViewController {
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        keyboardSize?.height += 30
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        self.activeField = nil
    }
}

// Credit: https://stackoverflow.com/questions/38133853/how-to-add-a-return-key-on-a-decimal-pad-in-swift
extension UITextField {
    func addDoneButtonToKeyboard(myAction:Selector?){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: myAction)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}
