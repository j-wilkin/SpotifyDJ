//
//  ViewController.swift
//  SpotifyDJ
//
//  Created by Jason Wilkin on 8/4/14.
//  Copyright (c) 2014 Jason Wilkin. All rights reserved.
//

import UIKit

class NowPlayingController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var albumLabel: UILabel!
    
    @IBOutlet weak var artworkImageView: UIImageView!
    
    @IBOutlet weak var playbackToggleButton: UIButton!
    
    @IBAction func togglePlayback(sender: AnyObject) {
        if GlobalPlayer.sharedInstance.isPlaying {
            GlobalPlayer.sharedInstance.setIsPlaying(false, callback: { (error: NSError!) -> Void in
                if error != nil {
                    // Something went wrong
                }
            })
            playbackToggleButton.setTitle("Play", forState: .Normal)
        } else {
            GlobalPlayer.sharedInstance.setIsPlaying(true, callback: { (error: NSError!) -> Void in
                if error != nil {
                    // Something went wrong
                }
            })
            playbackToggleButton.setTitle("Pause", forState: .Normal)
        }
    }
    
    var session: SPTSession?
    
    func setNowPlayingInfo(trackMetadata: [NSObject : AnyObject]!) {
        artistLabel.text = trackMetadata[SPTAudioStreamingMetadataArtistName] as? String
        albumLabel.text = trackMetadata[SPTAudioStreamingMetadataAlbumName] as? String
        songLabel.text = trackMetadata[SPTAudioStreamingMetadataTrackName] as? String
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.playbackToggleButton.setTitle("Pause", forState: .Normal)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        setNowPlayingInfo(trackMetadata)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
            setNowPlayingInfo(GlobalPlayer.sharedInstance.currentTrackMetadata)
        }
    }

}

