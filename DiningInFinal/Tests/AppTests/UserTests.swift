///// Copyright (c) 2020 Razeware LLC
/////
///// Permission is hereby granted, free of charge, to any person obtaining a copy
///// of this software and associated documentation files (the "Software"), to deal
///// in the Software without restriction, including without limitation the rights
///// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
///// copies of the Software, and to permit persons to whom the Software is
///// furnished to do so, subject to the following conditions:
/////
///// The above copyright notice and this permission notice shall be included in
///// all copies or substantial portions of the Software.
/////
///// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
///// distribute, sublicense, create a derivative work, and/or sell copies of the
///// Software in any work that is designed, intended, or marketed for pedagogical or
///// instructional purposes related to programming, coding, application development,
///// or information technology.  Permission for such use, copying, modification,
///// merger, publication, distribution, sublicensing, creation of derivative works,
///// or sale is expressly withheld.
/////
///// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
///// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
///// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
///// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
///// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
///// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
///// THE SOFTWARE.
//
//@testable import App
//import XCTVapor
//import NIOFoundationCompat
//
//final class UserTests: XCTestCase {
//    let usersURI = "/users/"
//    let signupURI = "/users/signup/"
//    
//   // let nameForUser = "OMG"
//   // let userName = "Oh My God"
//    var app: Application!
//    let passwordHash = "sfrvdebwdtgbv3123421"
//    let password = "Battleship1"
//   let userName = "WallErik"
//    let nameForUser = "erik"
//    override func setUp() {
//        app = try! Application.testable()
//    }
//    
//    override func tearDown() {
//        app.shutdown()
//    }
//    
//    func testUsersCanBeRetrievedFromAPI() throws {
//        let user1 = try User.create(username: userName, passwordHash: passwordHash, on: app.db)
//        _ = try User.create(on: app.db)
//        
//        try app.test(.GET, usersURI, afterResponse: { response in
//            let users = try response.content.decode([User].self)
//            XCTAssertEqual(users.count, 2)
//           // XCTAssertEqual(users[0].name, nameForUser)
//            XCTAssertEqual(users[0].username, userName)
//            XCTAssertEqual(users[0].id, user1.id)
//        })
//    }
//    
//    func testUserCanBeSavedWithAPI() throws {
//        try app.test(.POST, signupURI, beforeRequest: { request in
//        
////            let user = try User.create(username: userName, passwordHash: passwordHash, on: app.db)
////            let createUserData = CreateUserData(name: nameForUser, userID: user.id!)
////
//           // try UserSignup.validate(content: request as? Request)
//            let userSignup = UserSignup(username: userName, password: password)
//            //let userSignup = try request.content.decode(UserSignup.self)
//            let user = try User.create(from: userSignup)
//            guard try !User.testIfUserExists(userName, on: app.db).wait() else {
//                throw Abort(.conflict)
//            }
//            
//            try request.content.encode(userSignup)
//        }, afterResponse: { response in
//            let receivedUser = try response.content.decode(NewSession.self)
//            let user = receivedUser.user
//           // XCTAssertEqual(receivedUser.name, nameForUser)
//            XCTAssertEqual(user.username, userName)
//            XCTAssertNotNil(user.id)
//            
//            try app.test(.GET, usersURI, afterResponse: { allUsersResponse in
//                let users = try allUsersResponse.content.decode([User].self)
//                XCTAssertEqual(users.count, 1)
//               // XCTAssertEqual(users[0].name, nameForUser)
//                XCTAssertEqual(users[0].username, userName)
//                XCTAssertEqual(users[0].id, receivedUser.id)
//            })
//        })
//    }
//    
//    func testGettingASingleUserFromTheAPI() throws {
//        let user = try User.create(username: userName, passwordHash: passwordHash, on: app.db)
//        
//        try app.test(.GET, "\(usersURI)\(user.id!)", afterResponse: { response in
//            let returnedUser = try response.content.decode(User.self)
//            //XCTAssertEqual(returnedUser.name, nameForUser)
//            XCTAssertEqual(returnedUser.username, userName)
//            XCTAssertEqual(returnedUser.id, user.id)
//        })
//    }
//    
//    func testUpdatingAnUser() throws {
//        let user = try User.create(username: userName, passwordHash: passwordHash, on: app.db)
//        let newUser = try User.create(on: app.db)
//        let updatedUserData = CreateUserData(name: nameForUser, userID: newUser.id!)
//        
//        try app.test(.PUT, "\(usersURI)\(user.id!)", beforeRequest: { request in
//            try request.content.encode(updatedUserData)
//        })
//        
////        try app.test(.GET, "\(usersURI)\(user.id!)", afterResponse: { response in
////            let returnedUser = try response.content.decode(User.self)
////           // XCTAssertEqual(returnedUser.name, nameForUser)
////            XCTAssertEqual(returnedUser.username, newLong)
////            XCTAssertEqual(returnedUser.$user.id, newUser.id)
////        })
//    }
//    
//    func testDeletingAnUser() throws {
//        let user = try User.create(on: app.db)
//        
//        try app.test(.GET, usersURI, afterResponse: { response in
//            let users = try response.content.decode([User].self)
//            XCTAssertEqual(users.count, 1)
//        })
//        
//        try app.test(.DELETE, "\(usersURI)\(user.id!)")
//        
//        try app.test(.GET, usersURI, afterResponse: { response in
//            let newUsers = try response.content.decode([User].self)
//            XCTAssertEqual(newUsers.count, 0)
//        })
//    }
//    
//    func testSearchUserShort() throws {
//        let user = try User.create(username: userName, passwordHash: passwordHash, on: app.db)
//        
//        try app.test(.GET, "\(usersURI)search?term=OMG", afterResponse: { response in
//            let users = try response.content.decode([User].self)
//            XCTAssertEqual(users.count, 1)
//            XCTAssertEqual(users[0].id, user.id)
//           // XCTAssertEqual(users[0].name, nameForUser)
//            XCTAssertEqual(users[0].username, userName)
//        })
//    }
//    
//    func testSearchUserLong() throws {
//        let user = try User.create(username: userName, passwordHash: passwordHash, on: app.db)
//        
//        try app.test(.GET, "\(usersURI)search?term=Oh+My+God", afterResponse: { response in
//            let users = try response.content.decode([User].self)
//            XCTAssertEqual(users.count, 1)
//            XCTAssertEqual(users[0].id, user.id)
//           // XCTAssertEqual(users[0].name, nameForUser)
//            XCTAssertEqual(users[0].username, userName)
//        })
//    }
//    
//    func testGetFirstUser() throws {
//        let user = try User.create(username: userName, passwordHash: passwordHash, on: app.db)
//        _ = try User.create(on: app.db)
//        _ = try User.create(on: app.db)
//        
//        try app.test(.GET, "\(usersURI)first", afterResponse: { response in
//            let firstUser = try response.content.decode(User.self)
//            XCTAssertEqual(firstUser.id, user.id)
//           // XCTAssertEqual(firstUser.name, nameForUser) nameForUser)
//            XCTAssertEqual(firstUser.username, userName)
//        })
//    }
//    
//
//    //  func testSortingUsers() throws {
//    //    let short2 = "LOL"
//    //    let long2 = "Laugh Out Loud"
//    //    let user1 = try User.create(username: userName, passwordHash: passwordHash, on: app.db)
//    //    let user2 = try User.create(short: short2, long: long2, on: app.db)
//    //
//    //    try app.test(.GET, "\(usersURI)sorted", afterResponse: { response in
//    //      let sortedUsers = try response.content.decode([User].self)
//    //      XCTAssertEqual(sortedUsers[0].id, user2.id)
//    //      XCTAssertEqual(sortedUsers[1].id, user1.id)
//    //    })
//    //  }
//    
////    func testGettingAnUsersUser() throws {
////        let user = try User.create(on: app.db)
////       // let user = try User.create(user: user, on: app.db)
////
////        try app.test(.GET, "\(usersURI)\(user.id!)/user", afterResponse: { response in
////            let usersUser = try response.content.decode(User.self)
////            XCTAssertEqual(usersUser.id, user.id)
////            XCTAssertEqual(usersUser.username, user.username)
////        })
////    }
//    
//    //  func testUsersCategories() throws {
//    //    let category = try Category.create(on: app.db)
//    //    let category2 = try Category.create(name: "Funny", on: app.db)
//    //    let user = try User.create(on: app.db)
//    //
//    //    try app.test(.POST, "\(usersURI)\(user.id!)/categories/\(category.id!)")
//    //    try app.test(.POST, "\(usersURI)\(user.id!)/categories/\(category2.id!)")
//    //
//    //    try app.test(.GET, "\(usersURI)\(user.id!)/categories", afterResponse: { response in
//    //      let categories = try response.content.decode([App.Category].self)
//    //      XCTAssertEqual(categories.count, 2)
//    //      XCTAssertEqual(categories[0].id, category.id)
//    //      XCTAssertEqual(categories[0].name, category.name)
//    //      XCTAssertEqual(categories[1].id, category2.id)
//    //      XCTAssertEqual(categories[1].name, category2.name)
//    //    })
//    //
//    //    try app.test(.DELETE, "\(usersURI)\(user.id!)/categories/\(category.id!)")
//    //
//    //    try app.test(.GET, "\(usersURI)\(user.id!)/categories", afterResponse: { response in
//    //      let newCategories = try response.content.decode([App.Category].self)
//    //      XCTAssertEqual(newCategories.count, 1)
//    //    })
//    //  }
//}
//
//struct CreateUserData: Content {
//  let name: String
//  let userID: UUID
//}
