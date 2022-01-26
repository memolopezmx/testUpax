//
//  UpaxGraphData.swift
//  testUpax-David-Guillermo-Lopez-Vazquez
//
//  Created by David Lopez on 1/25/22.
//

import Foundation

struct SalinasData: Decodable {
    let colors: [String]
    let questions: [Question]
}

struct Question: Decodable {
    let total: Int
    let text: String
    let chartData: [Percentage]
}

struct Percentage: Decodable {
    let text: String
    let percetnage: Int
}
