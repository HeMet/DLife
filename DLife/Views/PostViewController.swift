//
//  EntryViewController2.swift
//  DLife
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit
import MVVMKit

class PostViewController: UITableViewController, SBViewForViewModel, UITableViewDelegate {
    static let sbInfo = (sbID: "Main", viewID: "PostViewController")
    
    let cbTag = "PostViewController"
    
    var viewModel: PostViewModel!
    var adapter: TableViewAdapter!
    
    var htmlTexts: [NSAttributedString?] = []
    var commentsProxy: ObservableArray<DLComment> = []
    
    func bindToViewModel() {
        adapter = TableViewAdapter(tableView: tableView, rowHeightMode: .TemplateCell)
        adapter.delegate = self
        
        adapter.cells.register(EntryCellView.self)
        adapter.cells.register(CommentCellView.self)
        adapter.cells.onWillBind = unowned(self, PostViewController.handleWillBindCell)
        adapter.cells.onDidBind = { cell, path in
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
        }
        
        commentsProxy = ObservableArray(observableArray: viewModel.comments)
        
        adapter.beginUpdate()
        adapter.setData(viewModel.currentEntry, forSectionAtIndex: 0)
        adapter.setData(commentsProxy, forSectionAtIndex: 1)
        adapter.setTitle("Комментарии:", forSection: .Header, atIndex: 1)
        println("end update")
        adapter.endUpdate()
        
        viewModel.onEntryChanged = { [unowned self] in
            self.adapter.setData(self.viewModel.currentEntry, forSectionAtIndex: 0)
            self.navigationItem.title = "Entry\(self.viewModel.currentEntry.entry.id)"
        }
        
        viewModel.comments.onBatchUpdate.register(cbTag, listener: unowned(self, PostViewController.parseCommentsTextAndUpdate))
        navigationItem.title = "Entry\(viewModel.currentEntry.entry.id)"
    }
    
    func parseCommentsTextAndUpdate(comments: ObservableArray<DLComment>, phase: UpdatePhase) {
        switch phase {
        case .Begin:
            adapter.beginUpdate()
            commentsProxy.removeAll(false)
        case .End:
            let copy = ObservableArray(observableArray: comments)
            htmlTexts = map(copy) { parseCommentText($0.text) }
            commentsProxy.replaceAll(comments)
            println("end update (comments)")
            adapter.endUpdate()
        }
    }
    
    func handleWillBindCell(cell: UITableViewCell, path: NSIndexPath) {
        switch cell {
        case let commentCell as CommentCellView:
            commentCell.lblMessage.attributedText = self.htmlTexts[path.row]
        case let entryCell as EntryCellView:
            entryCell.entryView.instantGifLoading = true
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
    
    @IBAction func nextRandomPostTapped(sender: AnyObject) {
        viewModel.nextRandomPost()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadComments()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let ec = cell as? EntryCellView {
            ec.setActive(true)
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let ec = cell as? EntryCellView {
            ec.setActive(false)
        }
    }
    
    deinit {
        println("dispose EVC")
    }
}