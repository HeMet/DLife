//
//  CollectionExtensions.swift
//  DLife
//
//  Created by Евгений Губин on 20.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

extension RangeReplaceableCollectionType {
    mutating func replaceAll<C: CollectionType where C.Generator.Element == Generator.Element>(newItems: C) {
        replaceRange(startIndex..<endIndex, with: newItems)
    }
}