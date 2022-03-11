//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor
import Fluent

final class UserAccountModel: Model {
    
    struct Public: Content {
        let email: String
        let name: String
        let id: UUID
        let createdAt: Date?
        let updatedAt: Date?
    }
    
    func asPublic() throws -> Public {
        Public(email: email,
               name: name,
               id: try requireID(),
               createdAt: createdAt,
               updatedAt: updatedAt)
    }
    
    static let schema: String = "users"
    
    struct FieldKeys {
        struct v1 {
            static var email: FieldKey { "email" }
            static var name: FieldKey { "name" }
            static var password: FieldKey { "password" }
            static var createdAt: FieldKey { "created_at" }
            static var updatedAt: FieldKey { "updated_at" }
        }
    }
    
    @ID()
    var id: UUID?
    
    @Field(key: FieldKeys.v1.email)
    var email: String
    
    @Field(key: FieldKeys.v1.name)
    var name: String
    
    @Field(key: FieldKeys.v1.password)
    var password: String
    
    @Timestamp(key: FieldKeys.v1.createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: FieldKeys.v1.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil,
         email: String,
         name: String,
         password: String,
         createdAt: Date? = nil,
         updatedAt: Date? = nil)
    {
        self.id = id
        self.email = email
        self.name = name
        self.password = password
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static func create(from email: String, name: String, pashwordDigest: String) -> UserAccountModel {
        UserAccountModel(email: email, name: name, password: pashwordDigest)
    }
    
    func createToken(source: SessionSource) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        return try Token(userId: requireID(),
                         token: [UInt8].random(count: 16).base64, source: source, expiresAt: expiryDate)
    }
}

extension UserAccountModel: ModelAuthenticatable {
  static let usernameKey = \UserAccountModel.$email
  static let passwordHashKey = \UserAccountModel.$password
  
  func verify(password: String) throws -> Bool {
      do {
          print(self.password)
          print(password)
          return try Bcrypt.verify(password, created: self.password)
      } catch {
          throw Abort(.notAcceptable)
      }
  }
}

extension UserAccountModel: Content {
    
}

//extension UserAccountModel: SessionAuthenticatable {
//    public var sessionID: UUID { id! }
//}
