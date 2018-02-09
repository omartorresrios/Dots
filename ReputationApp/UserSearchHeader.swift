//
//  UserSearchHeader.swift
//  ReputationApp
//
//  Created by Omar Torres on 29/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class UserSearchHeader: UICollectionViewCell {
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let addPeopleButton: UIButton = {
        let ap = UIButton(type: .system)
        ap.setTitle("¿No lo encontraste?, agrégalo (+5 pts)  👉", for: .normal)
        ap.titleLabel?.font = UIFont(name: "SFUIDisplay-Medium", size: 15)
        ap.isUserInteractionEnabled = true
        ap.setTitleColor(.white, for: .normal)
        return ap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(separatorView)
        separatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        
        addSubview(addPeopleButton)
        
        addPeopleButton.anchor(top: separatorView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addPeopleButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addPeopleButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



