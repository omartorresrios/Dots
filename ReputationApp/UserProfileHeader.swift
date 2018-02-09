//
//  UserProfileHeader.swift
//  ReputationApp
//
//  Created by Omar Torres on 31/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class UserProfileHeader: UICollectionViewCell {
    
    var user: User? {
        didSet {
            //            guard let profileImageUrl = user?.profileImageUrl else { return }
            //            profileImageView.loadImage(urlString: profileImageUrl)
            //
            //            fullnameLabel.text = user?.fullname
            
            //            setupAttributedUserData()
            
            //            if user?.isValidated == true {
            addSubview(verifiedImage)
            verifiedImage.anchor(top: profileImageView.topAnchor, left: nil, bottom: nil, right: profileImageView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 20, height: 20)
            //            }
            
        }
    }
    
    //    fileprivate func setupAttributedUserData() {
    //        guard let reviewsText = user?.reviewsCount else { return }
    //        guard let numbersFont = UIFont(name: "SFUIDisplay-Semibold", size: 14) else { return }
    //        guard let normalFont = UIFont(name: "SFUIDisplay-Regular", size: 14) else { return }
    //
    //        let attributedReview = NSMutableAttributedString(string: "\(reviewsText)", attributes: [NSFontAttributeName: numbersFont])
    //
    //        if user?.reviewsCount == 1 {
    //            attributedReview.append(NSAttributedString(string: " reseña", attributes: [NSFontAttributeName: normalFont]))
    //        } else {
    //            attributedReview.append(NSAttributedString(string: " reseñas", attributes: [NSFontAttributeName: normalFont]))
    //        }
    //
    //        reviewsLabel.attributedText = attributedReview
    //
    //        guard let pointsText = user?.points else { return }
    //
    //        let attributedPoint = NSMutableAttributedString(string: "\(pointsText)", attributes: [NSFontAttributeName: numbersFont])
    //
    //        if user?.points == 1 || user?.points == -1 {
    //            attributedPoint.append(NSAttributedString(string: " punto", attributes: [NSFontAttributeName: normalFont]))
    //        } else {
    //            attributedPoint.append(NSAttributedString(string: " puntos", attributes: [NSFontAttributeName: normalFont]))
    //        }
    //
    //        pointsLabel.attributedText = attributedPoint
    //
    //    }
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 100 / 2
        iv.clipsToBounds = true
        return iv
    }()
    
    let verifiedImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "isVerified")
        return image
    }()
    
    lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 20)
        label.textAlignment = .left
        return label
    }()
    
    let reviewsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let pointsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var writeReviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dejar reseña", for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 15)
        button.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(writeReview), for: .touchUpInside)
        return button
    }()
    
    let topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let messageView: UIView = {
        let view = UIView()
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 14)
        label.textAlignment = .center
        label.text = "Reseñas"
        return label
    }()
    
    let underlinedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow
        return view
    }()
    
    let backView: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "back_button")
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let arrowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let arrowImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = #imageLiteral(resourceName: "down_arrow").withRenderingMode(.alwaysTemplate)
        return image
    }()
    
    func writeReview() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToWriteCV"), object: nil)
    }
    
    func handleReturn() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToSearchFromProfile"), object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backView)
        
        backView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 18, height: 18)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleReturn))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
        
        addSubview(arrowView)
        arrowView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 18, height: 18)
        arrowView.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        
        arrowView.addSubview(arrowImage)
        arrowImage.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 13, height: 13)
        arrowImage.centerXAnchor.constraint(equalTo: arrowView.centerXAnchor).isActive = true
        arrowImage.centerYAnchor.constraint(equalTo: arrowView.centerYAnchor).isActive = true
        arrowImage.tintColor = UIColor(white: 0.4, alpha: 1)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: backView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 100, height: 100)
        
        addSubview(fullnameLabel)
        fullnameLabel.anchor(top: profileImageView.topAnchor, left: backView.leftAnchor, bottom: nil, right: profileImageView.leftAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        addSubview(reviewsLabel)
        
        reviewsLabel.anchor(top: fullnameLabel.bottomAnchor, left: backView.leftAnchor, bottom: nil, right: profileImageView.leftAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        addSubview(pointsLabel)
        
        pointsLabel.anchor(top: reviewsLabel.bottomAnchor, left: backView.leftAnchor, bottom: nil, right: profileImageView.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        addSubview(writeReviewButton)
        
        writeReviewButton.anchor(top: profileImageView.bottomAnchor, left: backView.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 20, paddingRight: 12, width: 0, height: 40)
        writeReviewButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        addSubview(topSeparatorView)
        
        topSeparatorView.anchor(top: writeReviewButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        addSubview(messageLabel)
        
        messageLabel.anchor(top: topSeparatorView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        addSubview(bottomSeparatorView)
        bottomSeparatorView.anchor(top: messageLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    func verifiedMessage(tapGestureRecognizer: UITapGestureRecognizer) {
        JDStatusBarNotification.show(withStatus: "Usuario verificado", dismissAfter: 2.0, styleName: JDStatusBarStyleDark)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

