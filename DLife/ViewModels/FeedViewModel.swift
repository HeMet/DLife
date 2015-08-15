//
//  FeedsViewModel.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import MVVMKit

class FeedViewModel: ViewModel {
    var entries = ObservableArray<EntryViewModel>()
    var feedToken = FeedToken(category: .Latest, pageSize: 10)
    var category = FeedCategory.Latest {
        didSet {
            feedToken = FeedToken(category: category, pageSize: 10)
            loadEntries()
        }
    }
    
    var onDisposed: ViewModelEventHandler?
    
    func loadEntries() {
        if feedToken.category == .Favorite {
            loadFavorites()
        } else {
            loadFromServer()
        }
    }
    
    func loadFromServer() {
        let api = DevsLifeAPI()
        let append = feedToken.isUsed
        api.getEntries(feedToken) { result in
            switch result {
            case .OK(let entries):
                let newVMs = entries.map { EntryViewModel(entry: $0) }
                if append {
                    self.entries.extend(newVMs)
                } else {
                    self.entries.replaceAll(newVMs)
                }
                self.onDataChanged?()
            case .Error(let error):
                print(error)
            }
        }
    }
    
    func loadFavorites() {
        if (!feedToken.isUsed) {
            let favs = FavoritesManager.sharedInstance.favorites.map { EntryViewModel(entry: $0) }
            entries.replaceAll(favs)
            feedToken.next()
        }
    }
    
    func showEntryAtIndex(index: Int) {
        let entry = entries[index].entry
        GoTo.post(sender: self)(PostViewModel(entry: entry))
    }
    
    func showAbout() {
        GoTo.about(sender: self)(AboutViewModel())
    }
    
    func dispose() {
        onDisposed?(self)
    }
    
    var onDataChanged: (() -> ())?
}