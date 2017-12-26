import AuthProvider

final class UserController {
  let drop: Droplet
  
  init(drop: Droplet) {
    self.drop = drop
  }
  
  func getRegisterView(_ req: Request) throws -> ResponseRepresentable {
    return try drop.view.make("register")
  }
  
  func postRegister(_ req: Request) throws -> ResponseRepresentable {
    
    guard
      let email = req.formURLEncoded?["email"]?.string,
      let password = req.formURLEncoded?["password"]?.string
    else {
        return "either email or password is missing"
    }
    
    guard
      try User.makeQuery().filter("email", email).first() == nil
    else {
      return "email already exists"
    }
    
    let hashedPassword = try BCryptHasher().make(password.bytes).makeString()
    let user = User(email: email, password: hashedPassword)
    try user.save()
    
    return Response(redirect: "/login")
  }
  
  func getLoginView(_ req: Request) throws -> ResponseRepresentable {
    return try drop.view.make("login")
  }
  
  func postLogin(_ req: Request) throws -> ResponseRepresentable {
  
    guard
      let email = req.formURLEncoded?["email"]?.string,
      let password = req.formURLEncoded?["password"]?.string
    else {
      return "either email or password is missing"
    }
    
    let credentials = Password(username: email, password: password)
    let user = try User.authenticate(credentials)
    
    req.auth.authenticate(user)
    
    return Response(redirect: "/profile")
  }
  
  func getProfileView(_ req: Request) throws -> ResponseRepresentable {
    
    let user: User = try req.auth.assertAuthenticated()
    return try drop.view.make("profile", ["user": try user.makeNode(in: nil)])
  }
  
  func logout(_ req: Request) throws -> ResponseRepresentable {
    try req.auth.unauthenticate()
    return Response(redirect: "/login")
  }
}
