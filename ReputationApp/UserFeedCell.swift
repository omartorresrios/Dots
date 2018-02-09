//
//  UserFeedCell.swift
//  ReputationApp
//
//  Created by Omar Torres on 17/10/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class UserFeedCell: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let playView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor(white: 1, alpha: 0.3)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    let videoLengthLabel: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7)
        button.backgroundColor = .black
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.setTitle("0:00", for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var goToWatch : (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.isUserInteractionEnabled = true
        
//        photoImageView.addSubview(videoLengthLabel)
//        videoLengthLabel.anchor(top: photoImageView.topAnchor, left: photoImageView.leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        photoImageView.addSubview(playView)
        playView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        playView.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
        playView.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor).isActive = true
        playView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(watchVideo)))
        
        playView.addSubview(playButton)
        playButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        playButton.centerXAnchor.constraint(equalTo: playView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: playView.centerYAnchor).isActive = true
        playButton.addTarget(self, action: #selector(watchVideo), for: .touchUpInside)
        
    }
    
    func watchVideo() {
        goToWatch!()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

