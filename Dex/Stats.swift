//
//  Stats.swift
//  Dex
//
//  Created by Sudha Rani on 07/06/25.
//

import SwiftUI
import Charts

struct Stats: View {
    var pokemon: Pokemon
    
    var body: some View {
       
        Chart(pokemon.stats) { stat in
            BarMark(x: .value("Value", stat.value),
                    y: .value("Name", stat.name)
            )
            
            .annotation(position: .trailing) {
                Text("\(stat.value)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, -5)
            }
        }
        .frame(height: 200)
        .padding([.horizontal, .bottom])
        .foregroundStyle(pokemon.typeColor)
        .chartXScale(domain: 0...pokemon.highestStat.value + 10)
    }
}

#Preview {
    Stats(pokemon: PersistenceController.previewPokemon)
}
