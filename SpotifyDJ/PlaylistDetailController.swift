//
//  PlaylistDetailController.swift
//  SpotifyDJ
//
//  Created by Jason Wilkin on 11/11/14.
//  Copyright (c) 2014 Jason Wilkin. All rights reserved.
//

import Foundation
import UIKit


class PlaylistDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate, SPTAudioStreamingPlaybackDelegate {
    
    
    @IBOutlet weak var trackTable: UITableView!
    var session: SPTSession?
    var tracks: AnyObject!
    var partialPlaylist: SPTPartialPlaylist!
    var snapshot: SPTPlaylistSnapshot!
    var currentPage: SPTListPage!
    
    var currentTrackIndex: NSIndexPath?
    
    let kCellIdentifier = "trackCell"
    
    
    override func viewDidLoad() {
        
        self.trackTable.reloadData()
        self.createPlayer()

    }
    
    func createPlayer() {
        GlobalPlayer.sharedInstance.playbackDelegate = self
        GlobalPlayer.sharedInstance.loginWithSession(self.session!, callback: { (error: NSError!) -> Void in
            if error != nil {
                print("Playback error: \(error.localizedDescription)")
            }
        })
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.currentTrackIndex != nil && self.currentTrackIndex == indexPath) {
                GlobalPlayer.sharedInstance.setIsPlaying(false, callback: nil)
                self.currentTrackIndex = nil
        } else {
            let track = self.currentPage.items[indexPath.row] as! SPTPlaylistTrack
            GlobalPlayer.sharedInstance.playURI(track.playableUri, callback: nil)
            self.currentTrackIndex = indexPath

        }
        tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) {
            let partialTrack = self.currentPage.items[indexPath.row] as! SPTPartialTrack
            cell.textLabel!.text = partialTrack.name
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(self.snapshot.trackCount)
    }
    
    
    func handleNewSession(session: SPTSession) {
        self.session = session
    }
    
    
    
}