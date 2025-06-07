//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Sudha Rani on 01/06/25.
//

import Foundation

struct FetchedPokemon: Decodable {
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int16
    let attack: Int16
    let defense: Int16
    let specialAttack: Int16
    let specialDefense: Int16
    let speed: Int16
    let sprite: URL
    let shiny: URL
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: CodingKey {
            case type
            
            enum TypeKeys: CodingKey {
                case name
            }
        }
        
        enum StatsDictionaryKeys: CodingKey {
            case baseStat
        }
        
        enum SpriteKeys: String, CodingKey {
            case sprite = "frontDefault"
            case shiny = "frontShiny"
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        var decodeTypes: [String] = []
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
        
        while !typesContainer.isAtEnd {
            let typeDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
            let typeContainer = try typeDictionaryContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self,
                                                                            forKey: .type)
            
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodeTypes.append(type)
            
        }
        
        if decodeTypes.count == 2 && decodeTypes[0] == "normal" {
            decodeTypes.swapAt(0, 1)
        }
        
        self.types = decodeTypes
        
        
        var decodeStats: [Int16] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatsDictionaryKeys.self)
            
            let stat = try statsDictionaryContainer.decode(Int16.self, forKey: .baseStat)
            decodeStats.append(stat)
        }
        
        self.hp = decodeStats[0]
        self.attack = decodeStats[1]
        self.defense = decodeStats[2]
        self.specialAttack = decodeStats[3]
        self.specialDefense = decodeStats[4]
        self.speed = decodeStats[5]
        
        let spriteContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteKeys.self, forKey: .sprites)
        self.sprite = try spriteContainer.decode(URL.self, forKey: .sprite)
        self.shiny = try spriteContainer.decode(URL.self, forKey: .shiny)
    }
}
