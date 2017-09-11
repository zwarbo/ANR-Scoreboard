//
//  Tournament.swift
//  ANR Scoreboard 2
//
//  Created by mark on 2/09/17.
//  Copyright © 2017 mark. All rights reserved.
//

import Foundation

struct Tournament {
    
    var players: [Player] = []

    struct Player {
        var name: String
        var runnerFaction: String?
        var runnerIdentity: String?
        var corpFaction: String?
        var corpIdentity: String?
    }
}

// Custom structional coding for NRTM JSON structure

extension Tournament : Decodable {
    
    enum TournamentKeys: String, CodingKey {
        case players
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TournamentKeys.self)
        
        self.players = try container.decode([Player].self, forKey: .players)
    }
}

extension Tournament.Player : Decodable {
    
    // The keys inside of the "players" object
    enum PlayerKeys: String, CodingKey {
        case name
        case runnerFaction
        case runnerIdentity
        case corpFaction
        case corpIdentity
    }
    
    init(from decoder: Decoder) throws {
        
        // Extract the top-level values ("players")
        let container = try decoder.container(keyedBy: PlayerKeys.self)
        
        // Extract each property from the nested container
        self.name = try container.decode(String.self, forKey: .name)
        self.runnerFaction = try container.decodeIfPresent(String.self, forKey: .runnerFaction) ?? " "
        self.runnerIdentity = try container.decodeIfPresent(String.self, forKey: .runnerIdentity) ?? " "
        self.corpFaction = try container.decodeIfPresent(String.self, forKey: .corpFaction) ?? " "
        self.corpIdentity = try container.decodeIfPresent(String.self, forKey: .corpIdentity) ?? " "
    }
}

extension Tournament {
    
    init(data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(Tournament.self, from: data)
    }
    
    init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }
}

