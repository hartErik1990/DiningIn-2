//
//  File.swift
//  
//
//  Created by Civilgistics_Labs on 2/15/22.
//

import Fluent
import Vapor

struct UserBearerAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        print(bearer.token)
        guard let bearerAuthorization = request.headers.bearerAuthorization else { return }
        print(bearerAuthorization.token)
        guard bearer.token == bearerAuthorization.token else {
            throw Abort(.notAcceptable)
        }
    }
}
