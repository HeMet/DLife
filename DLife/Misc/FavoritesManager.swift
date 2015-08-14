//
//  FavoritesManager.swift
//  DLife
//
//  Created by Евгений Губин on 26.07.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

class FavoritesManager {
    
    let FAVORITES_FOLDER = "Favorites"
    let FAVORITES_STORAGE = "favorites.json"
    
    static let sharedInstance = FavoritesManager()
    
    init() {
        ensureFavoritesFolder()
    }
    
    lazy private(set) var favorites: [DLEntry] = { [unowned self] in
        self.loadFavorites()
    }()
    
    private var favoritesFolder: String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = paths[0] 
        return docDir + "/" + FAVORITES_FOLDER
    }
    
    private var favoritesStorage: String {
        return favoritesFolder + "/" + FAVORITES_STORAGE
    }
    
    func ensureFavoritesFolder() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = paths[0] 
        let favDir = docDir + "/" + FAVORITES_FOLDER
        
        print(favDir)
        
        let fm = NSFileManager()
        if !fm.fileExistsAtPath(favDir) {
            print("create fav dir")
            var error: NSError? = nil
            do {
                try fm.createDirectoryAtPath(favDir, withIntermediateDirectories: true, attributes: nil)
            } catch let error1 as NSError {
                error = error1
            }
            if let error = error {
                print("Cann't create favorites directory: \(error)")
            }
        }
    }
    
    func loadFavorites() -> [DLEntry] {
        let fm = NSFileManager()
        if fm.fileExistsAtPath(favoritesStorage) {
            if let data = NSData(contentsOfFile: favoritesStorage) {
                let error: NSError? = nil
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [[String: AnyObject]] {
                    return (json ).map { DLEntry(json: $0) }
                } else {
                    print("deserialization error: \(error)")
                }
            } else {
                print("error while reading favorites")
            }
        }
        
        return []
    }
    
    func saveFovorites() {
        let favs = favorites.map { $0.toJson() }
        
        var error: NSError? = nil
        let json: NSData?
        do {
            json = try NSJSONSerialization.dataWithJSONObject(favs, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let error1 as NSError {
            error = error1
            json = nil
        }
        
        if let json = json {
            do {
                try json.writeToFile(favoritesStorage, options: NSDataWritingOptions())
            } catch let error1 as NSError {
                error = error1
            }
            
            if let error = error {
                print("writing error: \(error)")
            }
        } else {
            print("Error while serializing to json: \(error)")
        }
    }
    
    func add(entry: DLEntry) {
        if favorites.indexOf(entry) == nil {
            favorites.append(entry)
        }
    }
    
    func remove(entry: DLEntry) {
        if let index = favorites.indexOf(entry) {
            favorites.removeAtIndex(index)
        }
    }
    
    func isFavorite(entry: DLEntry) -> Bool {
        return favorites.contains(entry)
    }
}