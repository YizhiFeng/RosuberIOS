//
//  MenuCell.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/22.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Foundation

class MenuCell: UICollectionViewCell {
    
//    let button: UIButton = {
//        let button = UIButton(type: UIButtonType.system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = .white
//        button.tintColor = UIColor.black
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
//        button.contentHorizontalAlignment = .center
//        return button
//    }()
    
//    var action: (() -> ())?
//
    var menuItem: MenuItem? {
        didSet {
            button?.setTitle(menuItem?.title, for: .normal)
            button?.setImage(UIImage(named: (menuItem?.image)!), for: .normal)
            button?.imageView?.contentMode = .scaleAspectFit
//            action = menuItem?.action
        }
    }
    
        let btn: UIButton = {
            let button = UIButton(type: UIButtonType.system)
            return button
        }()
    
    
    var button: UIButton? {
        didSet {
            btn.setTitle(button?.titleLabel?.text, for: .normal)
            btn.setImage(button?.imageView?.image, for: .normal)
            btn.addTarget(self, action: #selector(actionOnPressed), for: .touchUpInside)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @objc func actionOnPressed() {
        button?.sendActions(for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .white
        btn.tintColor = UIColor.black
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        btn.contentHorizontalAlignment = .center
        btn.imageView?.contentMode = .scaleAspectFit
        
        btn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        btn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        btn.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
//        button.addTarget(self, action: #selector(actionOnPressed), for: .touchUpInside)
        btn.isUserInteractionEnabled = true
    }
}
