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
		this.mqttClient.on("close", this.onDisconnect.bind(this));
  
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
			this.wss.clients.forEach((client) => {
				if (client.readyState === WebSocket.OPEN) {
					client.send(data.client_id);
				}
			});
		}

		const clientId = data.client_id;
		const latitude = data.message.position.latitude;
		const longitude = data.message.position.longitude;
		console.log(data);
		this.locationData[clientId] = { latitude, longitude };
	}
  
	private onDisconnect() {
		console.log("Desconectado inesperadamente.");
		const clientId = this.mqttClient.options.clientId;
		if (clientId && this.locationData[clientId]) 
			delete this.locationData[clientId];
	}

	public getLocationData(): Record<string, { latitude: number; longitude: number }> {
		return this.locationData;
	}
	
	public getClient(): mqtt.MqttClient { 
		return this.mqttClient;
	}
}
  