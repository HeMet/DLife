//
//  GoTo.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 10.05.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit
import MVVMKit

struct GoTo {
    static let root = present(!FeedViewController.self).withinNavView().asRoot()
    static let entry = present(!EntryViewController.self).withTransition(Transitions.show)
}