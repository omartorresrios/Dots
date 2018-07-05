//
//  UserFeedPreviewAudioContainerView.swift
//  ReputationApp
//
//  Created by Omar Torres on 13/03/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import UIKit

class UserFeedPreviewAudioContainerView: UIView, UIGestureRecognizerDelegate {

    var tap = UITapGestureRecognizer()
    
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
        button.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        return button
    }()
    
    let progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.mainGreen()
        progress.tintColor = .gray
        progress.trackTintColor = .gray
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
    
    var playing: Bool = false {
        willSet {
            if newValue != playing {
                if newValue {
                    playButton.setImage(UIImage(named: "pause"), for: UIControlState())
                } else {
                    playButton.setImage(UIImage(named: "play"), for: UIControlState())
                }
            }
        }
    }
    
    let arrowDown: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "arrow_down").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .gray
        return iv
    }()
    
    let suportView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0, alpha: 0.9)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.addGestureRecognizer(tap)
        tap.delegate = self
        
        addSubview(suportView)
        let height: CGFloat = 162
        suportView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: height)
        suportView.layer.cornerRadius = 5
        suportView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        suportView.addSubview(fromProfileImageView)
        fromProfileImageView.anchor(top: suportView.topAnchor, left: suportView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        suportView.addSubview(fromFullnameLabel)
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
        
        suportView.addSubview(arrowDown)
        arrowDown.anchor(top: fromProfileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 50)
        arrowDown.centerXAnchor.constraint(equalTo: fromProfileImageView.centerXAnchor).isActive = true
        
        suportView.addSubview(toProfileImageView)
        toProfileImageView.anchor(top: arrowDown.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        toProfileImageView.centerXAnchor.constraint(equalTo: fromProfileImageView.centerXAnchor).isActive = true
        
        suportView.addSubview(toFullnameLabel)
        toFullnameLabel.anchor(top: nil, left: toProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        toFullnameLabel.centerYAnchor.constraint(equalTo: toProfileImageView.centerYAnchor).isActive = true
        
        suportView.addSubview(playButton)
        playButton.anchor(top: nil, left: fromProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        playButton.centerYAnchor.constraint(equalTo: arrowDown.centerYAnchor).isActive = true
        
        suportView.addSubview(progressView)
        progressView.anchor(top: nil, left: playButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        progressView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        
        suportView.addSubview(audioLengthLabel)
        audioLengthLabel.anchor(top: nil, left: progressView.rightAnchor, bottom: nil, right: suportView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        audioLengthLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: suportView))! {
            return false
        }
        return true
    }
    
    @objc func dismissView() {
        viewTappedForDismiss!()
    }
    
    var playOrPauseAudioAction : ((_ view: UserFeedPreviewAudioContainerView, _ progressView: UIProgressView) -> Void)?
    var optionButtonTapped : (() -> Void)?
    var viewTappedForDismiss : (() -> Void)?
    
    @objc func playAudio() {
        playOrPauseAudioAction?(self, progressView)
    }
    
    @objc func previewOptionButton() {
        optionButtonTapped!()
    }

}
