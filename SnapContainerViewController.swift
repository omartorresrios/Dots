//
//  ContainerViewController.swift
//  SnapchatSwipeView
//
//  Created by Jake Spracher on 8/9/15.
//  Copyright (c) 2015 Jake Spracher. All rights reserved.
//

import UIKit

protocol SnapContainerViewControllerDelegate {
    func outerScrollViewShouldScroll() -> Bool
}

class SnapContainerViewController: UIViewController, UIScrollViewDelegate {
    
    var topVc: UIViewController?
    var leftVc: UIViewController!
    var middleVc: UIViewController!
    var rightVc: UIViewController!
    var bottomVc: UIViewController?
    
    var directionLockDisabled: Bool!
    
    var horizontalViews = [UIViewController]()
    var veritcalViews = [UIViewController]()
    
    var initialContentOffset = CGPoint() // scrollView initial offset
    var middleVertScrollVc: VerticalScrollViewController!
    var scrollView: UIScrollView!
    var delegate: SnapContainerViewControllerDelegate?
    
    class func containerViewWith(_ leftVC: UIViewController,
                                 middleVC: UIViewController,
                                 rightVC: UIViewController,
                                 directionLockDisabled: Bool?=false) -> SnapContainerViewController {
        let container = SnapContainerViewController()
        
        container.directionLockDisabled = directionLockDisabled
        
        container.leftVc = leftVC
        container.middleVc = middleVC
        container.rightVc = rightVC
        return container
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVerticalScrollView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCameraViewFromUserFeed), name: NSNotification.Name(rawValue: "GoToCameraViewFromUserFeedController"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCameraViewFromUserSearch), name: NSNotification.Name(rawValue: "GoToCameraViewFromUserSearchController"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showUserSearchFromCamera), name: NSNotification.Name(rawValue: "GoToSearchFromCameraView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showUserFeedFromCamera), name: NSNotification.Name(rawValue: "GoToFeedFromCameraView"), object: nil)
        
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "userLoggedIn") == nil {
            
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        setupHorizontalScrollView()
        
    }
    
    @objc func showUserSearchFromCamera() {
        let newOffset = CGPoint(x: 0, y: 0)
        scrollView.setContentOffset(newOffset, animated: true)
    }
    
    func showUserSearchFromMyProfile() {
        let newOffset = CGPoint(x: view.bounds.width, y: 0)
        scrollView.setContentOffset(newOffset, animated: true)
    }
    
    @objc func showUserFeedFromCamera() {
        let newOffset = CGPoint(x: view.bounds.width * 2, y: 0)
        scrollView.setContentOffset(newOffset, animated: true)
    }
    
    @objc func showCameraViewFromUserFeed() {
        let newOffset = CGPoint(x: view.bounds.width, y: 0)
        scrollView.setContentOffset(newOffset, animated: true)
    }
    
    @objc func showCameraViewFromUserSearch() {
        let newOffset = CGPoint(x: view.bounds.width, y: 0)
        scrollView.setContentOffset(newOffset, animated: true)
    }
    
    func setupVerticalScrollView() {
        middleVertScrollVc = VerticalScrollViewController.verticalScrollVcWith(middleVc: middleVc, topVc: topVc, bottomVc: bottomVc)
        delegate = middleVertScrollVc
    }
    
    func setupHorizontalScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )

        scrollView.frame = CGRect(x: view.x,
                                  y: view.y,
                                  width: view.width,
                                  height: view.height
        )
        
        self.view.addSubview(scrollView)
        
        let scrollWidth  = 3 * view.width
        let scrollHeight  = view.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        
        leftVc.view.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.width,
                                   height: view.height
        )
        
        middleVertScrollVc.view.frame = CGRect(x: view.width,
                                               y: 0,
                                               width: view.width,
                                               height: view.height
        )
        
        rightVc.view.frame = CGRect(x: 2 * view.width,
                                    y: 0,
                                    width: view.width,
                                    height: view.height
        )
        
        addChildViewController(leftVc)
        addChildViewController(middleVertScrollVc)
        addChildViewController(rightVc)
        
        scrollView.addSubview(leftVc.view)
        scrollView.addSubview(middleVertScrollVc.view)
        scrollView.addSubview(rightVc.view)
        
        leftVc.didMove(toParentViewController: self)
        middleVertScrollVc.didMove(toParentViewController: self)
        rightVc.didMove(toParentViewController: self)
        
        scrollView.contentOffset.x = middleVertScrollVc.view.frame.origin.x
        scrollView.delegate = self
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.initialContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if delegate != nil && !delegate!.outerScrollViewShouldScroll() && !directionLockDisabled {
            let newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
        
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
            self.scrollView!.setContentOffset(newOffset, animated:  false)
        }
    }
    
}
