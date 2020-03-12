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

@objc class ProposalsViewController: UIViewController, ProposalsViewInput, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.proposals!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!

        // set the text from the data model
        cell.textLabel?.text = self.proposals![indexPath.row].title

        return cell

    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        self.router.openVote(withAccountAndMasterToken: self.account, masterToken: self.masterToken, voteBatch: Int32(indexPath.row))
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes,
        // always use one of bytes1 to bytes32 because they are much cheaper
        var title: String;   // short name
        var description: String; // description
        var yesVoteCount: uint; // number of accumulated votes saying yes
        var noVoteCount: uint; // number of accumulated votes saying no

        var dateProposed: uint;
        var expirationDate: uint;
    }
    
    var proposals: [Proposal]?;

    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var proposalsLabel: UILabel!
    
    var account: AccountPlainObject!
    
    var masterToken: MasterTokenPlainObject!
    
    var accountsService: AccountsService!
    
    @objc var wrapper: Web3Wrapper!
    var web3: web3!
    var contract: web3.web3contract!

    
    @objc var router: ProposalsRouterInput!
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"

    @objc var customTransitioningDelegate: UIViewControllerTransitioningDelegate!

    
    @IBAction func closeButtonDown(_ sender: UIButton) {
        self.router.close()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.proposalsLabel.text = NSLocalizedString("Proposals", comment: "Title")
        
        self.proposals = []
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let endpoint = VotingConstants.INFURA_URL
        self.web3 = Web3.new(URL(string: endpoint)!)
                
        let walletAddress = EthereumAddress(self.masterToken.address)! // Your wallet address

        let erc20ContractAddress = EthereumAddress(VotingConstants.CONTRACT_ADDRESS)!
        
        self.contract = self.web3!.contract(VotingConstants.CONTRACT_ABI, at: erc20ContractAddress)!
                
        /*
        var options = TransactionOptions.defaultOptions
        options.value = 0x0
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        options.nonce = .latest
        options.callOnBlock = .latest
        
        self.contract.transactionOptions = options*/
        
        var options = TransactionOptions.defaultOptions
        options.from = walletAddress

        self.contract.transactionOptions = options
        
        let transactionIntermediate = self.contract?.method("getLatestVoteBatch", parameters:[] as [AnyObject])

        let promise = transactionIntermediate!.callPromise()
        let promiseDoneResult = promise.done(on: .global(), { result in
            
            let biguint = (result["0"] as! BigUInt)
            
            let uintResult = uint(biguint.description)!
            
            self.iterateProposals(initialIndex: 0, finalIndex: uintResult + 1)

        })
           
       promiseDoneResult.catch({error in
           let web3Error = error as! Web3Error
            self.showErrorMessage(NSLocalizedString("An error occurred or you don't have enough tokens", comment: "Error message") + ": " + web3Error.description)
        
       })



    }

    func iterateProposals(initialIndex: uint, finalIndex: uint){
        if(initialIndex < finalIndex){
             let transactionIntermediate = self.contract?.method("getProposal", parameters:[initialIndex] as [AnyObject])

            let promise = transactionIntermediate!.callPromise()
             let promiseDoneResult = promise.done(on: .global(), { result in
                                   
                print(result)
                let yvc = (result["yesCount"] as! BigUInt)
                let nvc = (result["noCount"] as! BigUInt)
                let p = (result["proposed"] as! BigUInt)
                let e = (result["expiration"] as! BigUInt)

                let yesVoteCount = uint(yvc.description)!
                let noVoteCount = uint(nvc.description)!
                let proposed = uint(p.description)!
                let expiration = uint(e.description)!
                
                let proposal: Proposal =
                    Proposal(title: result["title"] as! String,
                             description: result["description"] as! String,
                             yesVoteCount: yesVoteCount,
                             noVoteCount: noVoteCount,
                             dateProposed: proposed,
                             expirationDate: expiration)

                self.proposals?.append(proposal)
                
                self.iterateProposals(initialIndex: initialIndex + 1, finalIndex: finalIndex)
             })
                
            promiseDoneResult.catch({error in
                let web3Error = error as! Web3Error
                self.showErrorMessage(NSLocalizedString("An error occurred or you don't have enough tokens", comment: "Error message") + ": " + web3Error.description)
            })


        } else{
            //update table
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }
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
