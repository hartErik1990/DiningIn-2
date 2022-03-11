/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
//  let encoder = JSONEncoder()
//  encoder.keyEncodingStrategy = .convertToSnakeCase
//  encoder.dateEncodingStrategy = .iso8601
//  
//  let decoder = JSONDecoder()
//  decoder.keyDecodingStrategy = .convertFromSnakeCase
//  decoder.dateDecodingStrategy = .iso8601
//  
//  ContentConfiguration.global.use(encoder: encoder, for: .json)
//  ContentConfiguration.global.use(decoder: decoder, for: .json)
//  
    let databaseName: String
    let databasePort: Int
    // 1
    if (app.environment == .testing) {
        databaseName = "vapor-test"
        databasePort = 5433
    } else {
        databaseName = "vapor_database"
        databasePort = 5432
    }
    
    app.databases.use(.postgres(
      hostname: Environment.get("DATABASE_HOST")
        ?? "localhost",
      port: databasePort,
      username: Environment.get("DATABASE_USERNAME")
        ?? "vapor_username",
      password: Environment.get("DATABASE_PASSWORD")
        ?? "vapor_password",
      database: Environment.get("DATABASE_NAME")
        ?? databaseName
    ), as: .psql)
    
    app.passwords.use(.bcrypt(cost: 12))
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    //app.middleware.use(ExtendPathMiddleware())
    
    /// setup sessions
    app.sessions.use(.fluent)
    app.migrations.add(SessionRecord.migration)
    app.middleware.use(app.sessions.middleware)
    
    app.migrations.add(UserAccountModelMigration())
    //add(UserAccountModelMigration())
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateDinners())
    app.migrations.add(CreateDinnerInviteePivotMigration())
    app.migrations.add(CreateTokens())
    
    app.middleware.use(UserSessionAuthenticator())
    app.http.server.configuration.hostname = "127.0.0.1"
    app.http.server.configuration.port = 9070
    
    try app.autoMigrate().wait()
    
    // register routes
    try routes(app)
}
