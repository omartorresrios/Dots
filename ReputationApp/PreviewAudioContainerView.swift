//
//  PreviewAudioContainerView.swift
//  ReputationApp
//
//  Created by Omar Torres on 31/12/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class PreviewAudioContainerView: UIViewController {
    
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
        button.setImage(image, for: UIControl.State())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        return button
    }()
    
    var playing: Bool = false {
        willSet {
            if newValue != playing {
                if newValue {
                    playButton.setImage(UIImage(named: "pause"), for: UIControl.State())
                } else {
                    playButton.setImage(UIImage(named: "play"), for: UIControl.State())
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
        slider.setThumbImage(UIImage(named: "thumb"), for: UIControl.State())
        //        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        
        return slider
    }()
    
    let closeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor.mainGreen()
        return view
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "down_arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
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
    
    let suportView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.grayLow()
        return view
    }()
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.grayHigh()
        
        view.addSubview(closeView)
        closeView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 30, height: 30)
        closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeViewController)))
        
        closeView.addSubview(closeButton)
        closeButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        closeButton.centerXAnchor.constraint(equalTo: closeView.centerXAnchor).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: closeView.centerYAnchor).isActive = true
        closeButton.addTarget(self, action: #selector(closeViewController), for: .touchUpInside)
        
        view.addSubview(suportView)
        let height: CGFloat = 25 + 44
        suportView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: height)
        suportView.layer.cornerRadius = 5
        suportView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        suportView.addSubview(profileImageView)
        profileImageView.anchor(top: suportView.topAnchor, left: suportView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        
        suportView.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        fullnameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        suportView.addSubview(playButton)
        playButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        playButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        suportView.addSubview(optionButton)
        optionButton.anchor(top: nil, left: nil, bottom: nil, right: suportView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 15, height: 15)
        optionButton.centerYAnchor.constraint(equalTo: fullnameLabel.centerYAnchor).isActive = true
        
        suportView.addSubview(progressView)
        progressView.anchor(top: nil, left: playButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        progressView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        
        suportView.addSubview(audioLengthLabel)
        audioLengthLabel.anchor(top: nil, left: progressView.rightAnchor, bottom: nil, right: suportView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        audioLengthLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        
    }
    
    @objc func closeViewController() {
        self.dismiss(animated: true, completion: nil)
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
    
    @objc func playAudio() {
        playOrPauseAudioAction?(self, progressView)
    }
}
