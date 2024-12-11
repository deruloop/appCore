//
//  CancelBag.swift
//  PackdApp
//
//  Created by deruloop on 04.04.2020.
//  Copyright © 2020 deruloop. All rights reserved.
//

import Combine

public final class CancelBag {
    var subscriptions = Set<AnyCancellable>()
    
	public init(subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()) {
		self.subscriptions = subscriptions
	}
	
	public func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
}

public extension AnyCancellable {
    
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
