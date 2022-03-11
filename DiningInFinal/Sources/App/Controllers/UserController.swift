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

import Vapor
import Fluent

struct UserSignup: Content {
  let username: String
  let password: String
}

struct NewSession: Content {
  let token: String
  let user: UserAccountModel.Public
}

extension UserSignup: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: !.empty)
    validations.add("password", as: String.self, is: .count(6...))
  }
}
 struct Input: Decodable {
    let email: String?
     let name: String?
    let password: String?
}

struct UserUpdate: Decodable {
    //let email: String
    let name: String
    let id: String
    enum CodingKeys: String, CodingKey {
      //  case email = "email"
        case name = "name"
        case id = "id"
    }
}
struct UserController: RouteCollection {
    
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("users")
      //let userAccountsRoute = routes.grouped("userAccounts")
   // usersRoute.post("signup", use: create)
    
      usersRoute.post("signup", use: createWith)
      let credentials = usersRoute.grouped(UserCredentialsAuthenticator())
      credentials.post("login", use: signInAction)

      
    let tokenProtected = usersRoute.grouped(Token.authenticator())
    tokenProtected.get("me", use: getMyOwnUser)
      let protected = routes.grouped([
          UserSessionAuthenticator(),
          UserBearerAuthenticator()])
      let protectedRoute = protected.grouped("users")
      let updteRoute = protectedRoute.grouped("update")
      updteRoute.put(use: updateName)
      
//    let passwordProtected = usersRoute.grouped(User.authenticator())
//    passwordProtected.post("login", use: login)
     // let credentials = userAccountsRoute.grouped(UserCredentialsAuthenticator())
     

  }

//  fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
//    try UserSignup.validate(content: req)
//    let userSignup = try req.content.decode(UserSignup.self)
//    let user = try User.create(from: userSignup)
//    var token: Token!
//
//    return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
//      guard !exists else {
//          return req.eventLoop.future(error: Abort(.conflict))
//      }
//
//      return user.save(on: req.db)
//    }.flatMap {
//      guard let newToken = try? user.createToken(source: .signup) else {
//        return req.eventLoop.future(error: Abort(.internalServerError))
//      }
//      token = newToken
//      return token.save(on: req.db)
//    }.flatMapThrowing {
//      NewSession(token: token.value, user: try user.asPublic())
//    }
//  }
    fileprivate func createWith(req: Request) async throws -> Response {
        let input = try req.content.decode(Input.self)
        print(input)
        print(req)
        guard let email = input.email else { throw Abort(.conflict) }
        print(email)
        guard let name = input.name else { throw Abort(.badGateway) }
        print(name)
        guard let password = input.password else { throw Abort(.badGateway) }
        print(password)
        let digest = try await req.password.async.hash(password)
        print(digest)
        let user = UserAccountModel.create(from: email, name: name, pashwordDigest: digest)
        //(email: email, password: try Bcrypt.hash(password))
        print(user)
        let checkIfUniqueUser = try await checkIfUserExists(email, req: req)
        print(checkIfUniqueUser)
        if checkIfUniqueUser {
            try await user.create(on: req.db)
            print("complete")
            return Response(status: .ok, body: .init(string: "hello"))
        } else {
            throw Abort(.alreadyReported)
        }
//        return user.save(on: req.db)
//        return checkIfUserExists(email, req: req).flatMap { exists in
//            guard !exists else {
//                return req.eventLoop.future(error: Abort(.conflict))
//            }
//        }
        //      try UserSignup.validate(content: req)
        //      let userSignup = try req.content.decode(UserSignup.self)
      //let user = try User.create(from: userSignup)
//      var token: Token!
//
//      return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
//        guard !exists else {
//            return req.eventLoop.future(error: Abort(.conflict))
//        }
//
//        return user.save(on: req.db)
//      }.flatMap {
//        guard let newToken = try? user.createToken(source: .signup) else {
//          return req.eventLoop.future(error: Abort(.internalServerError))
//        }
//        token = newToken
//        return token.save(on: req.db)
//      }.flatMapThrowing {
//        NewSession(token: token.value, user: try user.asPublic())
//      }
    }
    
    func signInAction(_ req: Request) async throws -> NewSession {
        if let user = req.auth.get(AuthenticatedUser.self) {
            print("Poop")
            req.session.authenticate(user)
            print("yay it worked")
           // return req.redirect(to: "/")
        }
       // let user: UserAccountModel = try req.auth.require(UserAccountModel.self)
        let input = try req.content.decode(Input.self)
        print(input)
        guard let email = input.email else { throw Abort(.badRequest)}
        print(email)
        guard let password = input.password else { throw Abort(.badRequest)}
        print(password)
        guard let model = try await firstModel(email, req: req) else { throw Abort(.badRequest)}
        print(model)
        let result = try await req.password.async.verify(password, created: model.password)
        print(result)
        let token = try model.createToken(source: .login)
        try await token.save(on: req.db)
        req.auth.login(model)
        return NewSession(token: token.value, user: try model.asPublic())
//            .flatMapThrowing {
//            NewSession(token: token.value, user: try user.asPublic())
//        }
       // return Response(status: .ok, body: .init(string: "hello"))
        //if result {
           
            /// the user is authenticated, we can store the user data inside the session too
//            if let user = req.auth.get(AuthenticatedUser.self) {
//                req.session.authenticate(user)
//                let thevc = req.redirect(to: "/")
//                print(thevc)
//                return thevc
//            }
//        } else {
//            throw Abort(.badRequest)
//        }
        /// if the user credentials were wrong we render the form again with an error message
       // let input = try req.content.decode(Input.self)

    }
    
    func getModelID(_ req: Request) throws -> UUID {
        guard let id = req.parameters.get("id") else {
            throw Abort(.notFound)
        }
        guard let uuid = UUID(uuidString: id) else {
            throw Abort(.notFound)
        }
        return uuid
    }
    
    func getHandler(_ req: Request) async throws -> UserAccountModel {
        let id = try getModelID(req)
        guard let userAccountModel = try await UserAccountModel.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return userAccountModel
    }
    
    func updateName(_ req: Request) async throws -> HTTPStatus {
        guard let token = try await Self.checkAccessToken(req: req) else {
            return .notFound
        }
        let input = try req.content.decode(UserUpdate.self)
        print("yayy made it")
       // let userAccountModel = try await getHandler(req)
        print("here too yayy yayy made it")
        print(token)
        token.name = input.name
        print(token)
        try await token.save(on: req.db)
        print("yaaa it saved it")
        return .ok

    }
    
    fileprivate func login(req: Request) async throws -> User.Public {
      do {
         // let gettin = try req.auth.get()
          let id = UUID(uuidString: "BD0019AE-A231-4360-B303-17E25D6CE374")
          guard let getting = try await User.find(id, on: req.db) else {
              throw Abort(.notFound)
          }
          let that = try req.content.decode(UserSignup.self)
          
          debugPrint(req)
          let passHash = that.password
          let bCrypt = try Bcrypt.hash(passHash)
          //BCryptDigest().hash(that.password)
          print(bCrypt)
          print(getting.passwordHash)
          if bCrypt.isEqual(getting.passwordHash) {
              print("true")
          }
         // debugPrint(gettin)
          debugPrint(getting)
          return try getting.asPublic()
         // let user = try req.auth.require(User.self)
//          do {
       
//          } catch {
//              throw Abort(.conflict)
//          }
      } catch {
          throw Abort(.ok)
      }
  }

  func getMyOwnUser(req: Request) throws -> User.Public {
    try req.auth.require(User.self).asPublic()
  }
    
    private func checkIfUserExists(_ email: String, req: Request) async throws -> Bool {
        let model = try await firstModel(email, req: req)
        return model == nil
    }
    
    private func firstModel(_ email: String, req: Request) async throws -> UserAccountModel? {
        return try await UserAccountModel.query(on: req.db)
            .filter(\.$email == email)
            .first()
    }
    
    static func checkAccessToken(req: Request) async throws -> UserAccountModel? {
        guard let bearerAuthorization = req.headers.bearerAuthorization else {
            // Works fine
            print("no bearer incluced")
            return nil
        }
        
        guard let token = try await Token.query(on: req.db).filter(\.$value == bearerAuthorization.token).with(\.$user).first() else {
            // Works fine
            print("no token incluced")
            return nil
        }
        print(token)
        let user = token.user
        print(user)
        return user
    }
}
