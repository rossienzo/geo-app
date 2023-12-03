
export interface Location {
    latitude: number;
    longitude: number;
}

export interface Fence {
    location: Location;
    radius: number;
}

export interface Accident {
    location: Location;
}

export interface ClientDTO {
    id: string;
    fence: Fence;
    accident?: Accident;
    currentLocation: Location;
}

export class Client implements ClientDTO {

	id: string;
	fence: {
        location: Location;
        radius: number;
    };
	accident?: {
        location: Location;
    };
	currentLocation: Location;

	constructor(clientDTO: ClientDTO) {
		this.id = clientDTO.id;
		this.fence = clientDTO.fence;
		clientDTO.accident && (this.accident = clientDTO.accident);
		this.currentLocation = clientDTO.currentLocation;
	}
}
