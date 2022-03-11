//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor
import Fluent

struct UserCredentialsAuthenticator: AsyncCredentialsAuthenticator {
    struct Credentials: Content {
        let email: String
        let password: String
    }
    
    func authenticate(credentials: Credentials, for req: Request) async throws {
        print("yayyy here")
        guard let user = try await UserAccountModel
                .query(on: req.db)
                .filter(\.$email == credentials.email)
                .first() else {
            throw Abort(.alreadyReported)
        }
        do {
            print("woohooo here")
            guard try Bcrypt.verify(credentials.password, created: user.password) else {
                throw Abort(.notAcceptable)
            }
            print("woohooo Bcrypt tried")
            req.auth.login(AuthenticatedUser(id: user.id!, email: user.email))
            print("kenny loggins")
        }
        catch {
            print("boooo Bcrypt")
            throw Abort(.badGateway)
        }
    }
}
