//
//  CustomAlertMessage.swift
//  ReputationApp
//
//  Created by Omar Torres on 29/01/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import Foundation
import UIKit

class CustomAlertMessage: UIView {
    
    let viewMessage: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    let iconMessage: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let labelMessage: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayLow()
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        
        self.addSubview(self.viewMessage)
        
        self.viewMessage.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        self.viewMessage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
        self.viewMessage.addSubview(self.iconMessage)
        self.iconMessage.anchor(top: self.viewMessage.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.iconMessage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.viewMessage.addSubview(self.labelMessage)
        self.labelMessage.anchor(top: self.iconMessage.bottomAnchor, left: self.viewMessage.leftAnchor, bottom: self.viewMessage.bottomAnchor, right: self.viewMessage.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
