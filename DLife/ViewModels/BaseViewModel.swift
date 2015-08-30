//
//  ViewModel.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 17.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import MVVMKit

class BaseViewModel: ViewModelWithID, DisposableViewModel {
    var uniqueID = String.unique()
    
    var onDisposed: ViewModelEventHandler?
}