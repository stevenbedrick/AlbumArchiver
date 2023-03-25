//
//  Person.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 3/25/23.
//

import Foundation
import SwiftUI

public class Person : Identifiable, ObservableObject, Hashable {
    public static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id = UUID()

    @Published var name : String
    
    @Published var observations : [FaceObservation] = []
    
    init(name: String) {
        self.name = name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }

    
}
