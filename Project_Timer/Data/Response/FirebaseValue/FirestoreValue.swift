//
//  FirestoreValue.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/17.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

protocol FirestoreValue {}
extension FirestoreValue {
    func transString(_ stringValue: FirebaseStringValue) -> FirebaseStringValue {
        let transString = stringValue.value.replacingOccurrences(of: "\\n", with: "\n")
        return FirebaseStringValue(value: transString)
    }
}
