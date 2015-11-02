//
//  EntryViewModel.swift
//  DLife
//
//  Created by Евгений Губин on 16.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import MVVMKit
import ReactiveCocoa

class PostViewModel: BaseViewModel {
    
    var comments: ObservableArray<DLComment> = []
    
    var currentEntry: MutableProperty<EntryViewModel>

    var onAlert: (String -> ())?
    
    private let api = DevsLifeAPI()
    
    init(entry: DLEntry) {
        currentEntry = MutableProperty(EntryViewModel(entry: entry))
        
        super.init()
        
        currentEntry.didSet { [unowned self] _ in
            self.loadComments()
        }
    }
    
    func nextRandomPost() {
        api.getRandomEntry(handleApiResult)
    }
    
    func handleApiResult(result: ApiResult<DLEntry>) {
        switch result {
        case .OK(let entry):
            currentEntry.value = EntryViewModel(entry: entry)
        case .Error(let error):
            print(error)
            onAlert?("Не удалось загрузить запись.")
        }
    }
    
    func loadComments() {
        api.getComments(currentEntry.value.entry.id) { [unowned self] result in
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