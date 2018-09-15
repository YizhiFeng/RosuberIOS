//
//  BottomMenuLauncher.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/22.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//
import UIKit
import Foundation

class BottomMenuLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate,
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
//    var menuItems: [MenuItem]!
    var buttons: [UIButton]!
    
    func showMenu() {
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            window.addSubview(menuView)
            let height: CGFloat = CGFloat(buttons.count) * cellHeight
            let y = window.frame.height - height
            menuView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            // acceleration animation
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.menuView.frame = CGRect(x: 0, y: y, width: self.menuView.frame.width, height: self.menuView.frame.height)
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5) {
                self.blackView.alpha = 1
                
                self.menuView.frame = CGRect(x: 0, y: y, width: self.menuView.frame.width, height: self.menuView.frame.height)
            }
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.menuView.frame = CGRect(x: 0, y: window.frame.height, width: self.menuView.frame.width, height: self.menuView.frame.height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = menuView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
//        let menuItem = menuItems[indexPath.row]
//        cell.menuItem = menuItem
        cell.button = buttons[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: menuView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
//
//    init(menuItems: [MenuItem]) {
//        super.init()
//        self.menuItems = menuItems
//
//        menuView.dataSource = self
//        menuView.delegate = self
//        menuView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
//    }
    
    init(buttons: [UIButton]) {
        super.init()
        self.buttons = buttons
        
        menuView.dataSource = self
        menuView.delegate = self
        menuView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}
