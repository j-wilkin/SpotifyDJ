//
//  ViewController.swift
//  SpotifyDJ
//
//  Created by Jason Wilkin on 8/4/14.
//  Copyright (c) 2014 Jason Wilkin. All rights reserved.
//

import UIKit

class NowPlayingController: UIViewController {
    
    
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
            playbackToggleButton.titleLabel?.text = "Play"
        } else {
            GlobalPlayer.sharedInstance.setIsPlaying(true, callback: { (error: NSError!) -> Void in
                if error != nil {
                    // Something went wrong
                }
            })
            playbackToggleButton.titleLabel?.text = "Pause"
        }
    }
    
    
    func setNowPlayingInfo() {
        if let currentTrack = GlobalPlayer.sharedInstance.[SPTAudioStreamingMetadataTrackName] as? String
            artistLabel.text = currentTrack[SPTAudioStreamingMetadataArtistName] as? String
            albumLabel.text = currentTrack[SPTAudioStreamingMetadataAlbumName] as? String
            
            GlobalPlayer.sharedInstance.
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    

}

