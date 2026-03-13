# Begin Masimba FarmOS: Comprehensive Software System Design & Specification

## 1. Executive Summary

**Begin Masimba FarmOS** is the central digital nervous system for the Begin Masimba Rural Home Farm. It bridges the gap between **Business Goals** (Profitability, Revenue Targets) and **Physical Engineering** (Water flow, Solar energy, Biological cycles). 

The system is designed to be **"Complete at Once,"** meaning it manages every aspect of the farm—from the voltage of the solar pump to the sale of a finished broiler chicken. It transforms the closed-loop integrated farm model into a digitally-managed ecosystem where:

- **Inputs** (Feed crops, Water, Energy, Livestock genetics) flow seamlessly
- **Processing** (Feed formulation, Animal growth, Pond management, Crop cycles) is automated and monitored
- **Outputs** (Meat, Fish, Vegetables, Compost, Biogas) are tracked and optimized
- **Financial Performance** (Revenue, Costs, Profitability) is real-time and transparent

### System Vision
Transform Begin Masimba from a **manually-managed farm** into a **data-driven, self-optimizing enterprise** that achieves:
- **70-80% Feed Self-Sufficiency** through intelligent crop-to-livestock planning
- **50-80% Cost Reduction** in largest variable costs (feed)
- **US$50,000-80,000 Annual Net Profit** (Year 2+)
- **Zero Waste** through closed-loop nutrient cycling tracking
- **100% Operational Transparency** via real-time dashboards

## 2. System Architecture Overview

### 2.1 The "Digital Twin" Concept

The software creates a **Digital Twin** of the physical farm. Every physical asset (Pond A, Broiler House 1, Solar Array, Borehole) has a digital counterpart that reflects its real-time status, historical performance, and predictive state.

**Technical Stack:**
- **Frontend**: PHP (Server-side Rendering) - Lightweight, responsive, and compatible with WAMP
- **Backend**: Pure PHP API (Composer + PHPUnit) - Simple, deployable, WAMP-friendly
- **Database**: MySQL (PDO) - Relational storage for core farm data
- **Edge Gateway**: Local Raspberry Pi/NUC controller aggregating sensor data and syncing to server
- **Offline-First**: Local caching strategies with sync capabilities
- **Security**: Role-Based Access Control (RBAC), JWT authentication, secure headers

### 2.2 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    PHYSICAL FARM LAYER                       │
│  (Sensors, Actuators, Livestock, Infrastructure, Crops)     │
└──────────────────────────┬──────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              IOT GATEWAY (Raspberry Pi/NUC)                  │
│  • Sensor Data Collection (Temperature, pH, Water Level)     │
│  • Pump/Fan Control Logic Execution                         │
│  • Local Data Caching (Offline Support)                     │
└──────────────────────────┬──────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                 BACKEND SERVER (PHP)                        │
│  • API Layer (RESTful endpoints)                             │
│  • Business Logic (Feed Formulation, Financial Calc)        │
│  • Database Synchronization                                 │
│  • Cloud Sync (Optional, when online)                       │
└──────────────────────────┬──────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│          DATABASE LAYER (In-Memory / SQL)                   │
│  • Relational Data (Batches, Inventory, Transactions)       │
│  • Time-Series Data (Sensor readings, production metrics)   │
│  • Historical Analytics & Reporting                         │
└──────────────────────────┬──────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│         FRONTEND LAYER (PHP / HTML / JS)                    │
│  • Admin Dashboard (Manager)                                │
│  • Mobile Worker View (Field Staff)                         │
│  • Monitor Interface (Real-time Dashboards)                 │
│  • Reporting Interface (Analytics & Compliance)             │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Core Design Principles

The system follows five core principles aligned with the farm's physical design:

1. **Circularity First**: All outputs become inputs elsewhere in the system (tracked digitally)
2. **Redundancy**: Critical functions have backup control pathways
3. **Modularity**: Components can be scaled or replaced independently
4. **Monitor-Act Loop**: Continuous sensing enables responsive management
5. **Simplicity Over Complexity**: Manual operations where appropriate, automation where necessary

## 3. Module Specifications & Functional Requirements

### 3.1 ADMIN & FINANCIAL COMMAND CENTER
**Goal**: Ensure the farm meets the $452,000 revenue target and $407,600 Net Profit.

*   **Financial Dashboard**:
    *   **Real-time P&L**: Tracks Income vs. Expenses daily.
    *   **Cost Granularity**: Drills down costs per batch (e.g., "Batch 42 cost $1.10/bird to raise").
    *   **Revenue Projection**: Compares current sales against the $407,600 net profit target.
    *   **Cash Flow Forecast**: Predicts upcoming expenses (feed, wages) vs expected sales.
*   **Staff Management**:
    *   Role-based access (Manager, Handler, Agronomist, Admin).
    *   Task Assignment: "Clean Solar Panels" or "Mix Feed" tasks sent to worker phones.
    *   Performance Tracking: Tasks completed vs. overdue.

## 3. Detailed Module Specifications

### 3.1 ADMIN & FINANCIAL COMMAND CENTER

**Goal**: Ensure the farm meets the US$370,000+ annual revenue target and maintains profitability trajectory.

#### A. Financial Dashboard (Real-Time P&L Tracking)
- **Revenue Tracking** (Daily):
  - Broiler Sales: 4,000/month × US$5.00/bird = US$20,000/month
  - Pork Sales: 50/month × US$100 = US$5,000/month
  - Fish Sales: 2,000/month × US$2.50 = US$5,000/month
  - Vegetable Sales: 500kg/month × US$1.50 = US$750/month
  - Compost Sales: 40 bags/month × US$5.00 = US$200/month
  - Biogas/Other: US$3,600/month
  - **Total Monthly Target**: US$30,950

- **Cost Tracking** (Granular):
  - Cost per batch: "Batch 42 cost US$1.10/bird to raise"
  - Labor costs by task and worker
  - Feed costs by ingredient and formulation
  - Utilities, maintenance, healthcare, transportation
  - Equipment depreciation

- **Real-Time KPIs**:
  - Daily Revenue vs. Budget
  - Monthly P&L comparison
  - Cost per kg produced (Broiler, Pork, Fish)
  - Feed Self-Sufficiency % (Target: 70-80%)
  - Gross Margin per product
  - Break-even tracking (Target: 14 months)

#### B. Staff Management & Task Assignment
- **Role-Based Access Control**:
  - Farm Manager: Full access to all modules
  - Livestock Supervisor: Poultry/Pig/Fish specific modules
  - Crop & Feed Supervisor: Crop, greenhouse, feed mill modules
  - General Worker: Task list and data entry only
  - Accountant: Financial modules only
  - Extension Officer (Remote): Read-only access to production data

- **Task Management System**:
  - Task creation: "Clean Solar Panels," "Mix Feed Batch 42"
  - Mobile push notifications to assigned workers
  - Task completion logging with photos/notes

### 3.2 IOT & ENVIRONMENTAL MONITORING SYSTEM

**Goal**: Automate physical control logic while providing real-time visibility.

#### A. Water Management Module (The "Pump Brain")

**Automated Control Logic**:
```
IF Tank Level < 30% 
AND Solar Voltage > 45V 
AND Time between 08:00-16:00
THEN Start Pump
ELSE Stop Pump

ALERT IF:
- Tank Level < 20% (Critical)
- Tank Level > 90% (Shut pump down)
- Solar Voltage < 40V (Insufficient power)
```

**Monitoring Dashboard**:
- **Live Tank Levels**: Real-time % full with 7-day graph
- **Water Flow Map**: Interactive SVG showing water routes
- **Daily Water Budget**:
  - Inflow: Borehole 30,000L, Rainwater ~400L
  - Outflow: Livestock 4,500L, Ponds 6,000L, Greenhouse 1,500L, Crops 15,000L, Processing 3,000L
  - Recycled water tracking
  - Deficit/Surplus indicator

- **Quality Monitoring** (Weekly):
  - Borehole: pH (6.5-8.5), Hardness, Nitrates
  - Fish Ponds: pH, DO (>4mg/L), Temperature (25-30°C), Turbidity (<50 NTU)
  - Greenhouse: Soil moisture, water quality

#### B. Energy Management Module (The "Power Monitor")

**Solar Monitor**:
- **Live PV Output**: Current power vs. Target, Daily cumulative energy, Weekly efficiency trend
- **Panel Status**: Temperature, Voltage, Current, MPPT efficiency
- **Alerts**: Alert if output drops >20% (dirty panels), Temperature >50°C

**Biogas Monitor**:
- **Daily Inputs**: Pig manure (400kg), Poultry litter (200kg), Water (200L)
- **Biogas Production**: Daily yield (m³), Methane %, Pressure, Temperature (35-40°C optimal)
- **Utilization**: Kitchen cooking (LPG replacement), Security lighting, Brooder heating

#### C. Biological Monitoring (Smart Farm Sensors)

**3C.1 Aquaculture Module (Smart Pond)**

**Sensor Inputs** (Daily/Continuous):
- **pH Level**: Target 6.5-9.0, Alert if outside range
- **Dissolved Oxygen**: Target >4 mg/L, **Critical alert if <3 mg/L** (auto-activate aerators)
- **Temperature**: Target 25-30°C, Alert if <24°C or >32°C
- **Transparency**: Visual weekly measurement

**Growth Tracking**:
- Weekly sampling: Weigh 20 fish/pond, record average
- Target: 0.5-1kg at harvest (5-6 months)
- FCR tracking: Feed input vs. weight gain
- Survival rate: Target 85%

**3C.2 Poultry Module (Smart Broiler House)**

**Environmental Monitoring** (Per house, multi-zone):
- **Temperature**:
  - Brooder (Days 1-10): 32-34°C, Alert if >35°C or <31°C
  - Grower (Days 11-28): 24-26°C
  - Finisher (Days 29-42): 20-24°C

- **Ammonia**: Target <25 ppm, **Alert if >25 ppm** (auto-trigger fans)

- **Humidity**: Target 50-70%, Alert if >75% or <40%

**Production Tracking**:
- **Batch Management**: Batch ID, date placed, house, projected harvest
- **Growth**: Weekly weighting (sample 20/house), Compare to Ross/Cobb standards
- **Vaccination**: Auto-reminders (Day 1, 7, 14, 21)
- **FCR**: Daily feed input ÷ Daily weight gain, Target <1.6
- **Mortality**: Daily count, Alert if >5%

**3C.3 Piggery Module (Smart Swine)**

**Individual Tracking**:
- **Sow ID**: Ear tag, breeding status, estrus cycle, gestation (114 days)
- **Piglet**: Birth weight, litter size, weaning age (4 weeks), post-weaning survival

**Feeding & Nutrition**:
- Gestating: 2.2kg/day 16% CP + silage
- Lactating: Ad libitum 18% CP
- Weaners: Ad libitum 21% CP
- Finishers: 2.8kg/day 17% CP + 30% silage

**Performance**:
- ADG: Target 650g/day
- FCR: Feed ÷ Weight gain
- Carcass quality

**3C.4 Greenhouse Module (Smart Hydroponics)**

**Environmental Control**:
- **Temperature**: 20-28°C target, Sensors in 3-5 zones
- **Humidity**: 60-80% target, Alert if >85% (fungal risk)

**Crop Tracking**:
- **Planting**: Succession every 2 weeks, Variety selection
- **Growth**: Height, leaf count, biomass, Days to maturity
- **Irrigation**: Manual mode or auto-trigger at <30% soil moisture

### 3.3 PRODUCTION & PROCESSING ENGINE

#### A. Feed Formulation Engine (The "Brain")

**Pearson Square Algorithm**:
```
Example: Target 22% CP for Broiler Starter
Available: Maize (9% CP), Sunflower Cake (35% CP)

Calculation:
- Difference above target: 35 - 22 = 13 parts
- Difference below target: 22 - 9 = 13 parts
- Ratio: 50% Maize + 50% Sunflower

Output: "Mix 50kg Maize + 50kg Sunflower"
```

**Workflow**:
1. Select available ingredients from inventory
2. Choose target animal & growth stage
3. System calculates mixing ratios
4. Generate Mill Work Order
5. Auto-update inventory

**Feed Types**:
- Broiler: Starter (22% CP), Grower (20% CP), Finisher (18% CP)
- Pig: Lactation (18% CP), Weaner (21% CP), Finisher (17% CP)
- Fish: Nursery (40% CP), Grow-out (30% CP)

#### B. Crop Cycle Manager (Feed Crop Planning)

**4-Year Rotation** (4 plots × 1ha):
- Year 1: Maize+Cowpea, Sorghum, Sunflower, Moringa+Legumes
- Year 2: Sorghum, Sunflower, Maize+Cowpea, Moringa+Legumes
- Year 3: Sunflower, Maize+Cowpea, Sorghum, Moringa+Legumes
- Year 4: Legumes, Moringa+Forage, Sunflower, Maize+Cowpea

**Cycle Tracking**:
- **Planting**: Date, variety, seeding rate, estimated harvest
- **Growth**: Weekly scouting, pest/disease observations
- **Harvest**: Date, yield (kg/ha), moisture, storage
- **Post-Harvest**: Drying, conditioning, processing for feed

### 3.4 INPUTS & INVENTORY MANAGEMENT

**Feed Ingredients**:
- Maize: Current stock, usage rate (kg/day), days remaining
- Sorghum, Sunflower Cake, Cowpea Meal, Moringa, Premix: Same tracking

**Livestock Inputs**:
- **Vaccines**: Newcastle, Gumboro, Marek's, Fowl Pox (Quantity, Expiry, Reorder level)
- **Medicines**: Antibiotics, antiparasitics (Usage logs, Inventory)
- **Feed Additives**: Salt, minerals, probiotics

**Procurement**:
- Auto-generate shopping lists when stock <threshold
- Supplier database (Lead time, Reliability, Pricing)
- Purchase order generation and receipt tracking

### 3.5 SALES & MARKET INTERFACE

**Customer Database**:
- Butcheries, Abattoirs, Restaurants, Farmers Markets, Cooperatives
- Contact info, Product preferences, Price agreements

**Order Management**:
- Order creation, allocation, fulfillment, delivery, payment tracking
- Customer receipt & satisfaction rating

**Product Traceability**:
- QR codes link to batch data
- Example: Scan broiler QR → Shows Batch 42 growth data, feed used, health record, harvest date

## 4. User Interface (UI) Design

### 4.1 The "Farm Cockpit" (Main Dashboard)

**Header KPIs**:
- 🐔 Total Livestock: 4,000 broilers + 50 pigs + 2,000 fish
- 💧 Tank Levels: 78% (39,000L/50,000L)
- ⚡ Solar: 8.2 kWh today (vs. 15.3 kWh target)
- 💵 Today's Revenue: US$1,200 (vs. US$1,031 target)
- ⚠️ Critical Alerts: 1 (Fish pond DO low)

**Center: Interactive Farm Map**:
- SVG showing 4 zones (Admin, Livestock, Aquaculture, Crops)
- Clickable assets: "Click Pond 1 → pH 7.3, DO 3.8mg/L, Temp 27°C"

**Activity Feed**:
- 08:00 - Pump started (Tank 29%)
- 09:30 - Feed batch FB-002 mixed (50kg)
- 10:00 - Fish fed (30kg pellets)
- 14:00 - Manure collected (100kg)

### 4.2 Mobile Worker App

**Design**: Big buttons, offline-capable, gloved-hand friendly

**Home Screen**:
- 📋 My Tasks
- 🐔 Log Data
- 🚨 Report Issue
- 📊 My Stats

**Data Entry Form** (Example):
```
FEED INPUT LOG
Date: Wed, Jan 12
Time: 10:00
House: [House 1]
Feed Type: [Starter]
Weight: [50kg]
[Submit] [Cancel]
```

## 5. Database Design

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| users | Staff | id, name, role, phone |
| livestock_batches | Animal groups | id, type, start_date, quantity |
| animal_events | Records | id, batch_id, event_type, value |
| crops | Fields | id, variety, plot_id, planting_date |
| inventory | Stock | id, item_name, quantity, reorder_level |
| feed_formulations | Recipes | id, target_protein, ingredients |
| transactions | Financial | id, type, amount, category, date |
| sensor_readings | IoT | id, sensor_id, value, timestamp |
| sales_orders | Orders | id, customer_id, product, qty, price |

## 6. Implementation Roadmap

### Phase 1: "The Nervous System" (Q1 2026)
- Local server setup + WiFi mesh
- Admin Dashboard + Inventory Module
- **Milestone**: Digital inventory live

### Phase 2: "The Senses" (Q2 2026)
- Install water/temperature/pH sensors
- Deploy Water Management Module
- Deploy Environmental Monitoring
- **Milestone**: Automated water pumping live

### Phase 3: "The Brain" (Q3 2026)
- Feed Formulation Engine
- Livestock & Crop modules
- Financial P&L tracking
- **Milestone**: First digital feed batch produced

### Phase 4: "Full Autonomy" (Q4 2026)
- Predictive analytics
- Sales order management
- QR traceability live
- **Milestone**: AI recommendations active

## 7. System Integration & Flow Fixes

### 7.1 Critical Integration Points

**Frontend-Backend Connection:**
- PHP Frontend → PHP Backend API (REST API)
- Enhanced API client with retry logic and offline fallback
- Environment-based configuration for flexible deployment

**Database Layer:**
- MySQL as primary data store
- PDO + models/query builder with proper relationships and constraints
- Schema applied from `begin_pyphp/database/schema.sql`

**Authentication Flow:**
- JWT-based authentication with role-based access control
- Session management with secure token handling
- Multi-tenant architecture support

### 7.2 Error Handling & Resilience

**API Resilience:**
- Automatic retry with exponential backoff
- Fallback data for critical dashboard functions
- Graceful degradation when backend is unavailable

**Database Resilience:**
- Connection pooling and retry logic
- Safe defaults when database queries fail
- Comprehensive error logging for debugging

**Offline Support:**
- Local caching of critical data
- Service worker for offline functionality
- Sync when connection restored

### 7.3 Startup & Deployment

**Quick Start:**
```bash
# 1. Start backend server
cd begin_pyphp/backend
composer run serve

# 2. Access frontend
http://localhost/farmos/begin_pyphp/frontend/public/

# 3. Health check
http://127.0.0.1:8001/health
```

**Environment Configuration:**
- `.env` file for all configuration variables
- Automatic environment detection (development/production)
- Flexible database connection strings

## 8. Security & Data Privacy

- **Role-Based Access**: Managers see financials, crop handlers modify crop data only
- **Encryption**: AES-256 at rest, TLS 1.3 in transit
- **Backup**: Daily automatic backup to local NAS + optional cloud
- **Audit Trail**: Every data change logged (user, timestamp, old→new value)

## 9. User Training & Adoption

- **Farm Manager**: Full system (4 hours)
- **Supervisors**: Module-specific (3 hours each)
- **Workers**: Mobile app basics (1 hour)
- **Monthly Training**: New features, best practices

## 10. Monitoring & Continuous Improvement

- **Uptime Target**: 99.5% (< 4 hours downtime/month)
- **Data Sync**: <5 minute latency from field to server
- **User Satisfaction**: Monthly survey, target 4.5/5 stars
- **Quarterly Releases**: New features and fixes

## 11. Troubleshooting Guide

### 11.1 Common Issues

**Backend Not Starting:**
- Check PHP installation and Composer dependencies
- Verify database connection in `.env`
- Ensure port 8001 is not in use

**Frontend API Errors:**
- Verify backend server is running at `127.0.0.1:8001`
- Review browser console for detailed errors

**Database Connection Issues:**
- Verify MySQL service is running
- Check database credentials in `.env`
- Ensure database `begin_masimba_farm` exists

### 11.2 Debug Mode

**Enable Debug Logging:**
```bash
# Set environment variable
set LOG_LEVEL=DEBUG

# Or edit .env file
LOG_LEVEL=DEBUG
```

**Check System Health:**
```bash
# Backend health check
curl http://127.0.0.1:8001/health

# Frontend API availability
# Check browser network tab for API calls
```

## 12. Conclusion

**Begin Masimba FarmOS** transforms the farm into a **data-driven, self-optimizing ecosystem**. By strictly adhering to physical constraints (from system_design.md, doc.md, analyse.md) and business targets, the software actively **drives** efficiency, profitability, and sustainability—not just "monitoring" the farm.

The modular architecture ensures scalability: As the farm expands to 10-20 hectares, the software scales seamlessly without redesign.

**Key Improvements Made:**
- ✅ Enhanced error handling and offline support
- ✅ Fixed database model inconsistencies
- ✅ Improved API resilience and retry logic
- ✅ Added comprehensive startup scripts
- ✅ Better environment configuration management
- ✅ Enhanced dashboard with fallback data

**Ready for Implementation: Q1 2026**
