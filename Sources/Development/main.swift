import Core
import HTTP
import Leaf
import Routing
import Service
import Vapor

extension View: ContentEncodable, ResponseRepresentable {
    public func encodeContent(to message: Message) throws {
        message.mediaType = .html
        message.body = Body(data)
    }
}


var services = Services.default()
try services.register(Leaf.Provider())

services.register { container in
    MiddlewareConfig([
        ErrorMiddleware.self
    ])
}

let app = Application(services: services)

let async = try app.make(AsyncRouter.self)
let sync = try app.make(SyncRouter.self)

let user = User(name: "Vapor", age: 3);
async.on(.get, to: "hello") { req in
    return Future<User>(user)
}

let hello = try Response(body: "Hello, world!")
sync.on(.get, to: "plaintext") { req in
    return hello
}

let view = try app.make(ViewRenderer.self)
async.on(.get, to: "leaf") { req in
    return try view.make("/Users/tanner/Desktop/hello", context: user, for: req)
}

print("Starting server...")
try app.run()

