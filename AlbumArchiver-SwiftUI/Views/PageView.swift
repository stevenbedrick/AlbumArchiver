//
//  PageView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import SwiftUI
import Cocoa

struct PageView: View {
    
    @State var active = false

    @ObservedObject var thisPage: Page
    
    var gridLayout : [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        
        
        VStack {
            HStack {
                Text("Page:")
                TextField("New Page Number", text: $thisPage.number)
            }
            Text("Items:")
            
            
            ItemCollectionViewHost(forPage: thisPage)
            
            HStack {
                Button("New Item") {
                    thisPage.addItem()
                }.padding()
                Spacer()
                Text("Faces: \(thisPage.faces().count)")
            }
        }.padding()
    }
}
