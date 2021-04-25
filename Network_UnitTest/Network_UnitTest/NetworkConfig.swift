//
//  NetworkConfig.swift
//  Network_UnitTest
//
//  Created by Jongho Lee on 2021/04/25.
//

import Foundation

enum APIError: Error {
	case unknown
	case httpStatus
	case decodingJSON
	case dataNil
	//	var errorDescription: String? { "unknownError" }
}

enum HttpMethod: String {
	case GET
	case POST
}
