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
            loginURL = auth.loginURLForClientId(kClientId, declaredRedirectURL: NSURL(string: kCallbackURL), scopes: [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope], withResponseType: "token")
        } else {
            loginURL = auth.loginURLForClientId(kClientId, declaredRedirectURL: NSURL(string: kCallbackURL), scopes: [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope])
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
    



}

