//
//  ProfileViewController.swift
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress
import BigInt

@objc class VoteViewController: UIViewController, VoteViewInput {
    
    enum Selection{
        case None
        case Yes
        case No
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes,
        // always use one of bytes1 to bytes32 because they are much cheaper
        var title: String;   // short name
        var description: String;   // description
        var yesVoteCount: uint; // number of accumulated votes saying yes
        var noVoteCount: uint; // number of accumulated votes saying no

        var dateProposed: uint;
        var expirationDate: uint;
    }
    
    var selection = Selection.None
    
    
    var voteBatch: NSNumber!

    var account: AccountPlainObject!
    
    var masterToken: MasterTokenPlainObject!
    
    var accountsService: AccountsService!
    
    @objc var wrapper: Web3Wrapper!
    var web3: web3!
    var contract: web3.web3contract!

    
    @objc var router: VoteRouterInput!

    @objc var customTransitioningDelegate: UIViewControllerTransitioningDelegate!
    
    @IBOutlet weak var proposalTitleLabel: UILabel!
    
    @IBOutlet weak var proposalLabel: UILabel!
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var voteButton: UIButton!
    
    @IBAction func closeButtonDown(_ sender: UIButton) {
        self.router.close()
        
    }
    
    @IBAction func yesButtonDown(_ sender: UIButton) {
        selection = Selection.Yes
        yesButton.isSelected = true
        noButton.isSelected = false
    }
    
    @IBAction func noButtonDown(_ sender: UIButton) {
        selection = Selection.No
        noButton.isSelected = true
        yesButton.isSelected = false
    }
    
    @IBAction func voteButtonDown(_ sender: UIButton) {

        var voteSelection = -1
        
        switch selection{
        case .Yes: voteSelection = 1
            
        case .No:  voteSelection = 0
        case .None: return
        }
        
        let voterTransactionIntermediate = self.contract?.method("getVoter", parameters:[uint(truncating: voteBatch)] as [AnyObject])

        let voterPromise = voterTransactionIntermediate!.callPromise()
        
         let voterPromiseDoneResult = voterPromise.done(on: .global(), { result in
             let voted = (result["voted"] as! Bool)

            if(!voted){
                let voteTransactionIntermediate = self.contract?.method("vote", parameters:[uint(truncating: self.voteBatch), uint(voteSelection)] as [AnyObject])

                       let votePromise = voteTransactionIntermediate!.sendPromise(password:self.password, transactionOptions: self.contract.transactionOptions)
                       
                        let votePromiseDoneResult = votePromise.done(on: .global(), { result in
                            func openProposal() -> () {
                                self.router.openProposal(withAccountAndMasterToken: self.account, masterToken: self.masterToken, voteBatch: self.voteBatch as! Int32)
                            }

                            self.showInfoMessage(NSLocalizedString("Voting has been successful, please allow up to 5 minutes before reflecting changes", comment: "Success message"), onClose: openProposal)
                        })
                           
                       votePromiseDoneResult.catch({error in
                           let web3Error = error as! Web3Error
                            self.showErrorMessage(NSLocalizedString("An error occurred or you don't have enough tokens", comment: "Error message") + ": " + web3Error.description)
                        
                       })
            } else{
                func openProposal() -> (){
                    self.router.openProposal(withAccountAndMasterToken: self.account, masterToken: self.masterToken, voteBatch: self.voteBatch as! Int32)
                }

                self.showInfoMessage(NSLocalizedString("You have voted this proposal already", comment: "Error message"), onClose: openProposal)
                
            }

         })
            
        voterPromiseDoneResult.catch({error in
            let web3Error = error as! Web3Error
             self.showErrorMessage(NSLocalizedString("An error occurred or you don't have enough tokens", comment: "Error message") + ": " + web3Error.description)
         
        })

        
       



    }
    
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        proposalTitleLabel.text = NSLocalizedString("Proposal", comment: "Title")
        
        proposalLabel.text = ""
        
        voteButton.titleLabel!.text = NSLocalizedString("Vote", comment: "Vote button title")
        
        prompt()
    }

    func load(){
        
       let transactionIntermediate = self.contract?.method("getProposal", parameters:[voteBatch] as [AnyObject])

       let promise = transactionIntermediate!.callPromise()
       let promiseDoneResult = promise.done(on: .global(), { result in
           
           let yvc = (result["yesCount"] as! BigUInt)
           let nvc = (result["noCount"] as! BigUInt)
           let p = (result["proposed"] as! BigUInt)
           let e = (result["expiration"] as! BigUInt)

        let yesVoteCount = uint(Web3.Utils.formatToEthereumUnits(yvc)!)!
           let noVoteCount = uint(Web3.Utils.formatToEthereumUnits(nvc)!)!
           let proposed = uint(p.description)!
           let expiration = uint(e.description)!
           
           let proposal: Proposal =
               Proposal(title: result["title"] as! String,
                        description: result["description"] as! String,
                        yesVoteCount: yesVoteCount,
                        noVoteCount: noVoteCount,
                        dateProposed: proposed,
                        expirationDate: expiration)
            DispatchQueue.main.async {
                self.proposalTitleLabel.text = proposal.title
                self.proposalLabel.text = proposal.description
            }
       })
          
      promiseDoneResult.catch({error in
          let web3Error = error as! Web3Error
           self.showErrorMessage(NSLocalizedString("An error occurred or you don't have enough tokens", comment: "Error message") + ": " + web3Error.description)
       
      })
        
    }
    func prompt(){
        

        let alert = UIAlertController(title: NSLocalizedString("Type your password", comment: ""), message: nil, preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Password", comment: "")
            textField.textContentType = UITextContentType.password
            textField.isSecureTextEntry = true
            
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in


            self.password = alert.textFields?.first?.text
                
            if self.wrapper.validatePassword(password: self.password, masterToken: self.masterToken, account: self.account) {
                
                let endpoint = VotingConstants.INFURA_URL
                self.web3 = Web3.new(URL(string: endpoint)!)

                
                let encryptedKeydata = self.wrapper.keychainService?.obtainKeydata(ofMasterToken: self.masterToken, ofAccount: self.account, inChainID: BlockchainNetworkType.ethereum)
                
                let keystoreData = self.wrapper.MEWcrypto?.decryptData(encryptedKeydata!, withPassword: self.password!)
                
                let bip32Keystore = BIP32Keystore(keystoreData!)
                
                let account = bip32Keystore?.addresses?.first
                
                let privateKey = try? bip32Keystore?.UNSAFE_getPrivateKeyData(password: self.password, account: account!)
                
                let key = privateKey!?.toHexString() // Some private key
                let formattedKey = key!.trimmingCharacters(in: .whitespacesAndNewlines)
                let dataKey = Data.fromHex(formattedKey)!
                let keystoreV3 = try! EthereumKeystoreV3(privateKey: dataKey, password: self.password)!

                let keystoreManager = KeystoreManager([keystoreV3])
                
                self.web3?.addKeystoreManager(keystoreManager);

                let walletAddress = EthereumAddress(self.masterToken.address)! // Your wallet address
                let contractAddress = EthereumAddress(VotingConstants.CONTRACT_ADDRESS)!
                self.contract = self.web3!.contract(VotingConstants.CONTRACT_ABI, at: contractAddress)!

                var options = TransactionOptions.defaultOptions
                options.value = 0x0
                options.from = walletAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                options.nonce = .latest
                options.callOnBlock = .latest
                
                self.contract.transactionOptions = options
                
                self.load()
                                
            } else {
                
                let alertController = UIAlertController(title: NSLocalizedString("Wrong password", comment: "Wrong password"), message: NSLocalizedString("The password you entered is wrong", comment: "Error message"), preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    DispatchQueue.main.async {
                        self.prompt()
                    }

                }

                let CancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel) { (action:UIAlertAction!) in
                    DispatchQueue.main.async {

                        self.router.close()
                    }

                }

                alertController.addAction(OKAction)
                alertController.addAction(CancelAction)

                self.present(alertController, animated: true, completion:nil)
                
            }
            
        }))
        
        let CancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel) { (action:UIAlertAction!) in
            DispatchQueue.main.async {

                self.router.close()
            }

        }

        alert.addAction(CancelAction)

        DispatchQueue.main.async {

            self.present(alert, animated: true)
        }
    }
    
    func showInfoMessage(_ info: String,  onClose: @escaping() -> Void){
        let alertController = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
               
        let OKAction = UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default) { (action:UIAlertAction!) in
            onClose()
        }

        alertController.addAction(OKAction)

        DispatchQueue.main.async {

            if(self.presentedViewController == nil){
                self.present(alertController, animated: true, completion:nil)
            } else {
                self.presentedViewController?.dismiss(animated: true, completion: {
                    self.present(alertController, animated: true, completion:nil)
                })
            }
        }
    }
    
    func showErrorMessage(_ error: String){

        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
         
         let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            DispatchQueue.main.async {

                self.router.close()
            }

            
         }
         alertController.addAction(OKAction)
         
        DispatchQueue.main.async {

            if(self.presentedViewController == nil){
                self.present(alertController, animated: true, completion:nil)
            } else {
                self.presentedViewController?.dismiss(animated: true, completion: {
                    self.present(alertController, animated: true, completion:nil)
                })
            }
        }

    }
}
