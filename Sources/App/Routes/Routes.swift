import Vapor
import AuthProvider
import Sessions

extension Droplet {
  func setupRoutes() throws {
    
    let userController = UserController(drop: self)
    get("register", handler: userController.getRegisterView)
    post("register", handler: userController.postRegister)
    get("login", handler: userController.getLoginView)
    
    let persistMW = PersistMiddleware(User.self)
    let memory = MemorySessions()
    let sessionMW = SessionsMiddleware(memory)
    let loginRoute = grouped([sessionMW, persistMW])
    loginRoute.post("login", handler: userController.postLogin)
    loginRoute.get("logout", handler: userController.logout)
    
    let passwordMW = PasswordAuthenticationMiddleware(User.self)
    let authRoute = grouped([sessionMW, persistMW, passwordMW])
    authRoute.get("profile", handler: userController.getProfileView)
  }
}
