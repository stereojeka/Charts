//
//  TrackInfoViewController.swift
//  Charts
//
//  Created by Admin on 8/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class TrackInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var listenedLabel: UILabel!
    @IBOutlet weak var listenersLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var trackListLabel: UILabel!
    @IBOutlet weak var trackListTable: UITableView!
    @IBOutlet weak var albumImage: UIImageView!
    
    private static let cellId = "trackListCell"
    
    private var trackService: TrackService!
    
    private var tracks: [Track] = []
    
    private var track: Track! {
        didSet {
            if !track.albumId.isEmpty {
                getAlbumTrackList()
            }
        }
    }
    
    var trackName: String = ""
    var artistName: String = ""

    func getAlbumTrackList() {
        if var urlComponents = URLComponents(string: "https://ws.audioscrobbler.com/2.0/") {
            urlComponents.query = "method=album.getinfo&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&artist=\(artistName)&album=\(trackName)&format=json"
            if let url = urlComponents.url {
                trackService.getTrackList(url) { [unowned self] result, image, errorMessage in
                    if let result = result {
                        self.tracks = result
                        self.trackListTable.reloadData()
                        self.showContent()
                        
                        self.albumImage.downloadedFrom(link: image)
                    }
                }
            }
        }
    }
    
    func showContent() {
        trackListLabel.isHidden = false
        trackListTable.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        trackService = TrackService.sharedTrackService
        
        trackListTable.register(AlbumTrackListCell.self, forCellReuseIdentifier: TrackInfoViewController.cellId)
        let xib = UINib(nibName: "AlbumTrackListCell", bundle: nil)
        trackListTable.register(xib, forCellReuseIdentifier: TrackInfoViewController.cellId)
        trackListTable.rowHeight = 60
        
        if var urlComponents = URLComponents(string: "https://ws.audioscrobbler.com/2.0/") {
            urlComponents.query = "method=track.getInfo&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&artist=\(artistName)&track=\(trackName)&format=json"
            if let url = urlComponents.url {
                trackService.getTrackInfo(url) { [unowned self] result, errorMessage in
                    if let result = result {
                        self.track = result
                        self.artistLabel.text! += self.track.artist
                        self.listenedLabel.text! += self.track.playcount
                        self.listenersLabel.text! += self.track.listeners
                        for tag in self.track.tags {
                            self.tagsLabel.text! += tag + " | "
                        }
                    }
                }
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackListCell", for: indexPath) as! AlbumTrackListCell
        
        cell.trackName.text = tracks[indexPath.row].name
        cell.trackDuration.text = getDurationText(Int(tracks[indexPath.row].duration)!)
        
        return cell
    }
    
    func getDurationText(_ data: Int) -> String {
        let minutes: Int = data / 60
        let seconds: Int = data - minutes * 60
        return seconds < 10 ? "\(minutes):0\(seconds)" : "\(minutes):\(seconds)"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowTrackInfo", sender: tableView.cellForRow(at: indexPath))
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = trackListTable.indexPath(for: sender as! UITableViewCell)!
        let infoVC = segue.destination as! TrackInfoViewController
        infoVC.navigationItem.title = self.tracks[indexPath.row].name
        infoVC.trackName = self.tracks[indexPath.row].name
        infoVC.artistName = self.tracks[indexPath.row].artist
    }

}