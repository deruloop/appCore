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
		struct OpenAIErrorEnvelope: Decodable {
			struct APIError: Decodable {
				let message: String
				let type: String?
				let code: String?
			}
			let error: APIError
		}

		let url = URL(string: "https://api.openai.com/v1/chat/completions")!

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

		// NOTE: Use a known-valid model for this endpoint. Replace with the one available to your account if needed.
		let body: [String: Any] = [
			"model": "gpt-5-nano",
			"messages": [
				["role": "system", "content": role],
				["role": "user", "content": prompt]
			],
			"max_tokens": 1000,
			"temperature": 0.3
		]

		request.httpBody = try? JSONSerialization.data(withJSONObject: body)

		do {
			let (data, response) = try await URLSession.shared.data(for: request)

			guard let http = response as? HTTPURLResponse else {
				print("Errore: risposta non HTTP")
				return nil
			}

			if data.isEmpty {
				print("Errore: dati di risposta vuoti (status \(http.statusCode))")
				return nil
			}

			if !(200...299).contains(http.statusCode) {
				if let apiError = try? JSONDecoder().decode(OpenAIErrorEnvelope.self, from: data) {
					print("Errore API: \(apiError.error.message) [type: \(apiError.error.type ?? "-") code: \(apiError.error.code ?? "-")]")
				} else {
					let raw = String(data: data, encoding: .utf8) ?? "<non UTF8>"
					print("HTTP \(http.statusCode) body: \(raw)")
				}
				return nil
			}

			let result = try JSONDecoder().decode(ChatGptResponse.self, from: data)
			let responseText = result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
			return responseText
		} catch {
			print("Errore fetch/parse: \(error.localizedDescription)")
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

