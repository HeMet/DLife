//
//  CommentCellView.swift
//  DLife
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit
import MVVMKit

class CommentCellView: UITableViewCell, CellViewForViewModel {
    
    var viewModel: DLComment!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    func bindToViewModel() {
        lblHeader.text = "@rating: \(viewModel.voteCount) @author: \(viewModel.authorName) @date: \(viewModel.date)"
        
        // tvMessage.attributesText setted up by table view

        // Workaround: bottom and right constraint's priorities are setted to 999 because of UIView-Encapsulated-Layout-... bug
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lblHeader.preferredMaxLayoutWidth = self.bounds.width - 16
        lblMessage.preferredMaxLayoutWidth = self.bounds.width - 16
    }
}
