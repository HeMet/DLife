//
//  FeedsViewModel.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import MVVMKit
import ReactiveCocoa

class FeedViewModel: ViewModelWithID {
    let uniqueID = String.unique()
    
    var entries = ObservableArray<EntryViewModel>()
    var feedToken = FeedToken(category: .Latest, pageSize: 10)
    
    let category = MutableProperty<FeedCategory>(.Latest)
    
    init() {
        category.didSet { [unowned self] value in
            self.feedToken = FeedToken(category: value, pageSize: 10)
            self.loadEntries()
        }
    }
    
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
                    self.entries.appendContentsOf(newVMs)
                } else {
                    self.entries.replaceAll(newVMs)
                }
            case .Error(let error):
                print(error)
            }
        }
    }
    
    func loadFavorites() {
        if (!feedToken.isUsed) {
            let favs = FavoritesManager.sharedInstance.favorites.map(EntryViewModel.init)
            entries.replaceAll(favs)
            feedToken.next()
        }
    }
    
    func showEntryAtIndex(index: Int) {
        let entry = entries[index].entry
        GoTo.post(sender: !self)(PostViewModel(entry: entry))
    }
    
    func showAbout() {
        GoTo.about(sender: !self)(AboutViewModel())
    }
}