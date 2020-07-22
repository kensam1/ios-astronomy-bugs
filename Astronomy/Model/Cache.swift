//
//  PhotoCache.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class Cache<Key: Hashable, Value> {
    
    func cache(value: Value, for key: Key) {
        serialQueue.async { // default is async
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        // value is returning, whatever sync is returning
        // when we are returning something use sync
        // return serialQueue.sync
        serialQueue.sync {
            return cache[key]
        }
    
    }
    
    private let serialQueue = DispatchQueue(label: "Cache Serial Queue")
    
    private var cache = [Key : Value]()
}
