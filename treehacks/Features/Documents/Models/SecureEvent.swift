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
}
