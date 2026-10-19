//
//  Poster.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 17/10/2026.
//

import Foundation
import SwiftData
import UIKit

@Model
class Poster {
    var title: String
    var timestamp: Date
    var imageData: Data?

    init(title: String, imageData: Data? = nil, timestamp: Date = .now) {
        self.title = title
        self.timestamp = timestamp
        self.imageData = imageData
    }

    var image: UIImage? {
        imageData.flatMap {
            UIImage(data: $0)
        }
    }
}
