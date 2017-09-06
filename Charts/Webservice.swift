//
//  Webservice.swift
//  Charts
//
//  Created by Admin on 9/4/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import UIKit

final class Webservice {
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        dataTask?.cancel()
        dataTask = defaultSession.dataTask(with: resource.url!) { data, response, error in
            defer { self.dataTask = nil }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let result: A?
            if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                result = resource.parse(data)
            } else {
                result = nil
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
        dataTask?.resume()
    }
    
}



























