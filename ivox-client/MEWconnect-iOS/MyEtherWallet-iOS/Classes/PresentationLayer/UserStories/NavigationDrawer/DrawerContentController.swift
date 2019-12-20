//
//  DrawrContentController.swift
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 19/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

import Foundation
import UIKit

@objc class DrawerContentController: UIViewController {

   let collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
       layout.minimumLineSpacing = 0
       layout.minimumInteritemSpacing = 0
       
       let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
       return collectionView
   }()
   
   override func viewDidLoad() {
       super.viewDidLoad()
       view.backgroundColor = .white
       
       collectionView.backgroundColor = .white
       collectionView.delegate = self
       collectionView.dataSource = self
       collectionView.register(DrawerCollectionViewCell.self, forCellWithReuseIdentifier: "DrawerCollectionViewCell")
       
       setLayout()
   }
   
   func setLayout() {
       view.addSubview(collectionView)
       collectionView.translatesAutoresizingMaskIntoConstraints = false
       collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
       collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
       collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
       collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
   }
}

extension DrawerContentController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 4
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawerCollectionViewCell", for: indexPath) as! DrawerCollectionViewCell
       setDrawerList(cell: cell, index: indexPath.item)
       return cell
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       return CGSize(width: view.frame.width, height: 50)
   }
   
   func setDrawerList(cell: DrawerCollectionViewCell, index: Int) {
       switch index {
       case 0:
           cell.cellIcon.image = UIImage(named: "mail_black_24dp")
           cell.cellName.text = "Inbox"
       case 1:
           cell.cellIcon.image = UIImage(named: "send_black_24dp")
           cell.cellName.text = "Outbox"
       case 2:
           cell.cellIcon.image = UIImage(named: "favorite_black_24dp")
           cell.cellName.text = "Favorites"
       case 3:
           cell.cellIcon.image = UIImage(named: "delete_black_24dp")
           cell.cellName.text = "Trash"
       default:
           break
       }
   }
}

class DrawerCollectionViewCell: UICollectionViewCell {
   
   let cellIcon: UIImageView = {
       let view = UIImageView()
       return view
   }()
   
   let cellName: UILabel = {
       let label = UILabel()
       label.sizeToFit()
       return label
   }()
   
   override init(frame: CGRect) {
       super.init(frame: frame)
       setLayout()
   }
   
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
   
   func setLayout() {
       contentView.addSubview(cellIcon)
       cellIcon.translatesAutoresizingMaskIntoConstraints = false
       cellIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
       cellIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
       cellIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
       cellIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
       
       contentView.addSubview(cellName)
       cellName.translatesAutoresizingMaskIntoConstraints = false
       cellName.leadingAnchor.constraint(equalTo: cellIcon.trailingAnchor, constant: 50).isActive = true
       cellName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
   }
}
