//
//  UserFeedController.swift
//  ReputationApp
//
//  Created by Omar Torres on 17/10/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith
import AVKit
import AudioBot
import AVFoundation

private let reuseIdentifier = "Cell"

class UserFeedController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    let userFeedCell = "userFeedCell"
    var reviewsAll = [ReviewAll]()
    var reviewSelected: ReviewAll!
    var images = [UIImage]()
    var collectionView: UICollectionView!
    var sheetController = UIAlertController()
    var tap = UITapGestureRecognizer()
    var isFrom: Bool!
    var userFullnameSelected: String!
    let userContentOptionsView = UserContentOptionsView()
    let url = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/all_reviews")!
    var selectedImage: UIImage?
    let userFeedPreviewAudioContainerView = UserFeedPreviewAudioContainerView()
    
    let userFeedControllerImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "dots_logo_feed")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let searchingReviewsLabel: UILabel = {
        let ml = UILabel()
        ml.text = "buscando reseñas..."
        ml.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        ml.textColor = UIColor.grayLow()
        ml.numberOfLines = 1
        ml.textAlignment = .center
        return ml
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.alpha = 1.0
        indicator.startAnimating()
        return indicator
    }()
    
    let cameraViewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "camera").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.mainGreen()
        button.addTarget(self, action: #selector(goToCamera), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTopButtons()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: view.frame.width - 16, height: 162)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UserFeedCell.self, forCellWithReuseIdentifier: userFeedCell)
        collectionView.backgroundColor = UIColor.rgb(red: 238, green: 238, blue: 238)
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 61, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        navigationController?.navigationBar.isHidden = true
        
        collectionView.addSubview(loader)
        loader.anchor(top: collectionView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        loader.startAnimating()
        loader.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        
        collectionView.addSubview(searchingReviewsLabel)
        searchingReviewsLabel.anchor(top: loader.bottomAnchor, left: collectionView.leftAnchor, bottom: nil, right: collectionView.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        searchingReviewsLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        
        getAllReviews()
        
    }
    
    func setupNavigationTopButtons() {
        view.addSubview(userFeedControllerImage)
        userFeedControllerImage.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 28, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        userFeedControllerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(cameraViewButton)
        cameraViewButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 28, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
    }
    
    func getAllReviews() {
        
        // Retreieve Auth_Token from Keychain
        if let userToken = Locksmith.loadDataForUserAccount(userAccount: "AuthToken") {
            
            let authToken = userToken["authenticationToken"] as! String
            
            print("the current user token: \(userToken)")
            
            // Set Authorization header
            let header = ["Authorization": "Token token=\(authToken)"]
            
            Alamofire.request(url, headers: header).responseJSON { response in
                
                print("request: \(response.request!)") // original URL request
                print("response: \(response.response!)") // URL response
                print("response data: \(response.data!)") // server data
                print("result: \(response.result)") // result of response serialization
                
                switch response.result {
                case .success(let JSON):
                    print("THE ALL_REVIEWS JSON: \(JSON)")
                    
                    let jsonArray = JSON as! NSDictionary
                    
                    let dataArray = jsonArray["reviews"] as! NSArray
                    
                    dataArray.forEach({ (value) in
                        guard let reviewDictionary = value as? [String: Any] else { return }
                        print("this is reviewDictionary: \(reviewDictionary)")
                        
                        let review = ReviewAll(reviewDictionary: reviewDictionary)
                        
                        self.reviewsAll.append(review)
                        
                    })
                    
                    self.reviewsAll.sort(by: { (p1, p2) -> Bool in
                        return p1.createdAt?.compare(p2.createdAt!) == .orderedDescending
                    })
                    
                    self.collectionView.reloadData()
                    
                    self.loader.stopAnimating()
                    self.searchingReviewsLabel.removeFromSuperview()
                    
                case .failure(let error):
                    print(error)
                }
                
            }
        }
    }
    
    func setupReviewInfoViews() {
        view.addSubview(userFeedPreviewAudioContainerView)
        userFeedPreviewAudioContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func goToCamera() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToCameraViewFromUserFeedController"), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewsAll.count
    }

    func handleReportContentoptions() {
        sheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sheetController.addAction(UIAlertAction(title: "Reportar", style: .destructive, handler: { (_) in
            let alert = UIAlertController(title: "", message: "Revisaremos tu reporte 🤔", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "¡Gracias!", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        sheetController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        
        present(sheetController, animated: true, completion: nil)
        
    }
    
    @objc func showFromUserProfile(sender: UIGestureRecognizer) {
        isFrom = true
        let position = sender.location(in: collectionView)
        guard let index = collectionView.indexPathForItem(at: position) else {
            print("Error, label not in collectionView")
            return
        }
        let review = reviewsAll[index.item]
        reviewSelected = review
        
        guard let userIdFromKeyChain = Locksmith.loadDataForUserAccount(userAccount: "currentUserId") else { return }
        let userId = userIdFromKeyChain["id"] as! Int
        
        if review.fromId != userId {
            setupUserInfoViewsContainers()
        }
    }
    
    @objc func showToUserProfile(sender: UIGestureRecognizer) {
        isFrom = false
        let position = sender.location(in: collectionView)
        guard let index = collectionView.indexPathForItem(at: position) else {
            print("Error, label not in collectionView")
            return
        }
        let review = reviewsAll[index.item]
        reviewSelected = review
        
        guard let userIdFromKeyChain = Locksmith.loadDataForUserAccount(userAccount: "currentUserId") else { return }
        let userId = userIdFromKeyChain["id"] as! Int
        
        if review.toId != userId {
            setupUserInfoViewsContainers()
        }
    }
    
    @objc func showUserReviewsView() {
        let userReviewsController = UserReviewsController(collectionViewLayout: UICollectionViewFlowLayout())
        
        if isFrom == true {
            userReviewsController.userId = reviewSelected.fromId
            userReviewsController.userFullname = reviewSelected.fromFullname
            userReviewsController.userImageUrl = reviewSelected.fromAvatarUrl
        } else {
            userReviewsController.userId = reviewSelected.toId
            userReviewsController.userFullname = reviewSelected.toFullname
            userReviewsController.userImageUrl = reviewSelected.toAvatarUrl
        }
        
        present(userReviewsController, animated: true, completion: nil)
        
//        // Tracking each time user tap reviewsViewContainer
//        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
//        Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
//        Mixpanel.mainInstance().track(event: "Pressed reviewsViewContainer")
    }
    
    @objc func showWriteReviewView() {
        let writeReviewController = WriteReviewController()
        
        if isFrom == true {
            writeReviewController.userId = reviewSelected.fromId
            writeReviewController.userFullname = reviewSelected.fromFullname
            writeReviewController.userImageUrl = reviewSelected.fromAvatarUrl
        } else {
            writeReviewController.userId = reviewSelected.toId
            writeReviewController.userFullname = reviewSelected.toFullname
            writeReviewController.userImageUrl = reviewSelected.toAvatarUrl
        }
        
        present(writeReviewController, animated: true, completion: nil)
        
//        // Tracking each time user tap writeReviewViewContainer
//        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
//        Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
//        Mixpanel.mainInstance().track(event: "Pressed writeReviewViewContainer")
    }
    
    @objc func blockUserView() {
        if isFrom == true {
            userFullnameSelected = reviewSelected.fromFullname
        } else {
            userFullnameSelected = reviewSelected.toFullname
        }
        
        let alert = UIAlertController(title: "", message: "Bloqueaste a \(userFullnameSelected!)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissContainerView() {
        userContentOptionsView.removeFromSuperview()
        userContentOptionsView.viewGeneral.removeGestureRecognizer(tap)
    }
    
    func setupUserInfoViewsContainers() {
        
        userContentOptionsView.viewSupport.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            self.view.addSubview(self.userContentOptionsView)
            self.userContentOptionsView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            //            let storiesTap = UITapGestureRecognizer(target: self, action: #selector(self.showUserStoriesView))
            //            self.userContentOptionsView.storiesViewContainer.addGestureRecognizer(storiesTap)
            
            let reviewsTap = UITapGestureRecognizer(target: self, action: #selector(self.showUserReviewsView))
            self.userContentOptionsView.reviewsViewContainer.addGestureRecognizer(reviewsTap)
            //
            //            self.userContentOptionsView.reviewsViewContainer.layoutIfNeeded()
            //            self.userContentOptionsView.reviewsViewContainer.layer.addBorder(edge: .top, color: .gray, thickness: 1)
            
            self.userContentOptionsView.writeReviewViewContainer.layoutIfNeeded()
            self.userContentOptionsView.writeReviewViewContainer.layer.addBorder(edge: .top, color: .gray, thickness: 1)
            
            let writeTap = UITapGestureRecognizer(target: self, action: #selector(self.showWriteReviewView))
            self.userContentOptionsView.writeReviewViewContainer.addGestureRecognizer(writeTap)
            
            let blockTap = UITapGestureRecognizer(target: self, action: #selector(self.blockUserView))
            self.userContentOptionsView.blockUserViewContainer.addGestureRecognizer(blockTap)
            
            self.tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissContainerView))
            self.userContentOptionsView.viewGeneral.addGestureRecognizer(self.tap)
            self.tap.delegate = self
            
            self.userContentOptionsView.viewSupport.transform = .identity
            
        }, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userFeedCell, for: indexPath) as! UserFeedCell
        cell.review = reviewsAll[indexPath.item]
        var audioReview = reviewsAll[indexPath.item]
        
        cell.optionButtonTapped = {
            self.handleReportContentoptions()
        }
        
        cell.fromProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFromUserProfile(sender:))))
        cell.fromProfileImageView.isUserInteractionEnabled = true
        
        cell.toProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showToUserProfile(sender:))))
        cell.toProfileImageView.isUserInteractionEnabled = true
        
        cell.fromFullnameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFromUserProfile(sender:))))
        cell.fromFullnameLabel.isUserInteractionEnabled = true
        
        cell.toFullnameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showToUserProfile(sender:))))
        cell.toFullnameLabel.isUserInteractionEnabled = true
        
        cell.goToListen = {
            
            // Check for internet connection
            //            if (reachability?.isReachable)! {
            
            UIApplication.shared.isStatusBarHidden = true
            
            self.setupReviewInfoViews()
            
            self.userFeedPreviewAudioContainerView.fromProfileImageView.loadImage(urlString: (cell.review?.fromAvatarUrl)!)
            self.userFeedPreviewAudioContainerView.fromFullnameLabel.text = cell.review?.fromFullname
            
            self.userFeedPreviewAudioContainerView.toProfileImageView.loadImage(urlString: (cell.review?.toAvatarUrl)!)
            self.userFeedPreviewAudioContainerView.toFullnameLabel.text = cell.review?.toFullname
            
            self.userFeedPreviewAudioContainerView.optionButtonTapped = {
                self.handleReportContentoptions()
            }
            
            self.userFeedPreviewAudioContainerView.viewTappedForDismiss = {
                self.userFeedPreviewAudioContainerView.removeFromSuperview()
                AudioBot.stopPlay()
                self.userFeedPreviewAudioContainerView.playing = false
                audioReview.playing = false
            }
            
            let duration = NSInteger(audioReview.duration)
            let seconds = String(format: "%02d", duration % 60)
            let minutes = (duration / 60) % 60
            
            self.userFeedPreviewAudioContainerView.audioLengthLabel.text = "\(minutes):\(seconds)"
            
            self.userFeedPreviewAudioContainerView.playOrPauseAudioAction = { [weak self] cell, progressView in
                func tryPlay() {
                    do {
                        AudioBot.reportPlayingDuration = { duration in
                            
                            let ti = NSInteger(duration)
                            
                            let seconds = String(format: "%02d", ti % 60)
                            let minutes = String(format: "%2d", (ti / 60) % 60)
                            
                            self?.userFeedPreviewAudioContainerView.audioLengthLabel.text = "\(minutes):\(seconds)"
                        }
                        let progressPeriodicReport: AudioBot.PeriodicReport = (reportingFrequency: 10, report: { progress in
                            print("progress: \(progress)")
                            audioReview.progress = CGFloat(progress)
                            progressView.progress = progress
                        })
                        
                        let fromTime = TimeInterval(audioReview.progress) * audioReview.duration
                        try AudioBot.startPlayAudioAtFileURL(audioReview.fileURL, fromTime: fromTime, withProgressPeriodicReport: progressPeriodicReport, finish: { success in
                            audioReview.playing = false
                            cell.playing = false
                        })
                        print("LET SEE: ", audioReview.fileURL)
                        audioReview.playing = true
                        cell.playing = true
                    } catch {
                        print("play error: \(error)")
                    }
                }
                if AudioBot.isPlaying {
                    AudioBot.pausePlay()
                    audioReview.playing = false
                    cell.playing = false
                    
                } else {
                    tryPlay()
                }
                
            }
            
        }

        return cell
    }
}
