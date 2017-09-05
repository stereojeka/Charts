//
//  Resource.swift
//  Charts
//
//  Created by Admin on 9/5/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

struct Resource<A> {
    var url: URL?
    var page: Int {
        didSet {
            self.url = composeUrlWith(self.page, self.method, self.country)
        }
    }
    var country: String? {
        didSet {
            self.url = composeUrlWith(self.page, self.method, country)
        }
    }
    let method: String
    let parse: (Data) -> A?
}

extension Resource {
    
    init(page: Int, method: String, country: String?, parseJSON: @escaping (Any) -> A?) {
        self.method = method
        self.page = page
        self.country = country
        self.url = URL(string: "https://ws.audioscrobbler.com/2.0/")!
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data as Data, options: [])
            return json.flatMap(parseJSON)
        }
        self.url = composeUrlWith(page, method, country)
    }
    
    init(url: URL, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.page = 1
        self.country = nil
        self.method = ""
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data as Data, options: [])
            return json.flatMap(parseJSON)
        }
    }
    
    func composeUrlWith(_ page: Int, _ method: String, _ country: String?) -> URL? {
        if var urlComponents = URLComponents(string: "https://ws.audioscrobbler.com/2.0/") {
            urlComponents.query = "method=\(method)&page=\(page)&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&format=json"
            if let country = country {
                urlComponents.query?.append("&country=\(country)")
            }
            return urlComponents.url!
        }
        return nil
    }
    
}
