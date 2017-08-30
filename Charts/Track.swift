//
//  Track.swift
//  Charts
//
//  Created by Admin on 8/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

class Track {
    
    let name: String
    let artist: String
    let image: String
    let largeImage: String
    let albumId: String
    let listeners: Int
    let playcount: Int
    let duration: Int
    let tags: [String]
    
    init(name: String, artist: String, image: String="", largeImage: String="", albumId: String="", listeners: Int=0, playcount: Int=0, tags: [String]=[], duration: Int=0) {
        self.name = name
        self.artist = artist
        self.image = image
        self.listeners = listeners
        self.playcount = playcount
        self.tags = tags
        self.albumId = albumId
        self.duration = duration
        self.largeImage = largeImage
    }
    
}
