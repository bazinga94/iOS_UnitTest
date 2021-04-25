//
//  JokeModel.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/10.
//
import Foundation

struct JokesAPI: NetworkInterface {
	internal typealias Response = JokeResponse

	static let baseURL = "https://api.icndb.com/"
	private var path: String { "jokes/random" }
	var url: URL { URL(string: JokesAPI.baseURL + path)! }

	struct JokeResponse: APIResponse {
		struct Joke: Decodable {
			let id: Int
			let joke: String
			let categories: [String]
		}

		let type: String
		let value: Joke
	}

	var responseSample: Data {
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

//enum JokesAPI {
//	case randomJokes
//
//	static let baseURL = "https://api.icndb.com/"
//	var path: String { "jokes/random" }
//	var url: URL { URL(string: JokesAPI.baseURL + path)! }
//
//	var sampleData: Data {
//		Data(
//			"""
//            {
//                "type": "success",
//                    "value": {
//                    "id": 459,
//                    "joke": "Chuck Norris can solve the Towers of Hanoi in one move.",
//                    "categories": []
//                }
//            }
//            """.utf8
//		)
//	}
//}
