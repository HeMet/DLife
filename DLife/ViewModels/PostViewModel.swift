//
//  EntryViewModel.swift
//  DLife
//
//  Created by Евгений Губин on 16.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import MVVMKit

class PostViewModel: BaseViewModel {
    
    var data = ObservableArray<AnyObject>()
    
    var currentEntry: EntryViewModel {
        didSet {
            onEntryChanged?()
            loadComments()
        }
    }
    
    var comments: ObservableArray<DLComment> = []
    
    var onEntryChanged: (() -> ())?
    var onAlert: (String -> ())?
    
    private let api = DevsLifeAPI()
    
    init(entry: DLEntry) {
        currentEntry = EntryViewModel(entry: entry)
        super.init()
    }
    
    func nextRandomPost() {
        api.getRandomEntry(handleApiResult)
    }
    
    func handleApiResult(result: ApiResult<DLEntry>) {
        switch result {
        case .OK(let entry):
            currentEntry = EntryViewModel(entry: entry)
        case .Error(let error):
            print(error)
            onAlert?("Не удалось загрузить запись.")
        }
    }
    
    func loadComments() {
        api.getComments(currentEntry.entry.id) { [unowned self] result in
            switch result {
            case .OK(let comments):
                self.comments.replaceAll(comments)
            case .Error(let error):
                print(error)
            }
        }
    }
    
    func showPost(id: String) {
        api.getEntry(id, callback: handleApiResult)
    }
}