//
//  JokeModel.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/10.
//
import Foundation

struct JokeResponse: Decodable {
	let type: String
	let value: Joke
}

struct Joke: Decodable {
	let id: Int
	let joke: String
	let categories: [String]
}

enum JokesAPI {
	case randomJokes

	static let baseURL = "https://api.icndb.com/"
	var path: String { "jokes/random" }
	var url: URL { URL(string: JokesAPI.baseURL + path)! }

	var sampleData: Data {
		Data(
			"""
            {
                "type": "success",
                    "value": {
                    "id": 459,
                    "joke": "Chuck Norris can solve the Towers of Hanoi in one move.",
                    "categories": []
                }
            }
            """.utf8
		)
	}
}
