//
//  PreviewVideoContainerView.swift
//  ReputationApp
//
//  Created by Omar Torres on 9/10/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Photos
import Locksmith
import Alamofire

class PreviewVideoContainerView: UIViewController {
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 16)
        label.textColor = .white
        label.backgroundColor = .clear
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 6
        return label
    }()
    
    var url: URL?
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 13)
        label.textColor = .white
        label.backgroundColor = .clear
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 6
        label.text = "0:00"
        return label
    }()
    
    let defaultImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    let optionButton: UIButton = {
        let button = UIButton()
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 2
        button.setImage(#imageLiteral(resourceName: "dot_vertical_option").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    func handleCancel() {
        view.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(defaultImage)
        defaultImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        defaultImage.layer.zPosition = 2
        
        view.addSubview(userNameLabel)
        userNameLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(optionButton)
        optionButton.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 15, height: 15)
        optionButton.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        
        view.addSubview(videoLengthLabel)
        videoLengthLabel.anchor(top: userNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
}
