//
//  PersonListView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 3/25/23.
//

import SwiftUI

struct PersonListView: View {
    
    @ObservedObject var library: Library
    
    @State var newPersonName = "" {
        didSet {
            // Does not appear to be working
            isValid = validate()
        }
    }
    
    @State var selectedPeople = Set<Person.ID>()
    
    @State var isValid = false
    
    var body: some View {
        VStack{
            Table(library.people, selection: $selectedPeople) {
                TableColumn("Name", value: \.name)
            }
            .navigationTitle("People")
            .onDeleteCommand(perform: {
                for p in selectedPeople {
                    // find the index
                    if let idx = library.people.firstIndex(where: {$0.id == p}) {
                        library.people.remove(at: idx)
                    }
                }
            })
            .padding([.bottom])
            HStack {
                TextField("New Person", text: $newPersonName, onCommit: handleSubmit)
                Button("Add", action: handleSubmit)
                    .disabled(!isValid) // this part's not quite working
                    .keyboardShortcut(.defaultAction)
                    
                Spacer()
            }
        }.padding()
    }
    
    func validate() -> Bool {
        // this logic isn't working
        if newPersonName.trimmingCharacters(in: .whitespaces).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func handleSubmit() {
        if validate() {
            library.addPerson(withName: newPersonName)
            newPersonName = ""
        }
    }
}

