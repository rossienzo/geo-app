import express from "express";
import routes from "./routes";
import http from "http";
import * as WebSocket from "ws";
import { MQTTService } from "./services/mqtt.service";
import cors from "cors";
import { ClientRepository } from "./db/repositories/client";

export const DB_URL = "http://localhost:3001";

declare module "express-serve-static-core" {
    interface Request {
      wss: WebSocket.Server;
      mqttService: MQTTService; // Substitua 'MQTTService' pelo tipo real do seu serviço MQTT
    }
}

const startServer = async () => {
	const app = express();
	const server = http.createServer(app);
	const wss = new WebSocket.Server({ server });

	try {
		const clientRepository = new ClientRepository();
		const loadClients = await clientRepository.getAllClients();
		const mqttService = new MQTTService(wss, loadClients);

		// configura o ejs	
		app.set("view engine", "ejs");
		app.set("views", __dirname + "/views");
		app.use(express.static(`${__dirname}/public`));
		app.use(cors());
		app.use(express.json());


		// Array para armazenar clientes WebSocket conectados
		const clients: WebSocket[] = [];

		// Configuração do servidor WebSocket
		wss.on("connection", (ws: WebSocket) => {
			console.log("Cliente WebSocket conectado");
			
			clients.push(ws);

			ws.on("message", (message) => {
				console.log(`Mensagem recebida do cliente WebSocket: ${message}`);

				// Envia a mensagem para todos os clientes conectados
				clients.forEach((client) => {
					if (client !== ws && client.readyState === WebSocket.OPEN) {
						client.send(message);
					}
				});
			});
		
			ws.on("close", () => {
				// Remove o cliente desconectado do array
				console.log("Cliente WebSocket desconectado");
				
				const index = clients.indexOf(ws);
				if (index !== -1) {
					clients.splice(index, 1);
				}
			});
		});

		// Middleware Websocket e MQTT
		app.use((req, res, next) => {
			req.wss = wss;
			req.mqttService = mqttService;
			next();
		});

		app.use(routes);

		server.listen(3000, () => console.log(`Server running in http://localhost:${3000}`));
	}
	catch (error) {
		console.error("Erro ao iniciar o servidor:", error);
	}
};

startServer();