import express from "express";
import routes from "./routes";
import http from "http";
import * as WebSocket from "ws";

const app = express();
const server = http.createServer(app);

const wss = new WebSocket.Server({ port: 3001 }, () => {
	console.log(`Servidor WebSocket está ouvindo na porta ${3001}`);
});
  
//const subscribers: WebSocket[] = [];


// configura o ejs	
app.set("view engine", "ejs");
app.set("views", __dirname + "/views");
app.use(express.static(`${__dirname}/public`));


app.use(express.json());
app.use(routes);

// Configuração do servidor WebSocket
wss.on("connection", (ws) => {
	console.log("Cliente WebSocket conectado");
  
	ws.on("message", (message) => {
		console.log(`Mensagem recebida do cliente WebSocket: ${message}`);

	});
  
	ws.on("close", () => {
		console.log("Cliente WebSocket desconectado");
	});
});

server.listen(3000, () => console.log(`Server running in http://localhost:${3000}`));