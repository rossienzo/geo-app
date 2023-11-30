import { Router, Request, Response } from "express";
import { MQTTService } from "./services/mqtt.service";

const routes = Router();

const mqttService = new MQTTService();


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