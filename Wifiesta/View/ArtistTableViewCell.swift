//
//  ArtistTableViewCell.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 28/01/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import UIKit
import AlamofireImage
class ArtistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var artistTrackNameLabel: UILabel!
    @IBOutlet weak var longDescriptionLabel: UILabel!
    @IBOutlet weak var movieContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutArtistCell()
        addImageViewGesture()
    }
    
    private func addImageViewGesture() { // Add image gesture to UIImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(tapGesture:)))
        tapGesture.cancelsTouchesInView = true
        artworkImageView.isUserInteractionEnabled = true
        artworkImageView.addGestureRecognizer(tapGesture)
    }
    
    private func layoutArtistCell() { // Set shadow to artist image
        DispatchQueue.main.async {
            self.artworkImageView.layer.shadowColor = UIColor.black.cgColor
            self.artworkImageView.layer.shadowOpacity = 0.8
            self.artworkImageView.layer.shadowRadius = 3.0
            self.artworkImageView.layer.shadowOffset = CGSize(width: 2.0, height: 5.0)
            self.movieContentView.layer.cornerRadius = 3
        }
    }
    
    func loadDataOnCell(artistModel: ArtistSearchPayload?, mediaContentType: String) {
        loadArtworkUrlImage(imageUrlString: artistModel?.artworkUrl100 ?? "") // Load artist artworkUrl
        loadArtistDetails(artistModel: artistModel, mediaContentType: mediaContentType) // Load artist info
    }
    
    func loadArtworkUrlImage(imageUrlString: String?) {
        if let imageUrl = imageUrlString, !imageUrl.isEmpty{
            if let url = URL(string: imageUrl){
                artworkImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "no_poster"))
            }else{
                artworkImageView.image =  UIImage(named: "no_poster") // load default image when url is corrupt
            }
        }else{
            artworkImageView.image =  UIImage(named: "no_poster") // load default image when url is corrupt
        }
    }
    
    func loadArtistDetails(artistModel: ArtistSearchPayload?, mediaContentType: String) { // Load artist info
        let trackName = artistModel?.trackName ?? ""
        let artistName = artistModel?.artistName ?? ""
        let longDescription = artistModel?.longDescription ?? ""
        if mediaContentType == MediaContentType.Music.rawValue { // Set TrackName, ArtistName & longDescription as per the mediaType
            artistTrackNameLabel.text = trackName
            longDescriptionLabel.text = artistName
        }else if mediaContentType == MediaContentType.TvShow.rawValue{
            artistTrackNameLabel.text = artistName
            longDescriptionLabel.text = longDescription
        }else{
            artistTrackNameLabel.text = trackName
            longDescriptionLabel.text = longDescription
        }
    }
    
    @objc func handleGesture(tapGesture: UITapGestureRecognizer) { // Gesture to show image bounce animation
        if let artworkImageView = tapGesture.view as? UIImageView{
            let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 0.5, y: 0.5);
            artworkImageView.transform = expandTransform
            UIView.animate(withDuration: 1,
                           delay:0.0,
                           usingSpringWithDamping:0.35,
                           initialSpringVelocity:0.4,
                           options: .curveEaseOut,
                           animations: {
                            artworkImageView.transform = CGAffineTransform(scaleX: 1, y: 1);
            }, completion: nil)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
