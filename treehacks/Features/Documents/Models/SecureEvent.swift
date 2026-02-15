//
//  SecureEvent.swift
//  treehacks
//
//  Created by Arnauld Martinez on 2/14/26.
//

import Foundation

struct SecureEvent: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var body: String
    var updatedAt: Date

    // Attachments
    var photoFileNames: [String]
    var audioFileNames: [String]

    init(
        id: UUID,
        title: String,
        body: String,
        updatedAt: Date,
        photoFileNames: [String] = [],
        audioFileNames: [String] = []
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.updatedAt = updatedAt
        self.photoFileNames = photoFileNames
        self.audioFileNames = audioFileNames
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case updatedAt
        case photoFileNames
        case audioFileNames
    }

    // Custom decoding to remain compatible with older saved data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.photoFileNames = try container.decodeIfPresent([String].self, forKey: .photoFileNames) ?? []
        self.audioFileNames = try container.decodeIfPresent([String].self, forKey: .audioFileNames) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(photoFileNames, forKey: .photoFileNames)
        try container.encode(audioFileNames, forKey: .audioFileNames)
    }
}
