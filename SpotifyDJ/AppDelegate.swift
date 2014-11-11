//
//  AppDelegate.swift
//  SpotifyDJ
//
//  Created by Jason Wilkin on 8/4/14.
//  Copyright (c) 2014 Jason Wilkin. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    let kClientId = "28080564c21241f895edb9b87fa85c4b"
    let kCallbackURL = "spotifydj://callback"
    //let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenSwapURL = ""
    let kTokenRefreshServiceURL = ""
    var trackPlayer: SPTAudioStreamingController?

    var session:SPTSession?
    var kSessionUserDefaultsKey = "SpotifySession"
    
    var player:SPTAudioStreamingController?
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    
    func enableAudioPlaybackWithSession(session: SPTSession){
        let sessionData: NSData = NSKeyedArchiver.archivedDataWithRootObject(session)
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(sessionData, forKey: kSessionUserDefaultsKey)
        userDefaults.synchronize()

        let nav = self.window?.rootViewController as UINavigationController
        
        let vc = nav.topViewController as PlaylistSelectController
        vc.handleNewSession(session)
    }
    
    func openLoginPage(){
        let auth = SPTAuth.defaultInstance()
        var loginURL: NSURL
        
        if kTokenSwapURL == "" {
            loginURL = auth.loginURLForClientId(kClientId, declaredRedirectURL: NSURL(string: kCallbackURL), scopes: [SPTAuthStreamingScope], withResponseType: "token")
        } else {
            loginURL = auth.loginURLForClientId(kClientId, declaredRedirectURL: NSURL(string: kCallbackURL), scopes: [SPTAuthStreamingScope])
        }
        delay(0.1) {
            UIApplication.sharedApplication().openURL(loginURL)
            return
        }
        
        
    }
    
    func renewTokenAndEnablePlayback() {
        let seshData: NSData? = NSUserDefaults.standardUserDefaults().objectForKey(kSessionUserDefaultsKey) as? NSData
        
        var session: SPTSession? = nil
        if seshData != nil {
            session = NSKeyedUnarchiver.unarchiveObjectWithData(seshData!) as? SPTSession
        }
        
        let auth = SPTAuth.defaultInstance()
        auth.renewSession(session, withServiceEndpointAtURL: NSURL(string: kTokenRefreshServiceURL)) { (error: NSError?, sesh: SPTSession?) -> Void in
            if error != nil {
                println("ERROR renewing session: \(error)")
                return
            }
            self.enableAudioPlaybackWithSession(sesh!)
        }
        
        
        
    }
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.

        let seshData: NSData? = NSUserDefaults.standardUserDefaults().objectForKey(kSessionUserDefaultsKey) as? NSData
        
        var session: SPTSession? = nil
        if seshData != nil {
            session = NSKeyedUnarchiver.unarchiveObjectWithData(seshData!) as? SPTSession
        }

        
        if (session != nil) {
            if session!.isValid() {
                self.enableAudioPlaybackWithSession(session!)

            } else {
                if kTokenRefreshServiceURL == "" { self.openLoginPage() }
                else { self.renewTokenAndEnablePlayback() }
            }
        } else {
            self.openLoginPage()
        }
        
    
        
        
        
//        var auth = SPTAuth.defaultInstance()
//        var loginURL = auth.loginURLForClientId(kClientId, declaredRedirectURL: NSURL(string: kCallbackURL), scopes: [SPTAuthStreamingScope])
//        
//        // Opening a URL in Safari close to application launch may trigger
//        // an iOS bug, so we wait a bit before doing so.
//        delay(0.1) {
//            application.openURL(loginURL)
//            return
//        }
        
        return true
    }

    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        // Ask SPTAuth if the URL given is a Spotify authentication callback
        if (SPTAuth.defaultInstance().canHandleURL(url, withDeclaredRedirectURL: NSURL(string:kCallbackURL))) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, tokenSwapServiceEndpointAtURL: NSURL(string: kTokenSwapURL), callback: { (error, session) -> Void in
                if (error != nil) {
                    println("*** Auth error: \(error)")
                    return
                }
                self.enableAudioPlaybackWithSession(session)
                //self.playUsingSession(session)
            })
            
            return true
        }
        
        return false
    }
    
    func playUsingSession(session:SPTSession) {
        // Create a new player if needed
        if (self.player == nil) {
            self.player = SPTAudioStreamingController()
        }
        self.player?.loginWithSession(session, callback: { (error) -> Void in
            if (error != nil) {
                println("*** Enabling playback got error: \(error)")
                return
            } else {
                
                // Sucesss! We can now play things
                
//                SPTRequest.requestItemAtURI(NSURL(string: "spotify:album:3vGtqTr5he9uQfusQWJ0oC"), withSession: session, callback: { (error, album) -> Void in
//                    if (error != nil) {
//                        println("*** Album lookup got error \(error)")
//                        return
//                    }
//                    self.player?.playTrackProvider(album as SPTAlbum, callback: nil)
//                    
//                })
            }
        })
        
    }
    
    
    
    
    
//    func applicationWillResignActive(application: UIApplication!) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    }
//
//    func applicationDidEnterBackground(application: UIApplication!) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//
//    func applicationWillEnterForeground(application: UIApplication!) {
//        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    }
//
//    func applicationDidBecomeActive(application: UIApplication!) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    }
//
//    func applicationWillTerminate(application: UIApplication!) {
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    }


}

