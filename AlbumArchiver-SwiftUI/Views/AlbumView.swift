//
//  AlbumView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import SwiftUI

struct AlbumView: View {
    
    @ObservedObject var thisAlbum : Album
    
    var body: some View {
        VStack {
            HStack {
                Text("Album title:")
                TextField("New Title", text: $thisAlbum.name)
            }
            
            Text("Pages:").frame(maxWidth: .infinity, alignment: .leading)
                
            
            Table(thisAlbum.pages) {
                TableColumn("Number", value: \.number)
                TableColumn("Items") { p in Text(String(p.items.count)) }
            }.navigationTitle("Pages").padding([.bottom])
            HStack {
                Button("New Page") {
                    thisAlbum.addPage()
                }
                Spacer()
            }
            
        }.padding()
        
    }
}
