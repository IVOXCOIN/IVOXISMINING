import UIKit
import Web3swift
import EthereumAddress
import BigInt

@objc class ProposalViewController: UIViewController, ProposalViewInput, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.voters!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!

        // set the text from the data model
        cell.textLabel?.text = self.voters![indexPath.row].address

        return cell

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
    
    struct Voter {
        var address: String;   // the voter address
        var weight: uint;   // the voters weight
        var voted: Bool; // if voted already
        var decision: uint; // decision (yes: 1, no: 0)
    }
    
    var voters: [Voter]?;

    var voteBatch: NSNumber!

    var account: AccountPlainObject!
    
    var masterToken: MasterTokenPlainObject!
    
    var accountsService: AccountsService!
    
    @objc var wrapper: Web3Wrapper!
    var web3: web3!
    var contract: web3.web3contract!

    
    @objc var router: VoteRouterInput!
    
    let cellReuseIdentifier = "cell"

    
    @objc var customTransitioningDelegate: UIViewControllerTransitioningDelegate!
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var proposalLabel: UILabel!

    @IBOutlet weak var yesPercentLabel: UILabel!
    
    @IBOutlet weak var noPercentLabel: UILabel!
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    
    @IBOutlet weak var votesLabel: UILabel!
    
    @IBAction func yesButtonDown(_ sender: Any) {
    }
    
    @IBAction func noButtonDown(_ sender: Any) {
    }
    @IBAction func closeButtonDown(_ sender: Any) {
        self.router.close()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.voters = []
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.votesLabel.text = NSLocalizedString("Votes", comment: "Votes label")

        load()
    }

    func load(){
        let endpoint = VotingConstants.INFURA_URL
        self.web3 = Web3.new(URL(string: endpoint)!)

        let contractAddress = EthereumAddress(VotingConstants.CONTRACT_ADDRESS)!
        
        self.contract = self.web3!.contract(VotingConstants.CONTRACT_ABI, at: contractAddress)!

        let walletAddress = EthereumAddress(self.masterToken.address)! // The wallet address

        var options = TransactionOptions.defaultOptions
        options.value = 0x0
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        options.nonce = .latest
        options.callOnBlock = .latest
        
        self.contract.transactionOptions = options

        
       let proposalIntermediate = self.contract?.method("getProposal", parameters:[voteBatch] as [AnyObject])

       let proposalPromise = proposalIntermediate!.callPromise()
       let proposalPromiseDoneResult = proposalPromise.done(on: .global(), { result in

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
                DispatchQueue.main.async {
                    //self.proposalTitleLabel.text = proposal.title
                    self.yesPercentLabel.text = String(proposal.yesVoteCount / (proposal.yesVoteCount + proposal.noVoteCount) * 100)
                    
                    self.yesPercentLabel.text = String(proposal.noVoteCount / (proposal.yesVoteCount + proposal.noVoteCount) * 100)
                    
                    self.proposalLabel.text = proposal.title
                }
        
            let votersIntermediate = self.contract?.method("getVoters", parameters:[self.voteBatch] as [AnyObject])

            let votersPromise = votersIntermediate!.callPromise()
            let votersPromiseDoneResult = votersPromise.done(on: .global(), { result in
            
                let addresses = result["addresses"]
                let weights = result["weights"]
                let voted = result["voted"]
                let decisions = result["decisions"]
                
                
            })
            
            votersPromiseDoneResult.catch({error in
                let web3Error = error as! Web3Error
                 self.showErrorMessage(NSLocalizedString("An error occurred or you don't have enough tokens", comment: "Error message") + ": " + web3Error.description)
             
            })

       })
          
      proposalPromiseDoneResult.catch({error in
          let web3Error = error as! Web3Error
           self.showErrorMessage(NSLocalizedString("An error occurred or you don't have enough tokens", comment: "Error message") + ": " + web3Error.description)
       
      })
        
    }
    
    func showInfoMessage(_ info: String, onClose: (() -> Void)?){
        let alertController = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
               
        let OKAction = UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default) { (action:UIAlertAction!) in
            onClose?()
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
