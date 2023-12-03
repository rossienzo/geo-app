import { DB_URL } from "../..";
import { ClientDTO } from "../../model/client";

export class ClientRepository {

	async getAllClients(): Promise<ClientDTO[]> {
		return await fetch(`${DB_URL}/clients`).then(response => response.json());
	}
    
	async getClientById(id: string): Promise<ClientDTO> {
		return await fetch(`${DB_URL}/clients/${id}`).then(response => response.json());
	}
    
	async save(client: ClientDTO): Promise<void> {
		await fetch(`${DB_URL}/clients`, { method: "POST", body: JSON.stringify(client), headers: { "Content-Type": "application/json" } });
	}

	async saveAccident(clientId: any, location: any) {
		await fetch(`${DB_URL}/clients/${clientId}`, { method: "PATCH", body: JSON.stringify({ accident: location }), headers: { "Content-Type": "application/json" } });
	}

	async addFence(clientId: any, fence: any) {
		await fetch(`${DB_URL}/clients/${clientId}`, { method: "PATCH", body: JSON.stringify({ fence }), headers: { "Content-Type": "application/json" } });
	}
    
	async delete(id: string): Promise<void> {
		await fetch(`${DB_URL}/clients/${id}`, { method: "DELETE" });
	}
}