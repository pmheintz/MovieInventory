//
//  BarcodeAPI.swift
//  MovieInventory
//
//  Created by Paul Heintz on 4/18/18.
//  Copyright © 2018 Paul Heintz. All rights reserved.
//

import Foundation

struct BarcodeAPI {
    
    // For deployment
    private static let baseURLString = "https://www.barcodelookup.com/restapi"
    // For testing
    // private static let baseURLString = "https://www.markheintz.com/barcode.json"
    private static let key = "lkamc0f6gr1cf2r53mp0i0bpbkxl36"
    
    private static func barcodeURL() -> URL {
        var components = URLComponents(string: baseURLString)!
        
         var queryItems = [URLQueryItem]()
         let baseParams = [
         "key": key
         ]
         for (key, value) in baseParams {
         let item = URLQueryItem(name: key, value: value)
         queryItems.append(item)
         }
         components.queryItems = queryItems
        
        return components.url!
    }
    
    static var movieDetailsURL: URL {
        return barcodeURL()
    }
}
