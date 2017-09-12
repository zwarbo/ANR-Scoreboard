//
//  Score.swift
//  ANR Scoreboard
//
//  Created by Mark Blackman on 6/09/17.
//  Copyright © 2017 Mark Blackman. All rights reserved.
//

//Score counter structure

import Foundation

struct Score {
    
    var score = 0
    
    mutating func increment() {
        score += 1
    }
    
    mutating func decrement() {
        score -= 1
    }
    
    mutating func reset() {
        score = 0
    }
    func isSevenPlus() -> Bool { // Check for 7 agenda points
        if self.score >= 7 {
            return true
        } else {
            return false
        }
    }
    func isSixPlus() -> Bool { // Check for 6 AP for "Harmony Medtech"
        if self.score >= 6 {
            return true
        } else {
            return false
        }
    }
}
