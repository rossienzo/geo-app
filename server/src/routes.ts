import { Router, Request, Response } from "express";
import { MQTTService } from "./services/mqtt.service";
import * as WebSocket from "ws";

const routes = Router();

const wss = new WebSocket.Server({ port: 3001 }, () => {
	console.log(`Servidor WebSocket está ouvindo na porta ${3001}`);
});

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

const mqttService = new MQTTService(wss);


routes.get("/", (req: Request, res: Response) => {
	const clientIds = mqttService.getLocationData();
	return res.render("index.ejs", {client_ids: clientIds});
});

routes.get("/client/:client_id", (req: Request, res: Response) => {
	const clientId = req.params.client_id;
	return res.render("client.ejs", {client_id: clientId});
});

routes.get("/location/:client_id", (req: Request, res: Response) => {
	const clientId = req.params.client_id;
	const locationData = mqttService.getLocationData();
	
	if (clientId in locationData) {
		res.json(locationData[clientId]);
	} else {
		res.status(404).json({ error: "client_id not found" });
	}
});

export default routes;