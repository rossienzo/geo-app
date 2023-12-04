import mqtt from "mqtt";
import * as WebSocket from "ws";
import { ClientRepository } from "../db/repositories/client";
import { ClientDTO } from "../model/client";


export class MQTTService {
	private wss: WebSocket.Server;
	private mqttClient: mqtt.MqttClient;
	private locationData: Record<string, ClientDTO> = {};
  
	constructor(wss: WebSocket.Server, loadClients?: ClientDTO[]) {
		this.mqttClient = mqtt.connect("mqtt://mqtt.eclipseprojects.io"); 
  
		this.mqttClient.on("connect", this.onConnect.bind(this));
		this.mqttClient.on("message", this.onMessage.bind(this));
		this.mqttClient.on("offline", this.onDisconnect.bind(this));
  
		this.mqttClient.subscribe("topic/location");
		this.mqttClient.subscribe("topic/accident");
		this.mqttClient.subscribe("topic/disconnection");

		this.wss = wss;

		if (loadClients) {
			this.chargeClients(loadClients);
		}

		console.log("Clientes carregados do banco de dados:", this.locationData);
	}

	public chargeClients(loadClients: ClientDTO[]) {
		// Carrega os clientes do banco de dados
		loadClients.forEach((client) => {
			this.locationData[client.id] = {
				id: client.id,
				fence: {
					location: { latitude: client.fence.location.latitude, longitude: client.fence.location.longitude }, 
					radius: client.fence.radius 
				},
				accident: client.accident || undefined,
				currentLocation: { latitude: 0, longitude: 0 },
			};

			
		});
	}
  
	private onConnect() {
		console.log("Conectado com sucesso!");
	}
  
	private async onMessage(topic: string, message: Buffer) {
		const data = JSON.parse(message.toString());
		
		// Envia a informação de acidente via websocket
		if (topic === "topic/accident") {
			this.wss.clients.forEach((client) => {
				if (client.readyState === WebSocket.OPEN) {
					client.send(this.prepareWebSocketMessage("accident", data));
				}
			});

			const parsedMessage = JSON.parse(message.toString());
			
			const clientId = parsedMessage?.client_id;
			const position = parsedMessage?.message.position;

			const clientRepository = new ClientRepository();
			clientRepository.saveAccident(clientId, position);

			const client = await clientRepository.getClientById(clientId);
			const { fence } = client;

			// Calcula a distância entre o acidente e a cerca
			const distance = Math.sqrt(Math.pow(position.latitude - fence.location.latitude, 2) + Math.pow(position.longitude - fence.location.longitude, 2));
			console.log(distance);
			if (distance > fence.radius) { 
				console.log("Acidente fora da área de cobertura");
			} else {
				console.log("Acidente dentro da área de cobertura");
			}

		}

		console.log(`topic: ${topic}`, data);

		// Detecta se o cliente se desconectou inesperadamente
		if(data.message === "client disconnected")  {
			this.removeClient(data);
			return;
		}
		
		const clientId = data.client_id;
		const latitude = data.message.position.latitude;
		const longitude = data.message.position.longitude;

		// Novo cliente conectado
		if(this.locationData[clientId] === undefined) {
			const clientData = {
				id: clientId,
				fence: {
					location: { latitude: 0, longitude: 0 }, 
					radius: 0 
				},
				accident: {},
				currentLocation: { latitude, longitude }
			};

			this.locationData[clientId] = clientData;

			// Envia a informação de conexão via websocket
			this.wss.clients.forEach((client: any) => {
				if (client.readyState === WebSocket.OPEN) {
					client.send(this.prepareWebSocketMessage("connection", data));
				}
			});

			const clientRepository = new ClientRepository();
			await clientRepository.save(clientData);
		}
		else
			this.locationData[clientId].currentLocation = {
				latitude, longitude 
			};
			
	}

	private onDisconnect() {
		console.log("Desconectado inesperadamente.");
		const clientId = this.mqttClient.options.clientId;
		this.removeClient(clientId!);
	}
	
	// Remove o cliente da lista de clientes conectados
	private removeClient(data: any) {
		const clientId = data.client_id;
		if (clientId && this.locationData[clientId]) {	
			//delete this.locationData[clientId];

			// Envia a informação de desconexão via websocket
			this.wss.clients.forEach((client) => {
				if (client.readyState === WebSocket.OPEN) {
					client.send(this.prepareWebSocketMessage("disconnection", data));
				}
			});
		}
	}

	public getLocationData(): Record<string, ClientDTO> {
		return this.locationData;
	}
	
	public getClient(): mqtt.MqttClient { 
		return this.mqttClient;
	}

	private prepareWebSocketMessage(type: string, data: any) {
		return JSON.stringify({
			"type": type, 
			"message": {
				"client_id": data.client_id, 
				"position": data.message.position 
			}
		});
	}
}
  