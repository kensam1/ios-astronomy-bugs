//
//  MarsRoverClient.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MarsRoverClient {
    
    func fetchMarsRover(named name: String,
                        using session: URLSession = URLSession.shared,
                        completion: @escaping (MarsRover?, Error?) -> Void) {
        
        // What queue are we in? Most likely the main queue, unless we specify the queue.
        
        let url = self.url(forInfoForRover: name)
        
        // @escaping allows the completion closure to finish after "fetchingMarsRover"
        // Trailing closure syntax: allows us to ignore the label for the last parameter if its a closure. Anonymous function.
        fetch(from: url, using: session) { (dictionary: [String : MarsRover]?, error: Error?) in
            
            // Happening in another queue.
            guard let rover = dictionary?["photo_manifest"] else {
                completion(nil, error)
                return
            }
            completion(rover, nil)
        }
    }
    
    func fetchPhotos(from rover: MarsRover,
                     onSol sol: Int,
                     using session: URLSession = URLSession.shared,
                     completion: @escaping ([MarsPhotoReference]?, Error?) -> Void) {
        
        let url = self.url(forPhotosfromRover: rover.name, on: sol)
        fetch(from: url, using: session) { (dictionary: [String : [MarsPhotoReference]]?, error: Error?) in
            guard let photos = dictionary?["photos"] else {
                completion(nil, error)
                return
            }
            completion(photos, nil)
        }
    }
    
    // MARK: - Private
    
    private func fetch<T: Codable>(from url: URL,
                           using session: URLSession = URLSession.shared,
                           completion: @escaping (T?, Error?) -> Void) {
        
        // Anonymous function
        // Calling completion from inside "fetch": completiong(possiblySomethingCodable, possibleError)
        
        
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "com.LambdaSchool.Astronomy.ErrorDomain", code: -1, userInfo: nil))
                return
            }
            
            do {
                // what type is T? Dictionary<String, MarsRover>
                let jsonDecoder = MarsPhotoReference.jsonDecoder
                // Decoding: The root object in the JSON -> Dictionary.
                // What root objects can a valid JSON have? Array or dictionary
                // Steps:
                // 1. Going to Dictionary<String, MarsRover> and saying "Do you know how to decode a JSON dictionary with string keys? Yes
                // 2. Does Dictionary<String, MarsRover> know how to decode the rest of the JSON? No, but MarsRover can and has it own decoder. But the dictionary<String, MarsRover> can't handle snakeCase.
                // Dictionary<String, MarsRover> not part of MarsRover, so cant handle snakeCase.
                let decodedObject = try jsonDecoder.decode(T.self, from: data)
                completion(decodedObject, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    private let baseURL = URL(string: "https://api.nasa.gov/mars-photos/api/v1")!
    private let apiKey = "qzGsj0zsKk6CA9JZP1UjAbpQHabBfaPg2M5dGMB7"

    private func url(forInfoForRover roverName: String) -> URL {
        var url = baseURL
        url.appendPathComponent("manifests")
        url.appendPathComponent(roverName)
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        return urlComponents.url!
    }
    
    private func url(forPhotosfromRover roverName: String, on sol: Int) -> URL {
        var url = baseURL
        url.appendPathComponent("rovers")
        url.appendPathComponent(roverName)
        url.appendPathComponent("photos")
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "sol", value: String(sol)),
                                    URLQueryItem(name: "api_key", value: apiKey)]
        return urlComponents.url!
    }
}
