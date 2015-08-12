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
    
    @IBOutlet weak var lblMobileApp: UILabel!
    @IBOutlet weak var lblPoweredBy: UILabel!
    @IBOutlet weak var lblSources: UILabel!
    @IBOutlet weak var lblIconProvidedBy: UILabel!
    @IBOutlet weak var lblCopyright: UILabel!
    
    
    var viewModel: AboutViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }
    
    func localize() {
        lblMobileApp.text = "mobileApp".localized
        lblPoweredBy.text = "poweredBy".localized
        lblSources.text = "sources".localized
        lblIconProvidedBy.text = "iconsProvidedBy".localized
        lblCopyright.text = "copyright".localized
    }
    
    func bindToViewModel() {
        // do nothing
    }
}