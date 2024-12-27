//
//  ChatGptManager.swift
//  AppCore
//
//  Created by Cristiano Calicchia on 10/12/24.
//

import Foundation

public protocol ChatGptRepository {
	func fetchChatGPTResponse(prompt: String, role: String) async -> String?
}


public struct ChatGptResponse: Decodable {
	let id: String
	let object: String
	let choices: [ChatChoice]
}

public struct ChatChoice: Decodable {
	let message: ChatMessage
}

public struct ChatMessage: Decodable {
	let role: String
	let content: String
}

public class ChatGptManager: ObservableObject,ChatGptRepository {

	private var apiKey: String
	
	public init(apiKey: String) {
		self.apiKey = apiKey
	}
	
	public func fetchChatGPTResponse(prompt: String, role: String) async -> String? {
		let url = URL(string: "https://api.openai.com/v1/chat/completions")!
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
		
		let body: [String: Any] = [
			"model": "gpt-4", // gpt-3.5-turbo as an alternative
			"messages": [
				["role": "system", "content": "\(role)"],
				["role": "user", "content": prompt]
			],
			"max_tokens": 1000,
			"temperature": 0.3
		]
		
		request.httpBody = try? JSONSerialization.data(withJSONObject: body)
		
		do {
			let (data, _) = try await URLSession.shared.data(for: request)
			let result = try JSONDecoder().decode(ChatGptResponse.self, from: data)
			let responseText = result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
			return responseText
		} catch {
			print("Error fetching or parsing response: \(error.localizedDescription)")
			return nil
		}
	}

}


public class ChatGptManagerMock: ChatGptRepository {
	//TODO: cover failure and success cases
	public init() {
		
	}
	
	public func fetchChatGPTResponse(prompt: String, role: String) async -> String? {
		return ""
	}

}
