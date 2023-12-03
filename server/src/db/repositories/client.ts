import { DB_URL } from "../..";
import { ClientDTO } from "../../model/client";

export class ClientRepository {

	async getAllClients(): Promise<ClientDTO[]> {
		return await fetch(`${DB_URL}/clients`).then(response => response.json());
	}
    
	async getClientById(id: string): Promise<ClientDTO> {
		return await fetch(`${DB_URL}/clients/${id}`).then(response => response.json());
	}
    
	async save(): Promise<void> {
		await fetch(`${DB_URL}/clients`, { method: "POST", body: JSON.stringify(this) });
	}
    
	async delete(id: string): Promise<void> {
		await fetch(`${DB_URL}/clients/${id}`, { method: "DELETE" });
	}
}