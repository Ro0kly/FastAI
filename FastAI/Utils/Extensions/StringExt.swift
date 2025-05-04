//
//  StringExt.swift
//  FastAI
//
//  Created by Rookly on 04.05.2025.
//

import Foundation

extension String {
    func toDataBase64() -> Data? {
        return Data.init(base64Encoded: self)
    }
}
