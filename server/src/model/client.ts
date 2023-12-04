
export interface Location {
    latitude: number;
    longitude: number;
}

export interface Fence {
    location: Location;
    radius: number;
}

export interface Accident {
    location?: Location;
}

export interface ClientDTO {
    id: string;
    fence: Fence;
    accident?: Location;
    currentLocation: Location;
}
