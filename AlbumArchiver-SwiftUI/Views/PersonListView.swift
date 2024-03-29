//
//  PersonListView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 3/25/23.
//

import SwiftUI

struct PersonListView: View {
    
    @ObservedObject var library: Library
    
    @State var newPersonName = "" 
    
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
                    if let p = library.people.first(where: {$0.id == p}) {
                        library.removePerson(somePerson: p)
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
            }.onChange(of: newPersonName) { newValue in
                isValid = validate()
            }
        }.padding()
    }
    
    func validate() -> Bool {
        
        let isBlank = newPersonName.trimmingCharacters(in: .whitespaces).count == 0
        
        var isDuplicate = false
        for p in library.people {
            // TODO: change algorithm if we end up with a substantial number of names
            if p.name == newPersonName { // string comparison this way works!
                isDuplicate = true
                break
            }
        }
        
        if !isBlank && !isDuplicate {
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

