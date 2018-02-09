//
//  photoLibraryViewController.swift
//  ReputationApp
//
//  Created by Omar Torres on 5/10/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Photos
import Alamofire
import Locksmith

class VideoLibraryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let photoCaption: UITextView = {
        let tv = UITextView()
        return tv
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        return button
    }()
    
    let cellId = "cellId"
    let videoHeaderId = "videoHeaderId"
    
    var selectedVideo: UIImage?
    var videos = [UIImage]()
    var videoAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        collectionView?.backgroundColor = .white
        
        setupNavigationButtons()
        
        collectionView?.register(VideoLibraryContentCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(VideoLibraryContentHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: videoHeaderId)
        
        fetchVideos()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedVideo = videos[indexPath.item]
        
        self.collectionView?.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchVideos() {
        
        let allVideos = PHAsset.fetchAssets(with: .video, options: self.assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            
            allVideos.enumerateObjects({ (asset, count, stop) in
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        self.videos.append(image)
                        self.videoAssets.append(asset)
                        
                        if self.selectedVideo == nil {
                            self.selectedVideo = image
                        }
                    }
                    
                    if count == allVideos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            })
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func playVideo(header: UICollectionViewCell, url: URL) {
        let videoURL = URL(string: (url.absoluteString))
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = header.contentView.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        header.layer.addSublayer(playerLayer)
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: videoHeaderId, for: indexPath) as! VideoLibraryContentHeader
        
        header.photoImageView.image = selectedVideo
        
        if let selectedVideo = selectedVideo {
            if let index = self.videos.index(of: selectedVideo) {
                let selectedAsset = self.videoAssets[index]
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                
                DispatchQueue.global(qos: .background).async {
                    
                    imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil, resultHandler: { (image, info) in
                        
                        header.photoImageView.image = image
                        
                        imageManager.requestAVAsset(forVideo: selectedAsset, options: .none) { (avAsset, avAudioMix, dict) -> Void in
                            if avAsset != nil {
                                let url = avAsset?.value(forKeyPath: "URL") as! URL
                                self.videoUrl = url
                                self.playVideo(header: header, url: url)
                                
                            }
                        }
                    })
                }
            }
        }
        
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoLibraryContentCell
        
        cell.photoImageView.image = videos[indexPath.item]
        
        return cell
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func handleNext() {
        view.addSubview(photoCaption)
        photoCaption.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 100)
        photoCaption.alpha = 0
        
        view.addSubview(shareButton)
        shareButton.anchor(top: photoCaption.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 20, height: 20)
        
        shareButton.addTarget(self, action: #selector(sendEvent), for: .touchUpInside)
        
        shareButton.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseIn, animations: {
            
            self.photoCaption.alpha = 1
            self.shareButton.alpha = 1
            
        }) { (succes) in
            print("success")
        }
        
    }
    
    var videoUrl: URL?
    
    func sendEvent() {
        // Retreieve Auth_Token from Keychain
        if let userToken = Locksmith.loadDataForUserAccount(userAccount: "AuthToken") {
            
            let authToken = userToken["authenticationToken"] as! String
            
            print("the current user token: \(userToken)")
            
            guard let caption = photoCaption.text else { return }
            
            // Set Authorization header
            let header = ["Authorization": "Token token=\(authToken)"]
            
            let parameters = ["description": caption] as [String : Any]
            
            let url = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/writeEvent")!
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                multipartFormData.append(self.videoUrl!, withName: "video", fileName: ".mp4", mimeType: "video/mp4")
                
                for (key, value) in parameters {
                    multipartFormData.append(((value as Any) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
                
            }, usingThreshold: UInt64.init() , to: url, method: .post, headers: header, encodingCompletion: { encodingResult in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        print("request: \(response.request!)") // original URL request
                        print("response: \(response.response!)") // URL response
                        print("response data: \(response.data!)") // server data
                        print("result: \(response.result)") // result of response serialization
                        
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                        }
                    }
                    
                case .failure(let encodingError):
                    print("Alamofire proccess failed", encodingError)
                }
            })
            
        } else {
            print("Impossible retrieve token")
        }
        
    }
}
