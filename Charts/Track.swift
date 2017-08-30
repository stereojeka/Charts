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
    let albumId: String
    let listeners: String
    let playcount: String
    let releaseDate: String
    let duration: String
    let tags: [String]
    
    init(name: String, artist: String, image: String) {
        self.name = name
        self.artist = artist
        self.image = image
        self.listeners = ""
        self.playcount = ""
        self.releaseDate = ""
        self.tags = []
        self.albumId = ""
        self.duration = ""
    }
    
    init(name: String, artist: String, duration: String) {
        self.name = name
        self.artist = artist
        self.image = ""
        self.listeners = ""
        self.playcount = ""
        self.releaseDate = ""
        self.tags = []
        self.albumId = ""
        self.duration = duration
    }
    
    init(name: String, artist: String, image: String, albumId: String, listeners: String, playcount: String, tags: [String]) {
        self.name = name
        self.artist = artist
        self.image = image
        self.listeners = listeners
        self.playcount = playcount
        self.releaseDate = ""
        self.tags = tags
        self.albumId = albumId
        self.duration = ""
    }
    
    init(name: String, artist: String, listeners: String, playcount: String, tags: [String]) {
        self.name = name
        self.artist = artist
        self.image = ""
        self.listeners = listeners
        self.playcount = playcount
        self.releaseDate = ""
        self.tags = tags
        self.albumId = ""
        self.duration = ""
    }
    
}
