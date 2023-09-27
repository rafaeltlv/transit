use actix::prelude::*;
use actix_web::{web, App, HttpServer, HttpResponse, HttpRequest, Error};
use actix_web_actors::ws;
use actix_cors::Cors;

// Ensure this is the only definition of MyWebSocket in your module
struct MyWebSocket;

impl Actor for MyWebSocket {
    type Context = ws::WebsocketContext<Self>;
}

impl StreamHandler<Result<ws::Message, ws::ProtocolError>> for MyWebSocket {
    fn handle(
        &mut self,
        msg: Result<ws::Message, ws::ProtocolError>,
        ctx: &mut Self::Context,
    ) {
        match msg {
            Ok(ws::Message::Ping(ping)) => {
                ctx.pong(&ping);
            }
            Ok(ws::Message::Text(text)) => {
                ctx.text(text);
            }
            Ok(ws::Message::Binary(bin)) => {
                ctx.binary(bin);
            }
            _ => {}
        }
    }
}

async fn ws_index(
    req: HttpRequest,
    stream: web::Payload,
) -> Result<HttpResponse, Error> {
    ws::start(MyWebSocket, &req, stream)
}

// Sample data fetch handler
async fn fetch_data() -> HttpResponse {
    let data = vec!["data1", "data2", "data3"]; // Replace with actual data fetching logic
    HttpResponse::Ok().json(data)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            // enable CORS
            .wrap(Cors::permissive())
            .route("/api/data", web::get().to(fetch_data))  // Data fetching route
            .route("/ws/", web::get().to(ws_index)) // WebSocket route
            // Add more routes and configurations as needed
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}
