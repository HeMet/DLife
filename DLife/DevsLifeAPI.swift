//
//  DevsLifeAPI.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import Alamofire
import Box

enum FeedCategory: Printable {
    case Latest, Hot, Top
    
    var description: String {
        switch self {
        case .Hot: return "hot"
        case .Latest: return "latest"
        case .Top: return "top"
        }
    }
}

enum ApiResult<T> {
    case Error(NSError)
    case OK(Box<T>)
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
}

class DevsLifeAPI {
    func getEntries(token: FeedToken, callback: ApiResult<[DLEntry]> -> ()) {
        let params: [String: AnyObject] = [
            "json": "true",
            "pageSize": token.pageSize,
            "types": "gif"
        ]
        Alamofire.request(.GET, "http://developerslife.ru/\(token.category)/\(token.page)", parameters: params, encoding: .URL).responseJSON { (_, _, data, error) in
            if  let data = data as? [String: AnyObject],
                let result = data["result"] as? [[String: AnyObject]],
                let totalCount = data["totalCount"] as? Int {
                    
                    var entries = map(result) {
                        DLEntry(json: $0)
                    }
                    token.total = totalCount
                    token.next()
                    callback(.OK(Box(entries)))
            } else if let error = error {
                callback(.Error(error))
            }
        }
    }
    
    func getEntries(category: FeedCategory, page: Int, count: Int, callback: ApiResult<[DLEntry]> -> ()) {
        let params: [String: AnyObject] = [
            "json": "true",
            "pageSize": count,
            "types": "gif"
        ]
        Alamofire.request(.GET, "http://developerslife.ru/\(category)/\(page)", parameters: params, encoding: .URL).responseJSON { (_, _, data, error) in
            if  let data = data as? [String: AnyObject],
                let result = data["result"] as? [[String: AnyObject]] {
                
                    println(data)
                    var entries = map(result) {
                        DLEntry(json: $0)
                    }
                    callback(.OK(Box(entries)))
                    Array<String>()
            } else if let error = error {
                println(error)
                callback(.Error(error))
            }
        }
    }

}