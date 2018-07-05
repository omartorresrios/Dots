//
//  UserFeedCell.swift
//  ReputationApp
//
//  Created by Omar Torres on 11/03/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import UIKit

class UserFeedCell: UICollectionViewCell {

    var review: ReviewAll? {
        didSet {
            let duration = NSInteger((review?.duration)!)
            let seconds = String(format: "%02d", duration % 60)
            let minutes = (duration / 60) % 60
            audioLengthLabel.text = "\(minutes):\(seconds)"
            
            guard let toProfileImageUrl = review?.toAvatarUrl else { return }
            toProfileImageView.loadImage(urlString: toProfileImageUrl)
            
            toFullnameLabel.text = review?.toFullname
            
            guard let fromProfileImageUrl = review?.fromAvatarUrl else { return }
            fromProfileImageView.loadImage(urlString: fromProfileImageUrl)
            
            fromFullnameLabel.text = review?.fromFullname
        }
    }
    
    let fromProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        return iv
    }()
    
    let fromFullnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayLow()
        label.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        label.textAlignment = .left
        return label
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .gray
        button.addTarget(self, action: #selector(previewAudio), for: .touchUpInside)
        return button
    }()
    
    let progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.mainGreen()
        progress.tintColor = .black
        progress.trackTintColor = .black
        return progress
    }()
    
    let audioLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0:00"
        label.textColor = .gray
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textAlignment = .right
        return label
    }()
    
    let toProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .yellow
        iv.layer.cornerRadius = 20
        return iv
    }()
    
    let toFullnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayLow()
        label.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        label.textAlignment = .right
        return label
    }()
    
    let arrowDown: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "arrow_down").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .gray
        return iv
    }()
    
    let optionButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dot_horizontal_option").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(previewOptionButton), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 5
        
        addSubview(fromProfileImageView)
        fromProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        addSubview(fromFullnameLabel)
        fromFullnameLabel.anchor(top: nil, left: fromProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        fromFullnameLabel.centerYAnchor.constraint(equalTo: fromProfileImageView.centerYAnchor).isActive = true
        
        addSubview(optionButtonView)
        optionButtonView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 30, height: 30)
        optionButtonView.centerYAnchor.constraint(equalTo: fromProfileImageView.centerYAnchor).isActive = true
        optionButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewOptionButton)))
        
        optionButtonView.addSubview(optionButton)
        optionButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        optionButton.centerYAnchor.constraint(equalTo: optionButtonView.centerYAnchor).isActive = true
        optionButton.centerXAnchor.constraint(equalTo: optionButtonView.centerXAnchor).isActive = true
        
        addSubview(arrowDown)
        arrowDown.anchor(top: fromProfileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 50)
        arrowDown.centerXAnchor.constraint(equalTo: fromProfileImageView.centerXAnchor).isActive = true
        
        addSubview(toProfileImageView)
        toProfileImageView.anchor(top: arrowDown.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        toProfileImageView.centerXAnchor.constraint(equalTo: arrowDown.centerXAnchor).isActive = true
        
        addSubview(toFullnameLabel)
        toFullnameLabel.anchor(top: nil, left: toProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        toFullnameLabel.centerYAnchor.constraint(equalTo: toProfileImageView.centerYAnchor).isActive = true
        
        addSubview(audioLengthLabel)
        audioLengthLabel.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        audioLengthLabel.centerYAnchor.constraint(equalTo: toProfileImageView.centerYAnchor).isActive = true
        
        addSubview(playButton)
        playButton.anchor(top: nil, left: nil, bottom: nil, right: audioLengthLabel.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 20)
//        playButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: toProfileImageView.centerYAnchor).isActive = true
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(previewAudio))
//        self.addGestureRecognizer(tap)
        
    }
    
    var goToListen : (() -> Void)?
    var optionButtonTapped : (() -> Void)?
    
    @objc func previewAudio() {
        goToListen!()    
    }
    
    @objc func previewOptionButton() {
        optionButtonTapped!()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
