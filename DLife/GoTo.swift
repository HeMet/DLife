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
    static let root = NavigationView.with { FeedViewController.bindedTo($0) }.presented().asRoot()
    static let post = PostViewController.presented().withTransition(Transitions.show)
    static let about = AboutViewController.presented().withTransition(Transitions.show)
}