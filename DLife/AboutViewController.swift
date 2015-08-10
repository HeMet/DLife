//
//  AboutViewController.swift
//  DLife
//
//  Created by Евгений Губин on 10.08.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import MVVMKit

class AboutViewController: UIViewController, SBViewForViewModel {
    static let sbInfo = (sbID: "Main", viewID: "AboutViewController")
    
    var viewModel: AboutViewModel!
    
    func bindToViewModel() {
        // do nothing
    }
}