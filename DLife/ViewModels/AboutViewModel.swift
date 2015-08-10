//
//  AboutViewModel.swift
//  DLife
//
//  Created by Евгений Губин on 10.08.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import MVVMKit

class AboutViewModel: ViewModel {
    var onDisposed: ViewModelEventHandler?
    
    func dispose() {
        onDisposed?(self)
    }
    
    deinit {
        dispose()
    }
}