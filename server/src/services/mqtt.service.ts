import mqtt from "mqtt";
import * as WebSocket from "ws";


export class MQTTService {
	private wss: WebSocket.Server;
	private mqttClient: mqtt.MqttClient;
	private locationData: Record<string, { latitude: number; longitude: number }> = {};
  
	constructor(wss: WebSocket.Server) {
		this.mqttClient = mqtt.connect("mqtt://mqtt.eclipseprojects.io"); 
  
		this.mqttClient.on("connect", this.onConnect.bind(this));
		this.mqttClient.on("message", this.onMessage.bind(this));
		this.mqttClient.on("offline", this.onDisconnect.bind(this));
  
		this.mqttClient.subscribe("topic/location");
		this.mqttClient.subscribe("topic/accident");
		this.mqttClient.subscribe("topic/disconnection");

		this.wss = wss;
	}
  
	private onConnect() {
		console.log("Conectado com sucesso!");
	}
  
	private onMessage(topic: string, message: Buffer) {
		const data = JSON.parse(message.toString());
		
		// Envia a informação de acidente via websocket
		if (topic === "topic/accident") {
			//const message = {"type": "accident", "message": {"client_id": data.client_id, "position": data.message.position }};
			this.wss.clients.forEach((client) => {
				if (client.readyState === WebSocket.OPEN) {
					client.send(this.prepareWebSocketMessage("accident", data));
				}
			});
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

		if(this.locationData[clientId] === undefined) {
			this.locationData[clientId] = { latitude, longitude };

			// Envia a informação de conexão via websocket
			this.wss.clients.forEach((client) => {
				if (client.readyState === WebSocket.OPEN) {
					client.send(this.prepareWebSocketMessage("connection", data));
				}
			});
		}
		else
			this.locationData[clientId] = { latitude, longitude };
			
	}

	private onDisconnect() {
		console.log("Desconectado inesperadamente.");
		const clientId = this.mqttClient.options.clientId;
		this.removeClient(clientId!);
	}
	
	private removeClient(data: any) {
		const clientId = data.client_id;
		if (clientId && this.locationData[clientId]) {
			delete this.locationData[clientId];

			// Envia a informação de desconexão via websocket
			this.wss.clients.forEach((client) => {
				if (client.readyState === WebSocket.OPEN) {
					client.send(this.prepareWebSocketMessage("disconnection", data));
				}
			});
		}
	}

	public getLocationData(): Record<string, { latitude: number; longitude: number }> {
		return this.locationData;
	}
	
	public getClient(): mqtt.MqttClient { 
		return this.mqttClient;
	}

	prepareWebSocketMessage(type: string, data: any) {
		return JSON.stringify({
			"type": type, 
			"message": {
				"client_id": data.client_id, 
				"position": data.message.position 
			}
		});
	}
}
  