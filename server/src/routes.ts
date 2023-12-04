import { Request, Response, Router } from "express";
import { ClientRepository } from "./db/repositories/client";

const routes = Router();

routes.get("/", async (req: Request, res: Response) => {
	const clientIds = req.mqttService.getLocationData();
	return res.render("index.ejs", {client_ids: clientIds});
});

routes.get("/client/:client_id", async (req: Request, res: Response) => {
	const clientId = req.params.client_id;
	
	try {
		const clientRepository = new ClientRepository();
		const client = await clientRepository.getClientById(clientId);
		
		if (!client) {
			return res.status(404).json({ error: "client_id not found" });
		}

		return res.render("client.ejs", { 
			client_id: clientId,
			fence_lng: client.fence.location.longitude,
			fence_lat: client.fence.location.latitude, 
			fence_radius: client.fence.radius,
			acident_lat: client.accident!.latitude ?? 0,
			acident_lng: client.accident!.longitude ?? 0,	
		});
	} catch (error) {
		return res.status(500).json({ error: error!.message });
	}
	
});

routes.get("/location/:client_id", (req: Request, res: Response) => {
	const clientId = req.params.client_id;
	const locationData = req.mqttService.getLocationData();
	
	if (clientId in locationData) {
		res.json(locationData[clientId]);
	} else {
		res.status(404).json({ error: "client_id not found" });
	}
});

routes.post("/client/:client_id/fence", (req: Request, res: Response) => {
	const clientId = req.params.client_id;
	
	const clientRepository = new ClientRepository();
	clientRepository.addFence(clientId, req.body)
		.then(() => {
			res.json({ message: "Fence added successfully" });
			res.status(200);
		})
		.catch((error) => {
			res.status(500).json({ error: error.message });
		});
});

export default routes;