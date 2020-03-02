//
//  PlayerViewController.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 30/01/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import UIKit
import AVKit
class PlayerViewController: UIViewController {

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    var artistModel: ArtistSearchPayload?
    var mediaType: String?
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAndPlayAVPlayer() // Load AVPlayer
        setDescriptionText() // Load longDescription
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseSongOnBackground), name: UIApplication.didEnterBackgroundNotification, object: nil) // Add Background notification observer
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)// Remove Background notification observer
    }
    
    @objc func pauseSongOnBackground() { // Pause AVPlayer when app goes to background
        if let avPlayer = player{
            avPlayer.pause()
        }
    }
    
    func createAndPlayAVPlayer() { // Create AVPlayer instance and play preview url
        if let previewUrlString = artistModel?.previewUrl, !previewUrlString.isEmpty{
            if let previewUrl = URL(string: previewUrlString){
                player = AVPlayer(url: previewUrl)
                let playerFrame = playerView.frame
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                playerViewController.view.frame = CGRect(x: 0, y: 0, width: playerFrame.width, height: playerFrame.height)
                player?.play()
                addChild(playerViewController)
                playerView.addSubview(playerViewController.view)
                playerViewController.didMove(toParent: self)
            }else{
                createImageViewOnCorruptPreviewUrl() // load when previewUrl is corrupt
            }
        }else{
            createImageViewOnCorruptPreviewUrl() // load when previewUrl is corrupt
        }
    }
    
    func createImageViewOnCorruptPreviewUrl() { // method to show corrupt imageview
        let corruptPreviewImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: playerView.frame.height))
        corruptPreviewImageView.image = UIImage(named: "corruptImage")
        corruptPreviewImageView.contentMode = .scaleAspectFit
        playerView.addSubview(corruptPreviewImageView)
    }
    
    func setDescriptionText() { // check and set longDescription text
        var descriptionText = ""
        if mediaType == MediaContentType.Music.rawValue{
            descriptionText = (artistModel?.artistName ?? "") + " - " + (artistModel?.trackName ?? "")
        }else{
            descriptionText = artistModel?.longDescription ?? ""
        }
        descriptionTextView.text = descriptionText
    }
}
