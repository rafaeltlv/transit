use actix_web::{HttpServer, App, web, HttpResponse};

// Sample route handler
async fn index() -> HttpResponse {
    HttpResponse::Ok().body("Hello, world!")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(index))  // Sample route
            // Add more routes and configurations as needed
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}
