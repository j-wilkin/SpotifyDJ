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
    var playlistSnapshots: NSArray!
    
    let kCellIdntifier = "playlistCell"
    
    override func viewDidLoad() {
        SPTRequest.playlistsForUserInSession(session, callback: { (error: NSError!, obj: AnyObject!) -> Void in
            if error != nil {
                println("Error getting playlists \(error)")
            }

            let snapshots = obj.items as NSArray
            self.playlistSnapshots = snapshots
            
            self.playlistNames = []
            for snap in snapshots {
                self.playlistNames.append(snap.name!)
            }
            println(self.playlistNames)
            self.playlistTable.reloadData()
        })

        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdntifier) as UITableViewCell
        cell.textLabel.text = self.playlistNames[indexPath.row]
        return cell
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