//
//  Serialization.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

extension DLEntry {
    convenience init(json: [String: AnyObject]) {
        self.init()
        
        id = json["id"] as! Int
        description = json["description"] as! String
        votes = json["votes"] as! Int
        gifURL = json["gifURL"] as! String
        previewURL = json["previewURL"] as! String
    }
}