//
//  ViewController.swift
//  Laundry
//
//  Created by Sandy Goss on 8/25/17.
//  Copyright © 2017 Sandy Goss. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import FirebaseDatabase

class ViewController: UIViewController, STPPaymentContextDelegate {
    var number: Int = 0

    @IBOutlet weak var Count: UITextField!
    
    @IBAction func Increment(_ sender: UIButton) {
        increment()
    }
    
    func printToConsole() {
        print("\(number)")
    }
    
    func increment() {
        number += 1
        Count.text! = String(number)
    }
    
    
    
    // Controllers
    private let customerContext: STPCustomerContext
    private let paymentContext: STPPaymentContext
    
    // State
    private var price = 0 {
        didSet {
            paymentContext.paymentAmount = price
        }
    }
    
    // Views
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var paymentButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        customerContext = STPCustomerContext(keyProvider: MainAPIClient.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        
        super.init(coder: aDecoder)
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    @IBAction func handlePaymentButtonTapped(_ sender: UIButton) {
        presentPaymentMethodsViewController()
    }
    
    private func presentPaymentMethodsViewController() {
        guard !STPPaymentConfiguration.shared().publishableKey.isEmpty else {
            // Present error immediately because publishable key needs to be set
            let message = "Please assign a value to `publishableKey` before continuing. See `AppDelegate.swift`."
            let alertController = UIAlertController(title: "Key", message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)
            present(alertController, animated: true)
            return
        }
        
        guard !MainAPIClient.shared.baseURLString.isEmpty else {
            // Present error immediately because base url needs to be set
            let message = "Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`."
            let alertController = UIAlertController(title: "URL", message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)
            present(alertController, animated: true)
            return
        }
        
        // Present the Stripe payment methods view controller to enter payment details
        paymentContext.presentPaymentMethodsViewController()
    }
    
    private func reloadPaymentButtonContent() {
        guard let selectedPaymentMethod = paymentContext.selectedPaymentMethod else {
            // Show default image, text, and color
            //paymentButton.setImage(#imageLiteral(resourceName: "Payment"), for: .normal)
            paymentButton.setTitle("Payment", for: .normal)
            paymentButton.setTitleColor(UIColor.gray, for: .normal)
            return
        }
        
        // Show selected payment method image, label, and darker color
        paymentButton.setImage(selectedPaymentMethod.image, for: .normal)
        paymentButton.setTitle(selectedPaymentMethod.label, for: .normal)
        paymentButton.setTitleColor(UIColor.blue, for: .normal)
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // Reload related components
        reloadPaymentButtonContent()
        //reloadRequestRideButton()
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
//This method is called when the user has successfully selected a payment method and completed their purchase. You should pass the contents of the paymentResult object to your backend, which should then finish charging your user using the create charge API. When this API request is finished, call the provided completion block with nil as its only argument if the call succeeded, or, if an error occurred, with that error as the argument instead.
        completion(nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFinishWith status: STPPaymentStatus,
                        error: Error?) {
        present(UIAlertController(title: "Default Style", message: "didFinishWith error", preferredStyle: .alert), animated: true)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(title: "Default Style", message: "didFailToLoadWithError", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    var database : DatabaseReference!
    override func viewDidLoad(){
        super.viewDidLoad()
        database =  Database.database().reference()
    }
    
    @IBAction func write(_ sender: UIButton) {
        writeToDatabase()
    }
    
    func writeToDatabase() {
        database.child("Sandy").setValue(number)
    }
}

