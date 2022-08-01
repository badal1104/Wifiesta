//
//  ArtistModel.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 28/01/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import Foundation

// MARK: -
// MARK: - WiFinder ArtistModel
struct ArtistModel: Codable { // Itunes Media Searcher response model
    let results: [ArtistSearchPayload]?
}
struct ArtistSearchPayload: Codable {
    let artworkUrl100, artistName, trackName, longDescription, previewUrl: String?
}


