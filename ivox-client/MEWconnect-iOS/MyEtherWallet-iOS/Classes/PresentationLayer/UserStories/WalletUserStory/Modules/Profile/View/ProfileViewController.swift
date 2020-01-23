//
//  ProfileViewController.swift
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

import UIKit

@objc class ProfileViewController: UIViewController, ProfileViewInput, UITextViewDelegate {
    
    enum CardType: String {
        case Unknown, Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay

        static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay]

        var regex : String {
            switch self {
            case .Amex:
               return "^3[47][0-9]{5,}$"
            case .Visa:
               return "^4[0-9]{6,}([0-9]{3})?$"
            case .MasterCard:
               return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
            case .Diners:
               return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
            case .Discover:
               return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
            case .JCB:
               return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
            case .UnionPay:
               return "^(62|88)[0-9]{5,}$"
            case .Hipercard:
               return "^(606282|3841)[0-9]{5,}$"
            case .Elo:
               return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
            default:
               return ""
            }
        }
    }

    func validateCreditCardFormat(string: String)-> (type: CardType, valid: Bool) {
            // Get only numbers from the input string
            var input = string
        let numberOnly = input.replacingOccurrences(of:"[^0-9]", with: "", options: .regularExpression)

        var type: CardType = .Unknown
        var formatted = ""
        var valid = false

        // detect card type
        for card in CardType.allCards {
            if (matchesRegex(regex: card.regex, text: numberOnly)) {
                type = card
                break
            }
        }

        // check validity
        valid = luhnCheck(number: numberOnly)

        // format
        var formatted4 = ""
        for character in numberOnly.characters {
            if formatted4.characters.count == 4 {
                formatted += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }

        formatted += formatted4 // the rest

        // return the tuple
        return (type, valid)
    }

    func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }

    func luhnCheck(number: String) -> Bool {
        var sum = 0
        let digitStrings = number.characters.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.offset % 2 == 1

            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }

        return sum % 10 == 0
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var account: AccountPlainObject!
    
    var masterToken: MasterTokenPlainObject!
    
    var accountsService: AccountsService!
    
    @objc var wrapper: Web3Wrapper!
    
    @objc var router: ProfileRouterInput!

    @objc var customTransitioningDelegate: UIViewControllerTransitioningDelegate!

    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var creditCardTextField: UITextField!
    
    
    @IBAction func closeButtonDown(_ sender: UIButton) {
        self.router.close()
        
    }
    
    @IBAction func updateButtonDown(_ sender: UIButton) {
        
        if(nameTextField.text == nil || nameTextField.text?.count ?? 0 < 3){
            showErrorMessage(NSLocalizedString("Name is too short (3 characters minimum)", comment: "Name error"))
        }
        
        if(emailTextField.text == nil || !isValidEmail(emailTextField.text ?? "")){
            showErrorMessage(NSLocalizedString("Invalid email", comment: "Email error"))

        }
        
        if(phoneTextField.text == nil || phoneTextField.text?.count ?? 0 != 10){
            showErrorMessage(NSLocalizedString("Invalid phone number", comment: "Phone error"))
        }
        
        if(addressTextField.text == nil || addressTextField.text?.count ?? 0 < 3){
            showErrorMessage(NSLocalizedString("Address must be non-empty", comment: "Address error"))
        }
        
        if(countryTextField.text == nil || countryTextField.text?.count ?? 0 < 4){
            showErrorMessage(NSLocalizedString("Country name is too short (4 characters minimum)", comment: "Country error"))
        }
        
        
        let cardFormat = validateCreditCardFormat(string: creditCardTextField.text ?? "")
        
        if(creditCardTextField.text == nil || !cardFormat.valid){
            showErrorMessage(NSLocalizedString("Invalid card number", comment: "Card error"))

        }
        
        let alert = UIAlertController(title: NSLocalizedString("Type your password", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Password", comment: "")
            textField.textContentType = UITextContentType.password
            textField.isSecureTextEntry = true
            
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in


            let password = alert.textFields?.first?.text
            
            if self.wrapper.validatePassword(password: password!, masterToken: self.masterToken, account: self.account) {
                
                self.findUser(withPassword: password!)
            
            } else {
                
                let alertController = UIAlertController(title: NSLocalizedString("Wrong password", comment: "Wrong password"), message: NSLocalizedString("The password you entered is wrong", comment: "Error message"), preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                                            
                }
                
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion:nil)
                
            }
            
            
        }))
        
        self.present(alert, animated: true)

        
    }
    
    func findUser(withPassword: String){
        let jsonBodyDict: NSMutableDictionary? =
        [
            "email" : emailTextField.text!,
            "wallet" : self.masterToken.address.lowercased()
        ]
        
        let jsonBodyData = try? JSONSerialization.data(withJSONObject: jsonBodyDict!, options: .prettyPrinted)
        
        // create post request
        let url = URL(string: "https://ivoxis-backend.azurewebsites.net/api/user/find")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // insert json data to the request
        request.httpBody = jsonBodyData

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                self.showErrorMessage(error?.localizedDescription ?? "No data")
                return
            }
            
            let httpStatus = response as? HTTPURLResponse
            
            if httpStatus?.statusCode == 200 {
                self.updateUser(withPassword: withPassword)
            } else {
                self.registerUser(withPassword: withPassword)
            }
        }

        task.resume()
    }
    
    func registerUser(withPassword: String){
        
                
        let jsonBodyDict: NSMutableDictionary? =
        [
            "name" : nameTextField.text!,
            "email" : emailTextField.text!,
            "phone" : phoneTextField.text!,
            "address": addressTextField.text!,
            "country": countryTextField.text!,
            "card": creditCardTextField.text!,
            "wallet" : self.masterToken.address.lowercased(),
            "password" : withPassword
        ]
        
        let jsonBodyData = try? JSONSerialization.data(withJSONObject: jsonBodyDict!, options: .prettyPrinted)
        
        // create post request
        let url = URL(string: "https://ivoxis-backend.azurewebsites.net/api/user/register")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // insert json data to the request
        request.httpBody = jsonBodyData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")


        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                self.showErrorMessage(error?.localizedDescription ?? "No data")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                self.showErrorMessage("Server returned an error")
            }
            
            self.accountsService.setUsername(self.account, username: self.nameTextField.text!)
            
            self.accountsService.setEmail(self.account, email: self.emailTextField.text!)
            
            self.accountsService.setPhone(self.account, phone: self.phoneTextField.text!)
            
            self.accountsService.setAddress(self.account, address:
                self.addressTextField.text!)
            
            self.accountsService.setCountry(self.account, country:
                self.countryTextField.text!)
            
            self.accountsService.setCard(self.account, card:
                self.creditCardTextField.text!)
            
            self.showInfoMessage("Operation completed!")
            
        }

        task.resume()
    }
    
    func updateUser(withPassword: String){
        
                
        let jsonBodyDict: NSMutableDictionary? =
        [
            "name" : nameTextField.text!,
            "email" : self.accountsService.getEmail(self.account)!,
            "new_email" : emailTextField.text!,
            "phone" : phoneTextField.text!,
            "address": addressTextField.text!,
            "country": countryTextField.text!,
            "card": creditCardTextField.text!,
            "wallet" : self.masterToken.address.lowercased(),
            "password" : withPassword
        ]
        
        let jsonBodyData = try? JSONSerialization.data(withJSONObject: jsonBodyDict!, options: .prettyPrinted)
        
        // create post request
        let url = URL(string: "https://ivoxis-backend.azurewebsites.net/api/user/update")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // insert json data to the request
        request.httpBody = jsonBodyData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")


        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                self.showErrorMessage(error?.localizedDescription ?? "No data")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                self.showErrorMessage("Server returned an error")
            }
            
            self.accountsService.setUsername(self.account, username: self.nameTextField.text!)
            
            self.accountsService.setEmail(self.account, email: self.emailTextField.text!)
            
            self.accountsService.setPhone(self.account, phone: self.phoneTextField.text!)
            
            self.accountsService.setAddress(self.account, address:
                self.addressTextField.text!)
            
            self.accountsService.setCountry(self.account, country:
                self.countryTextField.text!)
            
            self.accountsService.setCard(self.account, card:
                self.creditCardTextField.text!)
            
            self.showInfoMessage("Operation completed!")
            
        }

        task.resume()
    }
    
    func showInfoMessage(_ info: String){
        let alertController = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
               
        let OKAction = UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default) { (action:UIAlertAction!) in
                                           
        }

        alertController.addAction(OKAction)

        if(self.presentedViewController == nil){
            self.present(alertController, animated: true, completion:nil)
        } else {
          self.presentedViewController?.dismiss(animated: true, completion: {
              self.present(alertController, animated: true, completion:nil)
          })
        }

    }
    
    func showErrorMessage(_ error: String){

        let alertController = UIAlertController(title: "Error", message: NSLocalizedString("An error occurred: ", comment:"Error description") +  error, preferredStyle: .alert)
         
         let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                                     
         }
         alertController.addAction(OKAction)
         
        if(self.presentedViewController == nil){
         self.present(alertController, animated: true, completion:nil)
        } else {
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.present(alertController, animated: true, completion:nil)
            })
        }

    }
}
