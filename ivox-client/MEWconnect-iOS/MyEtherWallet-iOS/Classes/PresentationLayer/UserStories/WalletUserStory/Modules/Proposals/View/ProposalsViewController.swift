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


@objc class ProposalsViewController: UIViewController, ProposalsViewInput, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.animals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!

        // set the text from the data model
        cell.textLabel?.text = self.animals[indexPath.row]

        return cell

    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }


    @IBOutlet var tableView: UITableView!

    
    var account: AccountPlainObject!
    
    var masterToken: MasterTokenPlainObject!
    
    var accountsService: AccountsService!
    
    @objc var wrapper: Web3Wrapper!
    var web3: web3!
    var contract: web3.web3contract!

    
    @objc var router: ProfileRouterInput!
    
    // Data model: These strings will be the data for the table view cells
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat", "Chicken",
        "Donkey", "Duck", "Panda"]

    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"


    var CONTRACT_ABI: String = "[\n    {\n      \"inputs\": [],\n      \"payable\": false,\n      \"stateMutability\": \"nonpayable\",\n      \"type\": \"constructor\"\n    },\n    {\n      \"anonymous\": false,\n      \"inputs\": [\n        {\n          \"indexed\": true,\n          \"internalType\": \"address\",\n          \"name\": \"oldOwner\",\n          \"type\": \"address\"\n        },\n        {\n          \"indexed\": true,\n          \"internalType\": \"address\",\n          \"name\": \"newOwner\",\n          \"type\": \"address\"\n        }\n      ],\n      \"name\": \"OwnerSet\",\n      \"type\": \"event\"\n    },\n    {\n      \"constant\": false,\n      \"inputs\": [\n        {\n          \"internalType\": \"address\",\n          \"name\": \"newOwner\",\n          \"type\": \"address\"\n        }\n      ],\n      \"name\": \"changeOwner\",\n      \"outputs\": [],\n      \"payable\": false,\n      \"stateMutability\": \"nonpayable\",\n      \"type\": \"function\"\n    },\n    {\n      \"constant\": true,\n      \"inputs\": [],\n      \"name\": \"getOwner\",\n      \"outputs\": [\n        {\n          \"internalType\": \"address\",\n          \"name\": \"\",\n          \"type\": \"address\"\n        }\n      ],\n      \"payable\": false,\n      \"stateMutability\": \"view\",\n      \"type\": \"function\"\n    },\n    {\n      \"constant\": false,\n      \"inputs\": [\n        {\n          \"internalType\": \"address\",\n          \"name\": \"_address\",\n          \"type\": \"address\"\n        }\n      ],\n      \"name\": \"setERC20ContractAddress\",\n      \"outputs\": [],\n      \"payable\": false,\n      \"stateMutability\": \"nonpayable\",\n      \"type\": \"function\"\n    },\n    {\n      \"constant\": false,\n      \"inputs\": [\n        {\n          \"internalType\": \"string\",\n          \"name\": \"_proposalName\",\n          \"type\": \"string\"\n        }\n      ],\n      \"name\": \"setProposal\",\n      \"outputs\": [],\n      \"payable\": false,\n      \"stateMutability\": \"nonpayable\",\n      \"type\": \"function\"\n    },\n    {\n      \"constant\": false,\n      \"inputs\": [\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"yesNo\",\n          \"type\": \"uint256\"\n        }\n      ],\n      \"name\": \"vote\",\n      \"outputs\": [],\n      \"payable\": false,\n      \"stateMutability\": \"nonpayable\",\n      \"type\": \"function\"\n    },\n    {\n      \"constant\": true,\n      \"inputs\": [],\n      \"name\": \"getLatestVoteBatch\",\n      \"outputs\": [\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"\",\n          \"type\": \"uint256\"\n        }\n      ],\n      \"payable\": false,\n      \"stateMutability\": \"view\",\n      \"type\": \"function\"\n    },\n    {\n      \"constant\": true,\n      \"inputs\": [],\n      \"name\": \"getLatestProposal\",\n      \"outputs\": [\n        {\n          \"internalType\": \"string\",\n          \"name\": \"name\",\n          \"type\": \"string\"\n        },\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"yesCount\",\n          \"type\": \"uint256\"\n        },\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"noCount\",\n          \"type\": \"uint256\"\n        },\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"proposed\",\n          \"type\": \"uint256\"\n        },\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"expiration\",\n          \"type\": \"uint256\"\n        }\n      ],\n      \"payable\": false,\n      \"stateMutability\": \"view\",\n      \"type\": \"function\"\n    },\n    {\n      \"constant\": true,\n      \"inputs\": [\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"voteBatch\",\n          \"type\": \"uint256\"\n        }\n      ],\n      \"name\": \"getProposal\",\n      \"outputs\": [\n        {\n          \"internalType\": \"string\",\n          \"name\": \"name\",\n          \"type\": \"string\"\n        },\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"yesCount\",\n          \"type\": \"uint256\"\n        },\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"noCount\",\n          \"type\": \"uint256\"\n        },\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"proposed\",\n          \"type\": \"uint256\"\n        },\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"expiration\",\n          \"type\": \"uint256\"\n        }\n      ],\n      \"payable\": false,\n      \"stateMutability\": \"view\",\n      \"type\": \"function\"\n    },\n    {\n      \"constant\": true,\n      \"inputs\": [\n        {\n          \"internalType\": \"uint256\",\n          \"name\": \"voteBatch\",\n          \"type\": \"uint256\"\n        }\n      ],\n      \"name\": \"getVoters\",\n      \"outputs\": [\n        {\n          \"internalType\": \"address[]\",\n          \"name\": \"addresses\",\n          \"type\": \"address[]\"\n        },\n        {\n          \"internalType\": \"uint256[]\",\n          \"name\": \"weights\",\n          \"type\": \"uint256[]\"\n        },\n        {\n          \"internalType\": \"bool[]\",\n          \"name\": \"voted\",\n          \"type\": \"bool[]\"\n        },\n        {\n          \"internalType\": \"uint256[]\",\n          \"name\": \"votes\",\n          \"type\": \"uint256[]\"\n        }\n      ],\n      \"payable\": false,\n      \"stateMutability\": \"view\",\n      \"type\": \"function\"\n    }\n  ]"

    var CONTRACT_ADDRESS: String = "0x52431f5d20572086434857Cd5b8713B754aE3A47"
    
    var INFURA_URL: String = "https://mainnet.infura.io/v3/1febc18120a2467b9820ed83e95c0cfa"

    @objc var customTransitioningDelegate: UIViewControllerTransitioningDelegate!

    
    @IBAction func closeButtonDown(_ sender: UIButton) {
        self.router.close()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let endpoint = self.INFURA_URL
        self.web3 = Web3.new(URL(string: endpoint)!)
        
        let walletAddress = EthereumAddress(self.masterToken.address)! // Your wallet address

        let erc20ContractAddress = EthereumAddress(self.CONTRACT_ADDRESS)!
        
        self.contract = self.web3!.contract(self.CONTRACT_ABI, at: erc20ContractAddress)!
        
        var options = TransactionOptions.defaultOptions
        options.value = "0x0"
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        options.nonce = .latest
        options.callOnBlock = .latest
        
        self.contract.transactionOptions = options
        
        let transactionIntermediate = self.contract?.method("getLatestVoteBatch", parameters:[] as [AnyObject])

        let promise = transactionIntermediate!.sendPromise()
        let promiseDoneResult = promise.done(on: .global(), { result in
                              
                                   
               self.showInfoMessage(NSLocalizedString("Operation completed: You can view the transaction status on Etherscan", comment: "Description"))
            
            print(result.transaction.data)
            
        })
           
       promiseDoneResult.catch({error in
           let web3Error = error as! Web3Error
           self.showErrorMessage(web3Error.description)
       })



    }

    
    @IBAction func updateButtonDown(_ sender: UIButton) {
        
        
    }
    
    func findUser(withPassword: String){
      
    }
    
    func registerUser(withPassword: String){
        
      
    }
    
    func updateUser(withPassword: String){
        
    }
    
    func showInfoMessage(_ info: String){
        let alertController = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
               
        let OKAction = UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default) { (action:UIAlertAction!) in
                                           
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

        let alertController = UIAlertController(title: "Error", message: NSLocalizedString("An error occurred: ", comment:"Error description") +  error, preferredStyle: .alert)
         
         let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                                     
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
