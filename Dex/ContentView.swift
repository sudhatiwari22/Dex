//
//  ContentView.swift
//  Dex
//
//  Created by Sudha Rani on 01/06/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    
    @Query(sort: \Pokemon.id, animation: .default) private var pokedex: [Pokemon]
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    
    private var dynamicPredicate: Predicate<Pokemon> {
        #Predicate<Pokemon> { pokemon in
            if filterByFavorites && !searchText.isEmpty {
                pokemon.favorite &&
                pokemon.name.localizedStandardContains(searchText)
            } else if (!searchText.isEmpty) {
                pokemon.name.localizedStandardContains(searchText)
            } else if (filterByFavorites) {
                pokemon.favorite
            } else {
                true
            }
        }
    }
    
    let fetchService = FetchService()

    var body: some View {
        if pokedex.isEmpty {
            ContentUnavailableView {
                Label("No Pokemon", image: .nopokemon)
            } description: {
                Text("There aren't any pokemon yet.\nFetch some Pokemon to get started.")
            } actions: {
                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            
            NavigationStack {
                List {
                    Section {
                        ForEach(try? pokedex.filter(dynamicPredicate) ?? pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                        
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                } else {
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(pokemon.name.capitalized)
                                            .fontWeight(.bold)
                                        
                                        if pokemon.favorite == true {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    
                                    HStack {
                                        ForEach(pokemon.types, id: \.self) { type in
                                            Text(type.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 5)
                                                .background(Color(type.capitalized))
                                                .clipShape(.capsule)
                                        }
                                    }
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button(pokemon.favorite ? "Remove from favorites" : "Add to favorites", systemImage: "star") {
                                    pokemon.favorite.toggle()
                                    
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer : {
                        if pokedex.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch was intruppted.\nFetch the rest of the Pokemon")
                            } actions: {
                                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                .navigationTitle("Pokedex")
                .searchable(text: $searchText, prompt: "Find a Pokemon")
                .autocorrectionDisabled()
                .navigationDestination(for: Pokemon.self ) { pokemon in
                    PokemonDetail(pokemon: pokemon)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterByFavorites.toggle()
                        } label: {
                            Label("Filter by favorites",
                                  systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
    }

    private func getPokemon(from id: Int) {
        Task {
            for i in id..<152 {
                do {
                    let fetchedPokemon = try await fetchService.fetchPokemon(i)
                    modelContext.insert(fetchedPokemon)
                    
                } catch {
                    print(error)
                }
            }
            
            storeSprites()
        }
    }
    
    private func storeSprites() {
        Task {
            do {
                for pokemon in pokedex {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL).0
                    
                    try modelContext.save()
                    print("sprites stored..\(pokemon.id) \(pokemon.name.capitalized)")
                }
            } catch {
                print(error)
            }
        }
    }

}


#Preview {
    ContentView().modelContainer(PersistenceController.preview)
}
