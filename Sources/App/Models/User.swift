import Vapor
import FluentProvider
import AuthProvider

final class User: Model {
  var storage = Storage()
  var email: String
  var password: String
  
  init(email: String, password: String) {
    self.email = email
    self.password = password
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("email", email)
    try row.set("password", password)
    return row
  }
  
  init(row: Row) throws {
    self.email = try row.get("email")
    self.password = try row.get("password")
  }
}

// MARK: Fluent Preparation

extension User: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string("email")
      builder.string("password")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

// MARK: Node

extension User: NodeRepresentable {
  func makeNode(in context: Context?) throws -> Node {
    var node = Node(context)
    try node.set("id", id)
    try node.set("email", email)
    return node
  }
}

extension User: PasswordAuthenticatable {
  public var hashedPassword: String? {
    return password
  }
  public static var passwordVerifier: PasswordVerifier? {
    return MyVeryOwnPasswordVerifier()
  }
}

extension User: SessionPersistable {}

struct MyVeryOwnPasswordVerifier: PasswordVerifier {
  func verify(password: Bytes, matches hash: Bytes) throws -> Bool {
    return try BCryptHasher().verify(password: password, matches: hash)
  }
}
