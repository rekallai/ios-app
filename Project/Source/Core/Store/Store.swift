//
//  Store.swift
//  Snoutscan
//
//  Created by Levi McCallum on 4/6/19.
//  Copyright © 2019 Rekall. All rights reserved.
//

import Foundation

class Store {
    private(set) var state: AppState
        
    let coreDataDispatchQueue = DispatchQueue(label: "CoreData Queue")

    init(initialState state: AppState?) {
        self.state = state ?? AppState()
    }
    
    func apply(_ mutation: (inout AppState) -> Void) {
        var newState = state
        mutation(&newState)
        state = newState
    }
    
    func storeToken(newToken: String) {
        apply{
            $0.token = newToken
        }
        persist()
    }
    
    func signOut() {
        apply {
            $0.token = nil
        }
        persist()
    }
    
    func persist() {
        AppState.persist(state)
    }
    
    var isLoggedIn: Bool {
        return state.token != nil
    }    
}
