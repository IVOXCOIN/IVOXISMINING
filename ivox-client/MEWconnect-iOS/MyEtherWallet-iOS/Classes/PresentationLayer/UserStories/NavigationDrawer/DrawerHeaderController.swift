//
//  DrawerHeaderController.swift
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 19/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MaterialNavigationDrawer

class DrawerHeaderController: UIViewController, MDCBottomDrawerHeader {

   let titleLabel: UILabel = {
       let label = UILabel()
       label.text = "Ivoxis"
       label.font = UIFont.boldSystemFont(ofSize: 18)
       label.sizeToFit()
       return label
   }()
   
   let addressLabel: UILabel = {
       let label = UILabel()
       label.text = "drawerHeaderView@xxx.xxx"
       label.sizeToFit()
       return label
   }()
   
   override func viewDidLoad() {
       super.viewDidLoad()
       view.backgroundColor = .white

       setLayout()
   }
   
   func setLayout() {
       view.addSubview(titleLabel)
       titleLabel.translatesAutoresizingMaskIntoConstraints = false
       titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
       titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
       
    /*
       view.addSubview(addressLabel)
       addressLabel.translatesAutoresizingMaskIntoConstraints = false
       addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
       addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true*/
   }

}
