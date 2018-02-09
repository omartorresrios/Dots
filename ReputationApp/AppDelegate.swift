//
//  AppDelegate.swift
//  ReputationApp
//
//  Created by Omar Torres on 10/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import JDStatusBarNotification
import GoogleSignIn
import Google

let reachability = Reachability()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability = Reachability()!
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url , sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do {
            try reachability.startNotifier()
        } catch{
            print("could not start reachability notifier")
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        logUser(forAppDelegate: true)
        
        return true
    }
    
    func logUser(forAppDelegate: Bool) {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "userLoggedIn") != nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let left = storyboard.instantiateViewController(withIdentifier: "left")
            let middle = storyboard.instantiateViewController(withIdentifier: "middle")
            let right = storyboard.instantiateViewController(withIdentifier: "right")
            
            let snapContainer = SnapContainerViewController.containerViewWith(left,
                                                                              middleVC: middle,
                                                                              rightVC: right)
            
            if forAppDelegate == true {
                self.window?.rootViewController = snapContainer
            } else {
                showViewControllerWith(newViewController: snapContainer, usingAnimation: AnimationType.ANIMATE_UP)
            }
            
            self.window?.makeKeyAndVisible()
            
        } else {
            let login = LoginController()
            self.window?.rootViewController = login
        }
    }
    
    //Declare enum
    enum AnimationType{
        case ANIMATE_RIGHT
        case ANIMATE_LEFT
        case ANIMATE_UP
        case ANIMATE_DOWN
    }
    // Create Function...
    
    func showViewControllerWith(newViewController:UIViewController, usingAnimation animationType:AnimationType)
    {
        
        let currentViewController = UIApplication.shared.delegate?.window??.rootViewController
        let width = currentViewController?.view.frame.size.width;
        let height = currentViewController?.view.frame.size.height;
        
        var previousFrame:CGRect?
        var nextFrame:CGRect?
        
        switch animationType
        {
        case .ANIMATE_LEFT:
            previousFrame = CGRect(x: width!-1, y: 0.0, width: width!, height: height!)
            nextFrame = CGRect(x: -width!, y: 0.0, width: width!, height: height!)
        case .ANIMATE_RIGHT:
            previousFrame = CGRect(x: -width!+1, y: 0.0, width: width!, height: height!)
            nextFrame = CGRect(x: width!, y: 0.0, width: width!, height: height!)
        case .ANIMATE_UP:
            previousFrame = CGRect(x: 0.0, y: height!-1, width: width!, height: height!)
            nextFrame = CGRect(x: 0.0, y: -height!+1, width: width!, height: height!)
        case .ANIMATE_DOWN:
            previousFrame = CGRect(x: 0.0, y: -height!+1, width: width!, height: height!)
            nextFrame = CGRect(x: 0.0, y: height!-1, width: width!, height: height!)
        }
        
        newViewController.view.frame = previousFrame!
        UIApplication.shared.delegate?.window??.addSubview(newViewController.view)
        UIView.animate(withDuration: 0.0,
                                   animations: { () -> Void in
                                    newViewController.view.frame = (currentViewController?.view.frame)!
                                    currentViewController?.view.frame = nextFrame!
                                    
        })
        { (fihish:Bool) -> Void in
            UIApplication.shared.delegate?.window??.rootViewController = newViewController
        }
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Network not reachable")
            JDStatusBarNotification.show(withStatus: "Revisa tu conexión e intenta de nuevo", dismissAfter: 3.0, styleName: JDStatusBarStyleDark)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

