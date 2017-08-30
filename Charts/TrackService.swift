//
//  TrackService.swift
//  Charts
//
//  Created by Admin on 8/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import UIKit

final class TrackService {
    
    static let sharedTrackService = TrackService()
    
    typealias JSONArray = [[String: Any]]
    typealias JSONDictionary = [String: Any]
    typealias TracksResult = ([Track]?, Int, Int, String) -> ()
    typealias TrackListResult = ([Track]?, String, String) -> ()
    typealias SingleTrackResult = (Track?, String) -> ()
    
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    enum UrlUsage {
        case topWorld(Int)
        case topCountry(Int, String)
        case singleTrack(String, String)
        case trackList(String)
    }
    
    fileprivate func getUrlBy(usage: UrlUsage) -> URL? {
        if var urlComponents = URLComponents(string: "https://ws.audioscrobbler.com/2.0/") {
            switch usage {
            case .topWorld(let page):
                urlComponents.query = "method=chart.gettoptracks&page=\(page)&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&format=json"
                if let url = urlComponents.url {
                    return url
                }
            case .topCountry(let page, let country):
                urlComponents.query = "method=geo.gettoptracks&page=\(page)&country=\(country)&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&format=json"
                if let url = urlComponents.url {
                    return url
                }
            case .singleTrack(let artist, let trackName):
                urlComponents.query = "method=track.getInfo&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&artist=\(artist)&track=\(trackName)&format=json"
                if let url = urlComponents.url {
                    return url
                }
            case .trackList(let albumId):
                urlComponents.query = "method=album.getinfo&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&mbid=\(albumId)&format=json"
                if let url = urlComponents.url {
                    return url
                }
            }
        }
        return nil
    }
    
    fileprivate func makeRequest(url: URL, onCompletion: @escaping (Data?, String) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        dataTask = defaultSession.dataTask(with: url) { [unowned self] data, response, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                onCompletion(data, self.errorMessage)
            } else {
                onCompletion(nil, self.errorMessage)
            }
        }
    }
    
    func getTopTracks(_ page: Int, _ country: String?, onCompletion: @escaping TracksResult) {
        dataTask?.cancel()
        var url: URL
        if let country = country {
            url = getUrlBy(usage: UrlUsage.topCountry(page, country))!
        } else {
            url = getUrlBy(usage: UrlUsage.topWorld(page))!
        }
        makeRequest(url: url) { [unowned self] data, error in
            defer { self.dataTask = nil }
            if let data = data {
                let result = self.parseTracks(data)
                DispatchQueue.main.async {
                    onCompletion(result.tracks, result.pageIndex, result.totalPages, self.errorMessage)
                }
            } else {
                DispatchQueue.main.async {
                    onCompletion(nil, 0, 0, self.errorMessage)
                }
            }
        }
        dataTask?.resume()
    }
    
    func getTrackInfo(_ artist: String, _ trackName: String, onCompletion: @escaping SingleTrackResult) {
        dataTask?.cancel()
        if let url = getUrlBy(usage: UrlUsage.singleTrack(artist, trackName)) {
            makeRequest(url: url) { [unowned self] data, error in
                defer { self.dataTask = nil }
                if let data = data {
                    let result = self.parseSingleTrack(data)
                    DispatchQueue.main.async {
                        onCompletion(result, self.errorMessage)
                    }
                } else {
                    DispatchQueue.main.async {
                        onCompletion(nil, self.errorMessage)
                    }
                }
            }
        }
        dataTask?.resume()
    }
    
    func getTrackList(_ albumId: String, onCompletion: @escaping TrackListResult) {
        dataTask?.cancel()
        if let url = getUrlBy(usage: UrlUsage.trackList(albumId)) {
            makeRequest(url: url) { [unowned self] data, error in
                defer { self.dataTask = nil }
                if let data = data {
                    let result = self.parseTrackList(data)
                    DispatchQueue.main.async {
                        onCompletion(result.tracks, result.albumImage, self.errorMessage)
                    }
                } else {
                    DispatchQueue.main.async {
                        onCompletion(nil, "", self.errorMessage)
                    }
                }
            }
        }
        dataTask?.resume()
    }
    
    fileprivate func performSerialization(with data: Data) -> Any? {
        let result: Any?
        do {
            result = try JSONSerialization.jsonObject(with: data, options: [])
            return result!
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return nil
        }
        
    }
    
    fileprivate func parseTrackList(_ data: Data) -> (tracks: [Track]?, albumImage: String) {
        var result: [Track] = []
        var albumImage: String = ""
        
        if let response = performSerialization(with: data) as? JSONDictionary,
            let albumDictionary = response["album"] as? JSONDictionary,
            let imagesArray = albumDictionary["image"] as? JSONArray,
            let largeImage = imagesArray[2]["#text"] as? String,
            let artistName = albumDictionary["artist"] as? String,
            let tracksDictionary = albumDictionary["tracks"] as? JSONDictionary,
            let tracksArray = tracksDictionary["track"] as? JSONArray {
            
            albumImage = largeImage
            
            for track in tracksArray {
                if let name = track["name"] as? String,
                    let duration = track["duration"] as? String {
                    result.append(Track(name: name, artist: artistName, duration: Int(duration)!))
                }
            }
            
        }
        
        return result.isEmpty ? (nil, "") : (result, albumImage)
    }
    
    fileprivate func parseSingleTrack(_ data: Data) -> Track? {
        if let response = performSerialization(with: data) as? JSONDictionary,
            let trackDictionary = response["track"] as? JSONDictionary,
            let name = trackDictionary["name"] as? String,
            let artistDictionary = trackDictionary["artist"] as? JSONDictionary,
            let artistName = artistDictionary["name"] as? String,
            let listeners = trackDictionary["listeners"] as? String,
            let playCount = trackDictionary["playcount"] as? String,
            let topTags = trackDictionary["toptags"] as? JSONDictionary,
            let tagArray = topTags["tag"] as? JSONArray {
            
            let tagsResult: [String] = tagArray.flatMap { tag in tag["name"] as? String }
            
            if let albumDictionary = trackDictionary["album"] as? JSONDictionary,
                let albumId = albumDictionary["mbid"] as? String,
                let images = albumDictionary["image"] as? JSONArray,
                let largeImage = images[2]["#text"] as? String {
                
                return Track(name: name, artist: artistName, largeImage: largeImage, albumId: albumId, listeners: Int(listeners)!, playcount: Int(playCount)!, tags: tagsResult)
            } else {
                return Track(name: name, artist: artistName, listeners: Int(listeners)!, playcount: Int(playCount)!, tags: tagsResult)
            }
            
        }
        
        return nil
    }
    
    fileprivate func parseTracks(_ data: Data) -> (tracks: [Track]?, pageIndex: Int, totalPages: Int) {
        var result: [Track] = []
        var pageIndex = 0
        var totalPages = 0
        
        if let response = performSerialization(with: data) as? JSONDictionary,
            let tracksDictionary = response["tracks"] as? JSONDictionary,
            let tracksArray = tracksDictionary["track"] as? JSONArray,
            let attributesData = tracksDictionary["@attr"] as? JSONDictionary {
        
            let parsedAttributesData = parseAttributes(attributesData)
            pageIndex = parsedAttributesData.pageIndex
            totalPages = parsedAttributesData.totalPages
            
            for track in tracksArray {
                if let name = track["name"] as? String,
                    let artistDictionary = track["artist"] as? JSONDictionary,
                    let artistName = artistDictionary["name"] as? String,
                    let imageArray = track["image"] as? JSONArray,
                    let smallImage = imageArray[0]["#text"] as? String,
                    let largeImage = imageArray[2]["#text"] as? String {
                    result.append(Track(name: name, artist: artistName, image: smallImage, largeImage: largeImage))
                }
            }
            
        } else {
            errorMessage += "Problem parsing JSON\n"
        }
        return result.isEmpty ? (nil, pageIndex, totalPages) : (result, pageIndex, totalPages)
    }
    
    fileprivate func parseAttributes(_ data: JSONDictionary) -> (pageIndex: Int, totalPages: Int) {
        if let pageField = data["page"] as? String, let totalPagesField = data["totalPages"] as? String {
            return (Int(pageField)!, Int(totalPagesField)!)
        }
        return (0, 0)
    }
    
    
}
