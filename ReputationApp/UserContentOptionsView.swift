//
//  UserContentOptionsView.swift
//  ReputationApp
//
//  Created by Omar Torres on 30/01/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import Foundation
import UIKit

class UserContentOptionsView: UIView {
    
    let storiesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textColor = UIColor.grayLow()
        label.text = "Momentos"
        label.textAlignment = .left
        return label
    }()
    
    let reviewsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textColor = UIColor.grayLow()
        label.text = "Reseñas"
        label.textAlignment = .left
        return label
    }()
    
    let writeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textColor = UIColor.grayLow()
        label.text = "Deja una reseña"
        label.textAlignment = .left
        return label
    }()
    
    let blockLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textColor = UIColor.grayLow()
        label.text = "Bloquear"
        label.textAlignment = .left
        return label
    }()
    
    let viewGeneral = UIView()
    let viewSupport = UIView()
    let viewContainer = UIView()
    
    let storiesViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    let reviewsViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    let writeReviewViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    let blockUserViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    func setupViews() {
        
        addSubview(self.viewGeneral)
        self.viewGeneral.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.viewGeneral.backgroundColor = UIColor.grayHigh()
        
        viewSupport.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.viewGeneral.addSubview(self.viewSupport)
            self.viewSupport.anchor(top: nil, left: self.viewGeneral.leftAnchor, bottom: nil, right: self.viewGeneral.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 220)
            self.viewSupport.backgroundColor = UIColor.grayLow()
            self.viewSupport.centerYAnchor.constraint(equalTo: self.viewGeneral.centerYAnchor).isActive = true
            self.viewSupport.transform = .identity
        }, completion: nil)
        
        viewSupport.addSubview(viewContainer)
        viewContainer.anchor(top: viewSupport.topAnchor, left: viewSupport.leftAnchor, bottom: nil, right: viewSupport.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        viewContainer.backgroundColor = .white
        viewContainer.layer.cornerRadius = 5
        
        viewContainer.addSubview(storiesViewContainer)
        storiesViewContainer.anchor(top: viewContainer.topAnchor, left: viewContainer.leftAnchor, bottom: nil, right: viewContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150 / 3)
        
        let storiesEmojiView = UIImageView()
        let storiesEmoji = "🍻".image()
        storiesEmojiView.image = storiesEmoji
        
        storiesViewContainer.addSubview(storiesEmojiView)
        storiesViewContainer.addSubview(storiesLabel)
        storiesEmojiView.anchor(top: nil, left: storiesViewContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        storiesEmojiView.isUserInteractionEnabled = true
        storiesEmojiView.centerYAnchor.constraint(equalTo: storiesViewContainer.centerYAnchor).isActive = true
        
        storiesLabel.anchor(top: nil, left: storiesEmojiView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        storiesLabel.isUserInteractionEnabled = true
        storiesLabel.centerYAnchor.constraint(equalTo: storiesEmojiView.centerYAnchor).isActive = true
        
        
        viewContainer.addSubview(reviewsViewContainer)
        reviewsViewContainer.anchor(top: storiesViewContainer.bottomAnchor, left: viewContainer.leftAnchor, bottom: nil, right: viewContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150 / 3)
        
        let reviewsEmojiView = UIImageView()
        let reviewsEmoji = "👏".image()
        reviewsEmojiView.image = reviewsEmoji
        
        reviewsViewContainer.addSubview(reviewsEmojiView)
        reviewsViewContainer.addSubview(reviewsLabel)
        reviewsEmojiView.anchor(top: nil, left: reviewsViewContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        reviewsEmojiView.centerYAnchor.constraint(equalTo: reviewsViewContainer.centerYAnchor).isActive = true
        
        reviewsLabel.anchor(top: nil, left: reviewsEmojiView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        reviewsLabel.centerYAnchor.constraint(equalTo: reviewsViewContainer.centerYAnchor).isActive = true
        
        
        
        viewContainer.addSubview(writeReviewViewContainer)
        writeReviewViewContainer.anchor(top: reviewsViewContainer.bottomAnchor, left: viewContainer.leftAnchor, bottom: nil, right: viewContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150 / 3)
        
        let writeEmojiView = UIImageView()
        let writeEmoji = "🗣".image()
        writeEmojiView.image = writeEmoji
        
        writeReviewViewContainer.addSubview(writeEmojiView)
        writeReviewViewContainer.addSubview(writeLabel)
        writeEmojiView.anchor(top: nil, left: writeReviewViewContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        writeEmojiView.centerYAnchor.constraint(equalTo: writeReviewViewContainer.centerYAnchor).isActive = true
        
        writeLabel.anchor(top: nil, left: writeEmojiView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        writeLabel.centerYAnchor.constraint(equalTo: writeEmojiView.centerYAnchor).isActive = true
        
        
        
        viewSupport.addSubview(blockUserViewContainer)
        blockUserViewContainer.anchor(top: viewContainer.bottomAnchor, left: viewSupport.leftAnchor, bottom: nil, right: viewSupport.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        blockUserViewContainer.layer.cornerRadius = 5
        
        let blockEmojiView = UIImageView()
        let blockEmoji = "🚫".image()
        blockEmojiView.image = blockEmoji
        
        blockUserViewContainer.addSubview(blockEmojiView)
        blockUserViewContainer.addSubview(blockLabel)
        blockEmojiView.anchor(top: nil, left: blockUserViewContainer.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        blockEmojiView.centerYAnchor.constraint(equalTo: blockUserViewContainer.centerYAnchor).isActive = true
        
        blockLabel.anchor(top: nil, left: blockEmojiView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        blockLabel.centerYAnchor.constraint(equalTo: blockEmojiView.centerYAnchor).isActive = true
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
