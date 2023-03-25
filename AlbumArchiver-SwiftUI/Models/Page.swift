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
    
    @ObservedObject var album : Album
        
    init(number: String, inAlbum album: Album) {
        self.number = number
        self.album = album
    }
    
    init(number: String, withItems items: [ArchivedItem], inAlbum album: Album) {
        self.number = number
        self.items = items
        self.album = album
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(number)
    }
    
    func addItem() {
        let toAppend = ArchivedItem(withName: "New Item", onPage: self)
        self.items.append(toAppend)
    }
    
    func addItem(someItem: ArchivedItem) {
        someItem.page = self
        self.items.append(someItem)
    }
    
    func faces() -> [FaceObservation] {
        return self.items.flatMap { i in
            i.faces
        }
    }

}
