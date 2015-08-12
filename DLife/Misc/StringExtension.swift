//
//  StringExtension.swift
//  DLife
//
//  Created by Евгений Губин on 12.08.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "DLife", comment: "")
    }
}