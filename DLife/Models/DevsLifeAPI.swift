//
//  DevsLifeAPI.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import Alamofire
import WebImage

enum FeedCategory: CustomStringConvertible {
    case Latest, Hot, Top, Favorite
    
    var description: String {
        switch self {
        case .Hot: return "hot"
        case .Latest: return "latest"
        case .Top: return "top"
        case .Favorite: return "favorite"
        }
    }
}

enum ApiResult<T> {
    case Error(ErrorType)
    case OK(T)
}

extension NSError {
    class var DLifeApiDomain: String {
        return "DLifeAPI"
    }
    
    static func newApiError(errorCode: DLifeAPIErrorCodes) -> NSError {
        return NSError(domain: DLifeApiDomain, code: errorCode.rawValue, userInfo: nil)
    }
}

enum DLifeAPIErrorCodes: Int {
    case NotFound = 0
}

class FeedToken {
    let pageSize: Int
    let category: FeedCategory
    
    var page: Int = 0
    var total: Int = 0
    
    convenience init() {
        self.init(category: .Latest, pageSize: 5)
    }
    
    init(category: FeedCategory, pageSize: Int) {
        self.pageSize = pageSize
        self.category = category
    }
    
    func next() {
        page++
    }
    
    var isEndOfFeed: Bool {
        return (page + 1) * pageSize >= total
    }
    
    var isUsed: Bool {
        return page > 0
    }
}

class DevsLifeAPI {
    func getEntries(token: FeedToken, callback: ApiResult<[DLEntry]> -> ()) {
        let params: [String: AnyObject] = [
            "json": "true",
            "pageSize": token.pageSize,
            "types": "gif"
        ]
        
        Alamofire.request(.GET, "http://developerslife.ru/\(token.category)/\(token.page)", parameters: params, encoding: .URL).responseJSON { (_, _, result) in

            if  let data = result.value as? [String: AnyObject],
                let result = data["result"] as? [[String: AnyObject]],
                let totalCount = data["totalCount"] as? Int {
                    
                    let entries = result.map {
                        DLEntry(json: $0)
                    }
                    token.total = totalCount
                    token.next()
                    
                    self.loadPreviews(entries) {
                        callback(.OK(entries))
                    }
            } else if let error = result.error {
                callback(.Error(error))
            }
        }
    }
    
    func loadPreviews(entries: [DLEntry], callback: () -> ()) {
        if entries.isEmpty {
            callback()
            return
        }
        
        let downloader = SDWebImageDownloader.sharedDownloader()
        downloader.setSuspended(true)
        let counter = Counter(entries.count)
        for entry in entries {
            downloader.downloadImageWithURL(NSURL(string: entry.previewURL), options: SDWebImageDownloaderOptions(), progress: { _ in }) { image, _, error, _ in
                dispatch_async(dispatch_get_main_queue()) {
                    if (error == nil) {
                        entry.imgSize = (Float(image.size.width), Float(image.size.height))
                    }
                    counter.value--
                    if (counter.value == 0) {
                        callback()
                    }
                }
            }
        }
        downloader.setSuspended(false)
    }

    class Counter {
        var value = 0
        
        init(_ value: Int) {
            self.value = value
        }
    }
    
    func getRandomEntry(callback: ApiResult<DLEntry> -> ()) {
        let params: [String: AnyObject] = [
            "json": "true",
            "types": "gif"
        ]
        Alamofire.request(.GET, "http://developerslife.ru/random", parameters: params, encoding: .URL).responseJSON { (_, _, result) in
            if  let result = result.value as? [String: AnyObject] {
                    
                let entry = DLEntry(json: result)
                
                self.loadPreviews([entry]) {
                    callback(.OK(entry))
                }
            } else if let error = result.error {
                callback(.Error(error))
            }
        }
    }
    
    func getEntry(id: String, callback: ApiResult<DLEntry> -> ()) {
        let params: [String: AnyObject] = [
            "json": "true",
            "types": "gif"
        ]
        Alamofire.request(.GET, "http://developerslife.ru/\(id)", parameters: params, encoding: .URL).responseJSON { (_, _, result) in
            if  let result = result.value as? [String: AnyObject] {
                
                if let _ = result["error"] as? String {
                    let nsError = NSError.newApiError(.NotFound)
                    callback(.Error(nsError))
                } else {
                    let entry = DLEntry(json: result)
                    
                    self.loadPreviews([entry]) {
                        callback(.OK(entry))
                    }
                }
            } else if let error = result.error {
                callback(.Error(error))
            }
        }
    }
    
    func getComments(entryId: Int, callback: ApiResult<[DLComment]> -> ()) {
        let params: [String: AnyObject] = [
            "json": "true",
        ]
        Alamofire.request(.GET, "http://developerslife.ru/comments/entry/\(entryId)", parameters: params, encoding: .URL).responseJSON { (_, _, result) in
            if  let data = result.value as? [String: AnyObject],
                let result = data["comments"] as? [[String: AnyObject]] {
            
                let comments = result.map {
                    DLComment(json: $0)
                }
                
                callback(.OK(comments))
            } else if let error = result.error {
                callback(.Error(error))
            }
        }
    }
}