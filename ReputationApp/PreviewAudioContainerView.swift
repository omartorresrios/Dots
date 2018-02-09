//
//  PreviewAudioContainerView.swift
//  ReputationApp
//
//  Created by Omar Torres on 31/12/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class PreviewAudioContainerView: UIView {
    
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textAlignment = .left
        return label
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 25 / 2
        return iv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "play")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
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
    
    let optionButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "dot_horizontal_option").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.mainGreen()
        progress.tintColor = .white
        progress.trackTintColor = .white
        return progress
    }()
    
    lazy var audioSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .gray
        slider.setThumbImage(UIImage(named: "thumb"), for: UIControlState())
        //        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        
        return slider
    }()
    
    let audioLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0:00"
        label.textColor = .white
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textAlignment = .right
        return label
    }()
    
    func setupViews() {
        
        backgroundColor = UIColor.grayLow()
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        
        addSubview(fullnameLabel)
        fullnameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        fullnameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(playButton)
        playButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        playButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        addSubview(optionButton)
        optionButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 15, height: 15)
        optionButton.centerYAnchor.constraint(equalTo: fullnameLabel.centerYAnchor).isActive = true
        
        addSubview(progressView)
        progressView.anchor(top: nil, left: playButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        progressView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        
        addSubview(audioLengthLabel)
        audioLengthLabel.anchor(top: nil, left: progressView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        audioLengthLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        
    }
    
    //    func handleSliderChange() {
    //        print(audioSlider.value)
    //
    //        if let duration = player?.currentItem?.duration {
    //            let totalSeconds = CMTimeGetSeconds(duration)
    //
    //            let value = Float64(audioSlider.value) * totalSeconds
    //
    //            let seekTime = CMTime(value: Int64(value), timescale: 1)
    //
    //            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
    //                //perhaps do something later here
    //            })
    //        }
    //    }
    
    var playOrPauseAudioAction : ((_ view: PreviewAudioContainerView, _ progressView: UIProgressView) -> Void)?
    
    func playAudio() {
        playOrPauseAudioAction?(self, progressView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
