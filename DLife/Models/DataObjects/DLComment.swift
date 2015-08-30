//
//  DLComment.swift
//  DLife
//
//  Created by Евгений Губин on 16.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

class DLComment: Equatable {
    var id: Int!
    var entryId: Int!
    var text: String!
    var date: String!
    var voteCount: Int!
    var authorName: String!
}

func ==(l: DLComment, r: DLComment) -> Bool {
    return l.id == r.id
}