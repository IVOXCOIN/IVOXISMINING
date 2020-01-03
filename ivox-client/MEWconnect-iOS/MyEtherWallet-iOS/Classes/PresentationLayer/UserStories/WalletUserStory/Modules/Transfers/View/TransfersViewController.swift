//
//  TransfersViewController.swift
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 31/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress
import PromiseKit

@objc class TransfersViewController: UIViewController, TransfersViewInput, UITextViewDelegate {
    
    var CONTRACT_ABI: String = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"burn\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"burnFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"},{\"name\":\"\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"name\":\"initialSupply\",\"type\":\"uint256\"},{\"name\":\"tokenName\",\"type\":\"string\"},{\"name\":\"tokenSymbol\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"from\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Burn\",\"type\":\"event\"}]"
    
    var CONTRACT_ADDRESS: String = "0x1c26C58d230B48A7e012F27D769703909309c75c"
    var INFURA_URL: String = "https://mainnet.infura.io/v3/1febc18120a2467b9820ed83e95c0cfa"

    
    var account: AccountPlainObject!
    
    var masterToken: MasterTokenPlainObject!
    
    
    @objc var router: TransfersRouterInput!

    @objc var customTransitioningDelegate: UIViewControllerTransitioningDelegate!

    @objc var wrapper: Web3Wrapper!

    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var addressSwitch: UISwitch!
    @IBOutlet weak var amountStepper: UIStepper!
    @IBOutlet weak var amountTextView: UITextView!
    @IBOutlet weak var amountSwitch: UISwitch!
    @IBOutlet weak var declineButton: FlatButton!
    @IBOutlet weak var confirmButton: FlatButton!
    
    @IBAction func onAmountStepperValueChanged(_ sender: UIStepper) {
        
        self.amountTextView.text = String(Int(sender.value));
        
    }
    
    
    @IBAction func OnDeclineButtonDown(_ sender: FlatButton) {
        self.router.close()
    }
    
    
    @IBAction func onConfirmButtonDown(_ sender: FlatButton) {
        
        let ethereumAddress = EthereumAddress(self.addressTextView.text!)
        
        if((ethereumAddress) != nil){
            
            let alert = UIAlertController(title: "Type your password", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Input your password here."
                textField.textContentType = UITextContentType.password
                
            })

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in


                let password = alert.textFields?.first?.text
                    
                if self.wrapper.validatePassword(password: password!, masterToken: self.masterToken, account: self.account) {
                    
                    let endpoint = self.INFURA_URL
                    let web3 = Web3.new(URL(string: endpoint)!)

                    
                    let encryptedKeydata = self.wrapper.keychainService?.obtainKeydata(ofMasterToken: self.masterToken, ofAccount: self.account, inChainID: BlockchainNetworkType.ethereum)
                    
                    let keystoreData = self.wrapper.MEWcrypto?.decryptData(encryptedKeydata!, withPassword: password!)
                    
                    let bip32Keystore = BIP32Keystore(keystoreData!)
                    
                    let account = bip32Keystore?.addresses?.first
                    
                    let privateKey = try? bip32Keystore?.UNSAFE_getPrivateKeyData(password: password!, account: account!)
                    
                    let key = privateKey!?.toHexString() // Some private key
                    let formattedKey = key!.trimmingCharacters(in: .whitespacesAndNewlines)
                    let dataKey = Data.fromHex(formattedKey)!
                    let keystoreV3 = try! EthereumKeystoreV3(privateKey: dataKey, password: password!)!

                    let keystoreManager = KeystoreManager([keystoreV3])
                    
                    web3?.addKeystoreManager(keystoreManager);

                    let value: String = "1.0" // In Tokens
                    let walletAddress = EthereumAddress(self.masterToken.address)! // Your wallet address
                    let toAddress = EthereumAddress(self.addressTextView.text!)!
                    let erc20ContractAddress = EthereumAddress(self.CONTRACT_ADDRESS)!
                    let contract = web3!.contract(self.CONTRACT_ABI, at: erc20ContractAddress)!
                    let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
                        
                    do{
                        var options = TransactionOptions.defaultOptions
                        options.value = amount
                        options.from = walletAddress
                        options.gasPrice = .automatic
                        options.gasLimit = .automatic
                        options.nonce = .latest
                        options.callOnBlock = .latest
                        
                        contract.transactionOptions = options
                        
                        let method = "transfer"
                        let promise = contract.write(
                            method,
                            parameters: [toAddress, amount] as [AnyObject],
                            extraData: Data(),
                            transactionOptions: options)!.sendPromise(password: password!, transactionOptions: options)
                        
                        _ = promise.done(on: DispatchQueue.main, {(results) in
                            print(results)
                        })

                        /*var transaction = tx.transaction
                                                
                        try Web3Signer.EIP155Signer.sign(transaction: &transaction, privateKey: privateKey!!, useExtraEntropy: false)
                        
                        let result = try web3!.eth.sendRawTransaction(transaction)*/

                    } catch {
                        print(error)
                    }
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Wrong password", message: "The password you entered is wrong", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                                                
                    }
                    
                    alertController.addAction(OKAction)
                    
                    self.present(alertController, animated: true, completion:nil)
                    
                }
                
            }))

            self.present(alert, animated: true)

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.amountTextView.delegate = self

        addressSwitch.addTarget(self, action: #selector(TransfersViewController.addressSwitchIsChanged(_:)), for: .valueChanged)
        
        amountSwitch.addTarget(self, action: #selector(TransfersViewController.amountSwitchIsChanged(_:)), for: .valueChanged)

    }
    
    func textViewDidChange(_ textView: UITextView) {
        switch (textView) {
            case amountTextView:
                
                if self.amountTextView.text.isEmpty {
                    self.amountStepper.value = Double(0)
                } else {
                    self.amountStepper.value = Double(self.amountTextView.text)!
                }
            break
        default: break
        }
    }
    
    @objc func addressSwitchIsChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.addressTextView.isUserInteractionEnabled = false
        } else {
            self.addressTextView.isUserInteractionEnabled = true
        }
        
        if self.amountSwitch.isOn && self.addressSwitch.isOn {
            self.confirmButton.isEnabled = true;
        } else {
            self.confirmButton.isEnabled = false;
        }
    }

    @objc func amountSwitchIsChanged(_ sender: UISwitch) {
        if self.amountSwitch.isOn && self.addressSwitch.isOn {
            self.confirmButton.isEnabled = true;
        } else {
            self.confirmButton.isEnabled = false;
        }

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
