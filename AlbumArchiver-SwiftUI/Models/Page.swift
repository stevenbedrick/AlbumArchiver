//
//  Page.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import Foundation
import SwiftUI
import Vision
import Combine

public class Page : Identifiable, ObservableObject, Hashable {
    public static func == (lhs: Page, rhs: Page) -> Bool {
        return (lhs.id == rhs.id) && (lhs.number == rhs.number)
    }
    
    
    public let id = UUID()
    @Published var number: String
    @Published var items = [ArchivedItem]()
        
    init(number: String) {
        self.number = number
    }
    
    init(number: String, withItems items: [ArchivedItem]) {
        self.number = number
        self.items = items
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(number)
    }
    
    func addItem() {
        self.items.append(ArchivedItem(withName: "New Item"))
    }
    
    func addItem(someItem: ArchivedItem) {
        self.items.append(someItem)
    }
    
    func faces() -> [FaceObservation] {
        return self.items.flatMap { i in
            i.faces
        }
    }

}
