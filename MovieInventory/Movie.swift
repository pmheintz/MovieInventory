//
//  Movie.swift
//  MovieInventory
//
//  Created by Paul Heintz on 5/2/18.
//  Copyright © 2018 Paul Heintz. All rights reserved.
//

import Foundation

class Movie: NSObject, NSCoding {
    //MARK: Properties
    
    var barcode: String
    var title: String
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("movies")
    
    //MARK: Types
    
    struct PropertyKey {
        static let barcode = "barcode"
        static let title = "title"
    }
    
    //MARK: Initialization
    
    init?(barcode: String, title: String) {
        // The barcode must not be empty
        guard !barcode.isEmpty else {
            return nil
        }
        // The title must not be empty
        guard !title.isEmpty else {
            return nil
        }
        
        self.barcode = barcode
        self.title = title
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(barcode, forKey: PropertyKey.barcode)
        aCoder.encode(title, forKey: PropertyKey.title)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The barcode is required. If we cannot decode a barcode string, the initializer should fail.
        guard let barcode = aDecoder.decodeObject(forKey: PropertyKey.barcode) as? String else {
            print("Unable to decode the barcode for a Movie object.")
            return nil
        }
        
        // The title is required. If we cannot decode a title string, the initializer should fail.
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            print("Unable to decode the title for a Movie object.")
            return nil
        }
        
        // Must call designated initializer.
        self.init(barcode: barcode, title: title)
    }
}
