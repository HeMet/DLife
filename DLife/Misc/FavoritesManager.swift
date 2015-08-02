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
        let docDir = paths[0] as! String
        return docDir + "/" + FAVORITES_FOLDER
    }
    
    private var favoritesStorage: String {
        return favoritesFolder + "/" + FAVORITES_STORAGE
    }
    
    func ensureFavoritesFolder() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = paths[0] as! String
        let favDir = docDir + "/" + FAVORITES_FOLDER
        
        println(favDir)
        
        let fm = NSFileManager()
        if !fm.fileExistsAtPath(favDir) {
            println("create fav dir")
            var error: NSError? = nil
            fm.createDirectoryAtPath(favDir, withIntermediateDirectories: true, attributes: nil, error: &error)
            if let error = error {
                println("Cann't create favorites directory: \(error)")
            }
        }
    }
    
    func loadFavorites() -> [DLEntry] {
        let fm = NSFileManager()
        if fm.fileExistsAtPath(favoritesStorage) {
            if let data = NSData(contentsOfFile: favoritesStorage) {
                var error: NSError? = nil
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [[String: AnyObject]] {
                    return (json ).map { DLEntry(json: $0) }
                } else {
                    println("deserialization error: \(error)")
                }
            } else {
                println("error while reading favorites")
            }
        }
        
        return []
    }
    
    func saveFovorites() {
        let favs = favorites.map { $0.toJson() }
        
        var error: NSError? = nil
        let json = NSJSONSerialization.dataWithJSONObject(favs, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
        
        if let json = json {
            json.writeToFile(favoritesStorage, options: NSDataWritingOptions.allZeros, error: &error)
            
            if let error = error {
                println("writing error: \(error)")
            }
        } else {
            println("Error while serializing to json: \(error)")
        }
    }
    
    func add(entry: DLEntry) {
        if find(favorites, entry) == nil {
            favorites.append(entry)
        }
    }
    
    func remove(entry: DLEntry) {
        if let index = find(favorites, entry) {
            favorites.removeAtIndex(index)
        }
    }
    
    func isFavorite(entry: DLEntry) -> Bool {
        return contains(favorites, entry)
    }
}