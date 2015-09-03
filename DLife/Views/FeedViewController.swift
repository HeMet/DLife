//
//  SBViewController.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit
import MVVMKit

class FeedViewController : UITableViewController, SBViewForViewModel {
    
    @IBOutlet weak var scCategories: UISegmentedControl!
    
    var viewModel : FeedViewModel!
    var adapter: TableViewAdapter!
    
    func bindToViewModel() {
        let tv = view as! UITableView
        tv.estimatedRowHeight = 150
        tv.rowHeight = UITableViewAutomaticDimension
        
        adapter = TableViewAdapter(tableView: tv)
        adapter.cells.register(EntryCellView.self)
        
        adapter.onCellsInserted = { [unowned self] _, paths in
            let row = max(paths[0].row - 1, 0)
            self.adapter.performAfterUpdate {
                if (row > 0) {
                    let path = NSIndexPath(forRow: row, inSection: 0)
                    $0.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                } else {
                    $0.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                }
            }
        }
        
        adapter.delegate = self
        adapter.setData(viewModel.entries, forSectionAtIndex: 0)
        
        viewModel.loadEntries()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        bindToViewModel()
    }
    
    func localize() {
        scCategories.setTitle("latest".localized, forSegmentAtIndex: 0)
        scCategories.setTitle("best".localized, forSegmentAtIndex: 1)
        scCategories.setTitle("hot".localized, forSegmentAtIndex: 2)
        scCategories.setTitle("favorite".localized, forSegmentAtIndex: 3)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.showEntryAtIndex(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == viewModel.entries.endIndex - 1 {
            self.viewModel.loadEntries()
        }
        if let ec = cell as? EntryCellView {
            ec.setActive(true)
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let ec = cell as? EntryCellView {
            ec.setActive(false)
        }
    }
    
    @IBAction func handleCategoryChanged(sender: AnyObject) {
        let sc = sender as! UISegmentedControl
        switch sc.selectedSegmentIndex {
        case 0:
            viewModel.category = .Latest
        case 1:
            viewModel.category = .Top
        case 2:
            viewModel.category = .Hot
        case 3:
            viewModel.category = .Favorite
        default:
            break
        }
    }
    
    @IBAction func handleAboutTapped(sender: UIBarButtonItem) {
        viewModel.showAbout()
    }
}
