//
//  EntryViewModel.swift
//  DLife
//
//  Created by Евгений Губин on 28.07.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

class EntryViewModel: BaseViewModel {
    let entry: DLEntry
    
    init(entry: DLEntry) {
        self.entry = entry
    }
    
    var isFavorite: Bool {
        get {
            return FavoritesManager.sharedInstance.isFavorite(entry)
        }
        set {
            if newValue {
                FavoritesManager.sharedInstance.add(entry)
            } else {
                FavoritesManager.sharedInstance.remove(entry)
            }
            onFavoriteChanged?()
        }
    }
    
    var onFavoriteChanged: (() -> ())?
    
    func toggleFavorite() {
        isFavorite = !isFavorite
    }
}