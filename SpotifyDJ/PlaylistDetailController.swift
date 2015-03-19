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
    var player: SPTAudioStreamingController!
    
    var currentTrackIndex: NSIndexPath?
    
    let kCellIdentifier = "trackCell"
    
    
    override func viewDidLoad() {
        
        self.trackTable.reloadData()
        self.createPlayer()

    }
    
    func createPlayer() {
        self.player = SPTAudioStreamingController()
        self.player.playbackDelegate = self
        
        self.player.loginWithSession(self.session!, callback: { (error: NSError!) -> Void in
            if error != nil {
                println("Playback error: \(error.localizedDescription)")
            }
        })
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.player.isPlaying {
            self.player.setIsPlaying(false, callback: nil)
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.currentTrackIndex != nil && self.currentTrackIndex == indexPath) {
                self.player.setIsPlaying(false, callback: nil)
                self.currentTrackIndex = nil
        } else {
            let track = self.currentPage.items[indexPath.row] as SPTPlaylistTrack
            self.player.playURI(track.playableUri, callback: nil)
            self.currentTrackIndex = indexPath

        }
        tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        let partialTrack = self.currentPage.items[indexPath.row] as SPTPartialTrack
        SPTRequest.requestItemFromPartialObject(partialTrack, withSession: self.session) { (error: NSError!, fullObj: AnyObject!) -> Void in
            var fullTrack = fullObj as SPTTrack
            
        }
        
        cell.textLabel!.text = partialTrack.name
        return cell

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