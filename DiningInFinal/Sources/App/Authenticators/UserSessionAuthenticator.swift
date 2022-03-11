//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor
import Fluent

struct UserSessionAuthenticator: AsyncSessionAuthenticator {
    
    typealias User = AuthenticatedUser
    
    func authenticate(sessionID: User.SessionID, for req: Request) async throws {
        print(sessionID)
        guard let user = try await UserAccountModel.find(sessionID, on: req.db) else {
            throw Abort(.conflict)
        }
        req.auth.login(AuthenticatedUser(id: user.id!, email: user.email))
    }
}
