//
//  ArchivedItem.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/5/22.
//

import Foundation
import SwiftUI
import Cocoa

public class ArchivedItem : Identifiable, ObservableObject, Hashable {
    public static func == (lhs: ArchivedItem, rhs: ArchivedItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    @Published var name : String
    @Published var image : NSImage?
    
    public let id = UUID()
    
    init(withName: String, withImage: NSImage? = nil) {
        name = withName
        image = withImage
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func attachItem(fromUrl: URL) {
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let rawIm = NSImage(byReferencing: fromUrl)
            if rawIm.isValid {
                
                let fileName = fromUrl.lastPathComponent
                
                DispatchQueue.main.async {
                    self.image = rawIm
                    self.name = fileName
                }
            }  else {
                    print("Could not load image from \(fromUrl)")
            }
                
            
            
        }
        
        

    }

    
}
