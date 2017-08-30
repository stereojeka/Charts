//
//  TrackTableViewCell.swift
//  Charts
//
//  Created by Admin on 8/30/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet weak var trackImageView: UIImageView!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    fileprivate var dataTask: URLSessionDataTask?
    
    var track: Track? {
        didSet {
            updateContents()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
         dataTask?.cancel()
    }
    
    func updateContents() {
        guard let thisTrack = track else {
            return
        }
        
        trackNameLabel.text = thisTrack.name
        artistNameLabel.text = thisTrack.artist
        loadImage(url: URL(string: thisTrack.image)!)
    }
    
    func loadImage(url: URL) {
        dataTask?.cancel()
        dataTask = URLSession.shared.dataTask(with: url) { [ weak self ] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self?.trackImageView.image = image
            }
        }
        dataTask?.resume()
    }
    
}
