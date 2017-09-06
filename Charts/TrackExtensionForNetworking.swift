//
//  TrackExtensionForNetworking.swift
//  Charts
//
//  Created by Admin on 9/5/17.
//  Copyright © 2017 Admin. All rights reserved.
//
import UIKit

typealias JSONArray = [[String: Any]]
typealias JSONDictionary = [String: AnyObject]

extension Track {
    init?(dictionary: JSONDictionary) {
        guard let name = dictionary["name"] as? String,
            let artistDict = dictionary["artist"] as? JSONDictionary,
            let artistName = artistDict["name"] as? String,
            let imageArray = dictionary["image"] as? JSONArray,
            let smallImage = imageArray[0]["#text"] as? String,
            let largeImage = imageArray[2]["#text"] as? String else { return nil }
        self.name = name
        self.artist = artistName
        self.image = smallImage
        self.largeImage = largeImage
        self.albumId = ""
        self.listeners = 0
        self.playcount = 0
        self.duration = 0
        self.tags = []
    }
    
    init?(fullInfoDictionary: JSONDictionary) {
        guard let name = fullInfoDictionary["name"] as? String,
            let artistDict = fullInfoDictionary["artist"] as? JSONDictionary,
            let artistName = artistDict["name"] as? String,
            let listeners = fullInfoDictionary["listeners"] as? String,
            let playCount = fullInfoDictionary["playcount"] as? String,
            let topTags = fullInfoDictionary["toptags"] as? JSONDictionary,
            let tagArray = topTags["tag"] as? JSONArray else { return nil }
        let tagsResult: [String] = tagArray.flatMap { tag in tag["name"] as? String }
        
        self.name = name
        self.artist = artistName
        self.image = ""
        self.largeImage = ""
        self.albumId = ""
        self.listeners = Int(listeners)!
        self.playcount = Int(playCount)!
        self.duration = 0
        self.tags = tagsResult
        
        if let albumDictionary = fullInfoDictionary["album"] as? JSONDictionary,
            let albumId = albumDictionary["mbid"] as? String,
            let images = albumDictionary["image"] as? JSONArray,
            let largeImage = images[2]["#text"] as? String {
            
            self.albumId = albumId
            self.image = largeImage
            self.largeImage = largeImage
        }
        
    }
    
    init?(trackFromAlbum: JSONDictionary, image: String, artist: String, albumId: String) {
        guard let name = trackFromAlbum["name"] as? String,
            let duration = trackFromAlbum["duration"] as? String else { return nil }
        self.name = name
        self.artist = artist
        self.image = image
        self.largeImage = image
        self.albumId = albumId
        self.listeners = 0
        self.playcount = 0
        self.duration = Int(duration)!
        self.tags = []
    }
    
    static var topWorld = Resource<[Track]>(page: 1, method: "chart.gettoptracks", country: nil, parseJSON: { json in
        guard let result = json as? JSONDictionary,
            let tracks = result["tracks"] as? JSONDictionary,
            let arrayOfTracks = tracks["track"] as? [JSONDictionary] else { return nil }
        return arrayOfTracks.flatMap(Track.init(dictionary:))
    })
    
    static var localTop = Resource<[Track]>(page: 1, method: "geo.gettoptracks", country: "United States", parseJSON: { json in
        guard let result = json as? JSONDictionary,
            let tracks = result["tracks"] as? JSONDictionary,
            let arrayOfTracks = tracks["track"] as? [JSONDictionary] else { return nil }
        return arrayOfTracks.flatMap(Track.init(dictionary:))
    })
    
    var singleTrack: Resource<Track>? {
        if var urlComponents = URLComponents(string: "https://ws.audioscrobbler.com/2.0/") {
            urlComponents.query = "method=track.getInfo&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&artist=\(self.artist)&track=\(self.name)&format=json"
            return Resource<Track>(url: urlComponents.url!, parseJSON: { json in
                guard let result = json as? JSONDictionary,
                    let track = result["track"] as? JSONDictionary else { return nil }
                return Track.init(fullInfoDictionary: track)
            })
        } else {
            return nil
        }
    }
    
    var albumTrackList: Resource<[Track]>? {
        if var urlComponents = URLComponents(string: "https://ws.audioscrobbler.com/2.0/") {
            urlComponents.query = "method=album.getinfo&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&mbid=\(self.albumId)&format=json"
            return Resource<[Track]>(url: urlComponents.url!, parseJSON: { json in
                guard let result = json as? JSONDictionary,
                    let albumDictionary = result["album"] as? JSONDictionary,
                    let albumId = albumDictionary["mbid"] as? String,
                    let imagesArray = albumDictionary["image"] as? JSONArray,
                    let largeImage = imagesArray[2]["#text"] as? String,
                    let artistName = albumDictionary["artist"] as? String,
                    let tracksDictionary = albumDictionary["tracks"] as? JSONDictionary,
                    let tracksArray = tracksDictionary["track"] as? JSONArray else { return nil }
                
                return tracksArray.flatMap { Track.init(trackFromAlbum: $0 as JSONDictionary, image: largeImage, artist: artistName, albumId: albumId) }
            })
        } else {
            return nil
        }
    }
    
}
