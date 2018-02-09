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
import AVFoundation

private let reuseIdentifier = "Cell"

class UserFeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let userFeedCell = "userFeedCell"
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? UserFeedLayout {
            layout.delegate = self
        }
        
        collectionView?.backgroundColor = .white
        tabBarController?.tabBar.isHidden = false
        
        collectionView?.register(UserFeedCell.self, forCellWithReuseIdentifier: userFeedCell)
        //        getAllAvents()
    }
    
    let url = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/all_events")!
    
    func videoSnapshot(filePathLocal: NSString) -> UIImage? {
        
        let vidURL = NSURL(string: filePathLocal as String)//NSURL(fileURLWithPath: filePathLocal as String)
        let asset = AVURLAsset(url: vidURL as! URL, options: nil)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    var selectedImage: UIImage?
    
    func getAllAvents() {
        
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
                
                if let JSON = response.result.value as? [[String: Any]] {
                    
                    for item in JSON {
                        
                        let event_url = item["event_url"] as! String
                        
                        print("\nitem: ", item)
                        
                        var image = UIImage()
                        let imageURL = URL(string: event_url)
                        
                        
                        print("Its a video and the video url is: ", event_url)
                        
                        self.videoUrl = URL(string: event_url)
                        
                        image = self.videoSnapshot(filePathLocal: event_url as NSString)!
                        
                        self.images.append(image)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }
    
    var videoUrl: URL?
    
    func dismissFullscreenImage() {
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        let imageView = (self.view.viewWithTag(100)! as! UIImageView)
        imageView.removeFromSuperview()
    }
    
    func addImageViewWithImage(image: UIImage, completion: () -> ()) {
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.frame = UIScreen.main.bounds
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        imageView.addGestureRecognizer(tap)
        self.view.addSubview(imageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        imageView.tag = 100
        
        completion()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        
        addImageViewWithImage(image: self.selectedImage!) {
            //            playVideo(url: videoUrl!)
        }
    }
    
    func playVideo(url: URL) {
        let videoURL = URL(string: (url.absoluteString))
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(playerLayer)//cell.layer.addSublayer(playerLayer)
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0//images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userFeedCell, for: indexPath) as! UserFeedCell
        
        //        cell.photoImageView.image = self.images[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
    
}

extension UserFeedController : UserFeedLayoutDelegate {
    
    // 1. Returns the photo height
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        return images[indexPath.item].size.height
    }
    
}


