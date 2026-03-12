# Begin Masimba FarmOS: Comprehensive Software System Specification

## 1. Executive Summary
**Begin Masimba FarmOS** is the central digital nervous system for the Begin Masimba Rural Home Farm. It bridges the gap between the **Business Goals** (Profitability, Sales) and the **Physical Engineering** (Water flow, Solar energy, Biological cycles). 

This system is designed to be "Complete at Once," meaning it manages every aspect of the farm: from the voltage of the solar pump to the sale of a finished broiler chicken.

## 2. System Architecture Overview

### 2.1 The "Digital Twin" Concept
The software will create a "Digital Twin" of the physical farm. Every physical asset (Pond A, Barn B, Solar Array) has a digital counterpart in the system that reflects its real-time status.

*   **Frontend**: PHP (Server-side Rendering) - Lightweight and compatible with WAMP.
*   **Backend**: Python FastAPI - High performance, asynchronous, and auto-documented.
*   **Database**: In-Memory (Prototype) / SQL Ready (SQLite/PostgreSQL).
*   **Edge Gateway**: A local Raspberry Pi controller that aggregates sensor data (from `analyse.md` specs) and syncs to the server.

---

## 3. Detailed Module Specifications

### 3.1 ADMIN & FINANCIAL COMMAND CENTER
**Goal**: Ensure the farm meets the $452,000 revenue target (`doc.md`).

*   **Financial Dashboard**:
    *   **Real-time P&L**: Tracks Income vs. Expenses daily.
    *   **Cost Granularity**: Drills down costs per batch (e.g., "Batch 42 cost $1.10/bird to raise").
    *   **Revenue Projection**: Compares current sales against the $407,600 net profit target.
*   **Staff Management**:
    *   Role-based access (Manager, Handler, Agronomist).
    *   Task Assignment: "Clean Solar Panels" or "Mix Feed" tasks sent to worker phones.

### 3.2 IOT & ENVIRONMENTAL MONITORING SYSTEM
**Goal**: Automate the physical control logic defined in `analyse.md`.

#### A. Water Management Module
*   **Logic**: Implements the `control_water_pump` algorithm.
    *   *Input*: Tank Level (%), Solar Voltage (V), Time of Day.
    *   *Action*: Auto-start pump if Level < 30% AND Voltage > 45V.
*   **Visuals**: Live map of water flow from Borehole -> Tanks -> Ponds/Greenhouse.

#### B. Energy Management Module
*   **Solar Monitor**:
    *   Tracks PV Output (Target: 15.3 kWh/day).
    *   Alerts if efficiency drops (indicating dirty panels).
*   **Biogas Monitor**:
    *   Logs Digester Input (kg Manure).
    *   Estimates Gas Production (Target: 6-8m³/day).

#### C. Biological Monitoring
*   **Aquaculture (Smart Pond)**:
    *   **Sensors**: pH (Target 6.5-8.5), Dissolved Oxygen (>4mg/L), Temperature.
    *   **Alerts**: SMS to Manager if Oxygen drops < 3mg/L (Critical).
*   **Poultry (Smart Barn)**:
    *   **Sensors**: Ammonia levels, Temperature (Zone-based), Humidity.
    *   **Logic**: Auto-trigger ventilation fans if Ammonia > 25ppm.

### 3.3 PRODUCTION & PROCESSING ENGINE
**Goal**: Optimize the "Inputs -> Processing -> Outputs" chain.

#### A. Feed Formulation Engine (The "Brain")
*   **Algorithm**: **Pearson Square Method**.
*   **Function**:
    1.  User selects available ingredients (e.g., Maize from Field C, Soya Inventory).
    2.  System calculates mixing ratios to hit 22% Protein (Broiler Starter).
    3.  Generates a "Work Order" for the mill operator.

#### B. Crop Cycle Manager
*   **Field Mapping**: Digital map of 5-10ha.
*   **Cycle Tracking**: Planting Date -> Estimated Harvest -> Actual Yield.
*   **Irrigation Control**:
    *   *Manual Mode*: "Turn on Drip Zone A for 30 mins".
    *   *Smart Mode*: Uses Soil Moisture sensors to auto-irrigate.

### 3.4 INPUTS & INVENTORY MANAGEMENT
**Goal**: Prevent stock-outs and track usage.

*   **Live Inventory**:
    *   **Feed**: Bags remaining, projected usage rate.
    *   **Medicine**: Vaccines (Newcastle, Gumboro) with Expiry Alerts.
    *   **Spare Parts**: Pump seals, Solar fuses.
*   **Procurement**: Auto-generate shopping lists when stock hits "Reorder Level".

### 3.5 SALES & MARKET INTERFACE
**Goal**: Streamline the "Output" phase.

*   **Customer Database**: Wholesalers, Local Market, Abattoirs.
*   **Order Management**: Track orders from "Placed" to "Delivered".
*   **Traceability**: QR Code generator for produce (e.g., "Scan to see this fish was raised in Pond B using Organic Feed").

---

## 4. User Interface (UI) Design

### 4.1 The "Farm Cockpit" (Main Dashboard)
*   **Top Row (KPIs)**: Total Birds (Alive), Tank Levels (%), Solar Battery (%), Today's Revenue.
*   **Center Map**: Interactive SVG map of the farm. Clicking "Pond 1" shows its pH/Temp.
*   **Activity Feed**: "Pump started at 08:00", "Batch 42 fed 50kg".

### 4.2 Mobile Worker App
*   **Simple View**: Big buttons for gloved hands.
*   **Actions**: "Log Mortality", "Log Feed Input", "Check Task".
*   **Offline Mode**: Caches data and syncs when back in WiFi range (Office).

---

## 5. Implementation Roadmap

### Phase 1: The "Nervous System" (Infrastructure)
*   Set up Local Server (Raspberry Pi/NUC) + WiFi Mesh.
*   Deploy Admin Dashboard + Inventory Module.
*   **Milestone**: Digital inventory of all assets and inputs.

### Phase 2: The "Senses" (IoT Integration)
*   Install Water Level sensors and Solar Controllers.
*   Deploy Water Management Module (Pump logic).
*   **Milestone**: Automated water pumping system live.

### Phase 3: The "Brain" (Logic & Automation)
*   Deploy Feed Formulator (Pearson Square).
*   Deploy Financial P&L tracking.
*   **Milestone**: First fully digital feed batch produced and costed.

### Phase 4: Full Autonomy
*   Integrate Biogas and Crop irrigation loops.
*   AI Analytics (Predicting yield based on weather).

## 6. Conclusion
This specification provides a complete blueprint for the **Begin Masimba FarmOS**. By strictly adhering to the physical constraints defined in `analyse.md` and the business targets in `doc.md`, this software will not just "monitor" the farm—it will actively **drive** its efficiency, profitability, and sustainability.
