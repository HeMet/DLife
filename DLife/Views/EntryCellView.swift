//
//  EntryCellView.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit
import MVVMKit
import WebImage

// TODO: Maybe it would be useful to declare ViewForViewModelHolder protocol
// to specify what viewModel should be binded to child view.

class EntryCellView: UITableViewCell, CellViewForViewModel, NibSource {

    @IBOutlet weak var entryView: EntryView!
    
    var viewModel: EntryViewModel! {
        get {
            return entryView.viewModel
        }
        set {
            entryView.viewModel = newValue
        }
    }
    
    func bindToViewModel() {
        entryView.bindToViewModel()
    }
    
    func setActive(active: Bool) {
        entryView.setActive(active)
    }
}