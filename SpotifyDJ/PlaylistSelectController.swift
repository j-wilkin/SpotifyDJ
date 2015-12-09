//
//  PlaylistSelectController.swift
//  SpotifyDJ
//
//  Created by Jason Wilkin on 9/14/14.
//  Copyright (c) 2014 Jason Wilkin. All rights reserved.
//

import Foundation
import UIKit


class PlaylistSelectController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var playlistTable: UITableView!
    var session: SPTSession?
    var playlistNames: [String] = []
    var partialPlaylists: NSArray!
    
    let kCellIdentifier = "playlistCell"
    
    override func viewDidAppear(animated: Bool) {
        if session != nil {
        
            
            SPTRequest.playlistsForUserInSession(session, callback: { (error: NSError!, obj: AnyObject!) -> Void in
                if error != nil {
                    print("Error getting playlists \(error)")
                }
                
                let playlistList = obj as! SPTPlaylistList
                self.partialPlaylists =  playlistList.items

                for p in self.partialPlaylists {
                    self.playlistNames.append(p.name!)
                }
                self.playlistTable.reloadData()
            })
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let playListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("playlistView") as! PlaylistDetailController
        
        let partial = self.partialPlaylists[indexPath.row] as! SPTPartialPlaylist
        SPTRequest.requestItemFromPartialObject(partial, withSession: self.session) { (error: NSError!, metadata: AnyObject!) -> Void in
            playListVC.snapshot = metadata as! SPTPlaylistSnapshot
            playListVC.currentPage = playListVC.snapshot.firstTrackPage
            playListVC.partialPlaylist = partial
            playListVC.session = self.session
            self.navigationController?.pushViewController(playListVC, animated: true)
        }
        
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) {
            cell.textLabel!.text = self.playlistNames[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistNames.count
    }
    
    
    func handleNewSession(session: SPTSession) {
        self.session = session
    }
    
    
    
}