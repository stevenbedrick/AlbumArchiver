//
//  PersonPickerPopupView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 3/25/23.
//

import SwiftUI

struct PersonPickerPopupView: View {
    
    @EnvironmentObject var library : Library
    
    var thisItem : ArchivedItem
    var faceObs : FaceObservation
    
    @State var filteredPeople: [Person] = []
    
    @State var searchQuery = ""
    
    var body: some View {
        VStack{
//            Text("Library has \(library.people.count) people").padding()
            TextField("Find Name", text: $searchQuery).frame(width: 240)
            List(filteredPeople, id: \.id) { person in
                Button(person.name) {
                    NSLog("Clicked: \(person.name)")
                }
            }.frame(height: 240)
            Text("Filtered persons: \(filteredPeople.count)")
        }
        .onChange(of: searchQuery) { _ in
            filterPeople()
        }
        .padding()
        .frame( maxWidth: .infinity, maxHeight: .infinity)

    }
    
    func filterPeople() {
        if searchQuery.isEmpty {
            filteredPeople = library.people
        } else {
            filteredPeople = library.people.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }

    }
    
}

