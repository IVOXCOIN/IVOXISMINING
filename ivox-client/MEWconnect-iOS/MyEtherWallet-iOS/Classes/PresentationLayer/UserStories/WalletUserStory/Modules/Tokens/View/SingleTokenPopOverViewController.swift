//
//  SingleTokenPopOverViewController.swift
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 26/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

import UIKit

class SingleTokenPopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    @objc public var titles: [String] = ["0","1","2","3","4","5","6","7","8","9"]
    
    @objc public var names: [String] = ["0","1","2","3","4","5","6","7","8","9"]

    override func viewDidLoad() {
        super.viewDidLoad()
           tableView.dataSource = self
           tableView.delegate = self
        

        // Do any additional setup after loading the view.
    }
    
    // Returns count of items in tableView
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.names.count;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! TokenHeadlineTableViewCell

        print("Title : " + cell.headlineTitleLabel.text!)
        print("Text : " + cell.headlineTextView.text!)
        
    }

    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TokenHeadlineTableViewCell

        cell.headlineTitleLabel.text = titles[indexPath.row];
        cell.headlineTextView.text = names[indexPath.row];

        cell.headlineTitleLabel.numberOfLines = 0;
        cell.headlineTitleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping;        

        cell.headlineTextView.sizeToFit()
       return cell
    }

    @IBAction func closePopup(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
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
