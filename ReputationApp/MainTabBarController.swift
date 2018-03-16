//
//  MainTabBarController.swift
//  ReputationApp
//
//  Created by Omar Torres on 10/03/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isStatusBarHidden = false
        
//        tabBar.isHidden = true
        
        self.delegate = self
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "userLoggedIn") == nil {
            
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        setupViewControllers { (success) in
            print("setup success")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        tabBar.isHidden = false
    }
    
    func setupViewControllers(completion: @escaping _Callback) {
        
        // MyProfile
        let myProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "dots_logo"), selectedImage: #imageLiteral(resourceName: "dots_logo"), rootViewController: MyProfileController())
        
        // Ranking
        let layout = UICollectionViewFlowLayout()
        let userRankingController = UserSearchController()
        
        let userRankingNavController = UINavigationController(rootViewController: userRankingController)
        
        userRankingNavController.tabBarItem.image = #imageLiteral(resourceName: "dot")
        userRankingNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "dot")
        
        tabBar.tintColor = UIColor.mainBlue()
        
        viewControllers = [userRankingNavController, myProfileNavController]
        
        completion(true)
        
        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
