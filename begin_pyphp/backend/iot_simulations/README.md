# IoT Sensor Simulations

This directory contains scripts to simulate various IoT sensors for the FarmOS application.

## Prerequisites

- Python 3.x
- `requests` library (`pip install requests`)
- The FarmOS backend must be running at `http://localhost:8000`

## Available Simulations

The `simulate_sensors.py` script runs multi-threaded simulations for:

1.  **Field A Soil Sensor**: Simulates soil moisture and temperature.
2.  **Main Weather Station**: Simulates ambient temp, humidity, wind speed, solar radiation.
3.  **Fish Pond Monitor**: Simulates water quality (pH, DO, Turbidity).
4.  **Biogas Digester Monitor**: Simulates gas pressure, methane content, internal temp.

## Usage

Run the main simulation script:

```bash
python simulate_sensors.py
```

The script will:
1.  Check if the devices exist in the backend (using `X-Tenant-ID: 1`).
2.  Create them if they don't exist.
3.  Start sending random sensor data to `/api/iot/ingest` every few seconds.

## Customization

You can modify `simulate_sensors.py` to add more devices or change the range of simulated values in the `start_simulations` function.
