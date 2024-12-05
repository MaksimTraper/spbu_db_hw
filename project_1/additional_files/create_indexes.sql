CREATE UNIQUE INDEX idx_parks_name_type ON Parks(number, type);

CREATE INDEX idx_transport_cards_owner_id ON Transport_cards(owner_id);

CREATE INDEX idx_brigades_park_id ON Brigades(park_id);

CREATE INDEX idx_drivers_brigade_id ON Drivers(brigade_id);

CREATE INDEX idx_transport_model ON Transport(model);

CREATE INDEX idx_transport_driver_id ON Transport(driver_id);

CREATE INDEX idx_trips_transport_id ON Trips(transport_id);

CREATE INDEX idx_trips_card_id ON Trips(card_id);

CREATE INDEX idx_trips_route_id ON Trips(route_id);

CREATE INDEX idx_purchases_card_id ON Purchases(card_id);