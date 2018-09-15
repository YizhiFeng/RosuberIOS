//
//  LeftMenuLauncher.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/23.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Foundation

class LeftMenuLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    let blackView = UIView()
    
    let menuView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    var menuItems: [MenuItem]!
    
    let y: CGFloat = UIApplication.shared.statusBarFrame.size.height
    
    func showMenu() {
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            window.addSubview(menuView)
            let height: CGFloat = CGFloat(menuItems.count) * (cellHeight + 5.0)
            menuView.frame = CGRect(x: 0, y: y, width: 0, height: 0)
            
            // acceleration animation
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.menuView.frame = CGRect(x: 0, y: self.y, width: window.frame.width / 2.5, height: height)
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5) {
                self.blackView.alpha = 1
                self.menuView.frame = CGRect(x: 0, y: self.y, width: self.menuView.frame.width, height: height)
            }
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.menuView.frame = CGRect(x: 0, y: self.y, width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = menuView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
        let menuItem = menuItems[indexPath.row]
        cell.menuItem = menuItem
        cell.button?.contentHorizontalAlignment = .center
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: menuView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    init(menuItems: [MenuItem]) {
        super.init()
        self.menuItems = menuItems
        
        menuView.dataSource = self
        menuView.delegate = self
        menuView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}
