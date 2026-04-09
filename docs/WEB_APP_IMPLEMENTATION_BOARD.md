# FarmOS Web App Implementation Board

This document is the working backlog for the PHP web app under `app/frontend`.

Source of truth for this board:
- Frontend pages and shared frontend library under `app/frontend/pages` and `app/frontend/lib`
- Backend router in `app/backend/public/index.php`
- Existing backend controllers in `app/backend/src/Controllers`

Audit date: April 8, 2026

## Status Legend

- `working`: frontend module has a matching backend route surface and appears close to usable
- `partial`: backend exists, but route names or feature coverage do not fully match the frontend
- `missing`: frontend page exists but backend routes/controller do not exist
- `mock`: page renders fallback or demo data and needs real backend integration

## Immediate Priorities

1. Align existing modules before building new ones: auth, dashboard, inventory, financial, weather.
2. Build core admin and operations gaps next: users, settings, fields, equipment, suppliers, notifications.
3. Defer advanced feature modules until the core CRUD and admin flows are stable.

## Ticket Board

| Ticket | Module | Frontend Page | Frontend Endpoint List | Backend Status | Deliverable |
|---|---|---|---|---|---|
| WEB-01 | Auth and session consolidation | `login.php` | `/api/auth/login` | `working` | Local auth fallback removed; remaining work is runtime verification of logout/refresh/session expiry behavior. |
| WEB-02 | Dashboard route alignment | `dashboard.php` | `/api/dashboard/summary` | `working` | Summary endpoint added and aligned with the page; remaining work is live data verification. |
| WEB-03 | Livestock module | `livestock.php` | `/api/livestock/`, `/api/livestock/breeding`, `/api/livestock/events` | `working` | Livestock breeding and event compatibility endpoints are implemented and the page now tolerates API payload shape differences; remaining work is end-to-end runtime validation. |
| WEB-04 | Inventory route alignment | `inventory.php` | `/api/inventory/items`, `/api/inventory/items/`, `/api/inventory/transactions` | `working` | Frontend calls now map to the existing inventory routes and stock adjustment flow; remaining work is live verification. |
| WEB-05 | Financial route alignment | `financial.php` | `/api/financial/summary`, `/api/financial/transactions`, `/api/financial/budgets`, `/api/financial/invoices` | `working` | Budgets and invoices endpoints are implemented and wired into the page forms and tables; summary and transaction flows remain aligned. |
| WEB-06 | Tasks validation pass | `tasks.php` | `/api/tasks/` | `working` | Verify create/list/update flows and confirm task assignment and completion behavior from the UI. |
| WEB-07 | Reports and analytics | `reports.php`, `analytics.php` | `/api/reports/types`, `/api/reports/generate`, `/api/analytics/dashboard` | `working` | Validate report generation/download from UI and confirm analytics payload shape matches page expectations. |
| WEB-08 | Weather route alignment | `weather.php` | `/api/weather/current`, `/api/weather/logs` | `working` | Weather page now targets current backend observation/history routes; remaining work is live verification. |
| WEB-09 | IoT module validation | `iot.php` | `/api/iot/devices`, `/api/iot/water-quality`, `/api/iot/sensors/latest`, `/api/iot/alerts` | `working` | Validate end-to-end device, sensor, alert, and water-quality flows from the web app. |
| WEB-10 | Users management | `users.php` | `/api/users/` | `working` | Users CRUD routes are implemented; remaining work is manual verification of admin flows. |
| WEB-11 | Settings and tenancy | `settings.php` | `/api/system/`, `/api/tenants/` | `working` | Settings and tenants endpoints are implemented with persistence tables created on demand; remaining work is manual verification. |
| WEB-12 | Fields and crop management | `fields.php` | `/api/fields/`, `/api/fields/history`, `/api/fields/rotation`, `/api/fields/soil`, `/api/fields/harvest` | `working` | Fields list/create and child history, rotation, soil, and harvest endpoints are implemented; remaining work is UI/runtime validation. |
| WEB-13 | Equipment management | `equipment.php` | `/api/equipment/`, `/api/equipment` | `working` | Equipment list/create routes are implemented and normalized to the page payload shape; remaining work is UI/runtime validation. |
| WEB-14 | Suppliers management | `suppliers.php` | `/api/suppliers`, `/api/suppliers/suppliers` | `working` | Supplier list/create routes now support both the canonical and legacy page paths; remaining work is UI/runtime validation. |
| WEB-15 | Notifications | `notifications.php` | `/api/notifications/`, `/api/notifications/mark-all-read` | `working` | Notifications list, mark-all-read, and single-item mark-read endpoints are implemented; remaining work is UI/runtime validation. |
| WEB-16 | Timesheets | `timesheets.php` | `/api/timesheets/`, `/api/timesheets/stats`, `/api/timesheets/log` | `working` | Timesheet list, stats, logging, and status update endpoints are implemented; the page was also made PHP-runtime compatible. Remaining work is UI/runtime validation and API client cleanup. |
| WEB-17 | HR operations | `hr.php` | `/api/hr/sops`, `/api/hr/tasks`, `/api/hr/schedules`, `/api/hr/sops/executions`, `/api/hr/sops/run` | `working` | `HRController` is implemented for SOPs, schedules, task flows, and SOP execution tracking; remaining work is UI/runtime validation. |
| WEB-18 | Contracts | `contracts.php` | `/api/contracts/contracts` | `working` | Contract list/create routes are implemented on the legacy page path; remaining work is runtime validation and route-name normalization. |
| WEB-19 | Payments | `payments.php` | `/api/payments/methods`, `/api/payments/process` | `working` | Payment-method retrieval and payment processing endpoints are implemented; add/remove method UI remains a separate enhancement. |
| WEB-20 | Marketplace | `marketplace.php` | `/api/marketplace/listings`, `/api/marketplace/customers` | `working` | Marketplace listings and customer endpoints are implemented; future transaction/deal flow decisions can stay separate from this page. |
| WEB-21 | Sales CRM | `sales_crm.php` | `/api/sales-crm/leads`, `/api/sales-crm/forecast` | `working` | Lead and forecast endpoints are implemented for the page's current read-only CRM view; lead creation and contact workflows can be added separately. |
| WEB-22 | Compliance | `compliance.php` | `/api/compliance/requirements` | `working` | Compliance requirement list/create endpoints are implemented and mapped to the page payload; edit/audit workflows can be added separately. |
| WEB-23 | Veterinary | `veterinary.php` | `/api/veterinary/logs`, `/api/veterinary/vaccinations`, `/api/veterinary/withdrawals` | `working` | Veterinary log, vaccination, and withdrawal read endpoints are implemented for the current page; treatment entry workflows can be added separately. |
| WEB-24 | Feed inventory and milling | `feed.php` | `/api/feed/ingredients`, `/api/feed/milling-logs`, `/api/feed/calculate-pearson` | `working` | Feed ingredient list/create, milling-log list, and Pearson calculation endpoints are implemented for the current page. |
| WEB-25 | Feed formulation | `feed_formulation.php` | `/api/feed-formulation/ingredients`, `/api/feed-formulation/recent`, `/api/feed-formulation/calculate` | `working` | Dedicated feed-formulation compatibility endpoints are implemented for ingredient lookup, recent calculations, and Pearson-style formulation results. |
| WEB-26 | Production management | `production_management.php` | `/api/production-management/pest-disease`, `/api/production-management/crop-rotation` | `working` | Pest/disease reporting and crop-rotation analysis endpoints are implemented for the current read-only production management view. |
| WEB-27 | Energy management | `energy_management.php` | `/api/energy/status`, `/api/energy/loads`, `/api/energy/history` | `working` | Energy status, load-priority, and history endpoints are implemented; remaining work is runtime verification with real energy data. |
| WEB-28 | Waste operations | `waste.php` | `/api/waste/biogas`, `/api/waste/compost`, `/api/waste/manure` | `working` | Waste tracking endpoints for biogas, compost, and manure list/create flows are implemented for the current page. |
| WEB-29 | Circularity and carbon | `waste_circularity.php` | `/api/circularity/compost`, `/api/circularity/carbon`, `/api/circularity/bsf` | `working` | Circularity compost, carbon, and BSF endpoints are implemented with BSF create/list support; remaining work is production seeding to eliminate page fallback behavior in empty environments. |
| WEB-30 | Biogas monitoring | `biogas.php` | `/api/biogas/status`, `/api/biogas/zones` | `working` | Biogas system-status and zone endpoints are implemented and aligned to the current page fields; remaining work is live telemetry data verification. |
| WEB-31 | Predictive maintenance | `predictive_maintenance.php` | `/api/predictive-maintenance/alerts`, `/api/predictive-maintenance/fleet-health` | `working` | Predictive maintenance alerts and fleet health endpoints are implemented; remaining work is to seed live telemetry-backed records and remove page fallback blocks. |
| WEB-32 | Financial analytics | `financial_analytics.php` | `/api/financial-analytics/forecast`, `/api/financial-analytics/assets`, `/api/financial-analytics/roi` | `working` | Forecast, assets, and ROI analytics endpoints are implemented and aligned with page payloads; remaining work is live data population and UI validation. |
| WEB-33 | Traceability | `traceability.php` | `/api/blockchain/chain` | `working` | Traceability chain endpoint is implemented using persisted audit-style events formatted for the page timeline. |
| WEB-34 | QR inventory | `qr_inventory.php` | `/api/qr/history` | `working` | QR scan history endpoint is implemented and mapped to the page fields. |
| WEB-35 | Data import | `data_import.php` | `/api/import` | `working` | Import template download and upload processing endpoints are implemented for livestock and inventory import types. |
| WEB-36 | Weather irrigation | `weather_irrigation.php` | `/api/weather-irrigation/decision`, `/api/weather-irrigation/schedule`, `/api/weather-irrigation/moisture` | `working` | Weather-irrigation decision, schedule, and moisture endpoints are implemented with response shapes aligned to the page. |
| WEB-37 | Breeding page alignment | `breeding.php` | `/api/breeding/` | `working` | Separate breeding list/create endpoints are implemented and aligned with the current page workflow. |

## Cross-Cutting Tickets

| Ticket | Area | Scope | Deliverable |
|---|---|---|---|
| WEB-X1 | API naming normalization | Multiple pages use inconsistent route naming such as `/api/inventory/items` vs current inventory routes, `/api/contracts/contracts`, `/api/suppliers/suppliers`, and `/api/system/`. | Canonical routes are now adopted in frontend for contracts, suppliers, and system/tenants, with backend compatibility retained for legacy contract and supplier paths; remaining work is final sweep for any leftover route aliases. |
| WEB-X2 | Service worker and offline paths | The service worker cache paths were updated to the current FarmOS frontend runtime paths. | Revalidate PWA behavior under `app/frontend/public`. |
| WEB-X3 | Shared API client adoption | Some pages use raw relative `fetch` calls while others use `call_api()`. | Standardize on one web-app API access pattern. |
| WEB-X4 | Frontend cleanup | Dev-only files remain in `app/frontend` root. | Remove or quarantine test/fix/auth helper files that are not part of production runtime. |
| WEB-X5 | Frontend integration tests | Existing docs overstate readiness. | Add page-to-endpoint integration coverage for the working and partial modules first. |

## Existing Backend Coverage Reference

Implemented backend controllers today:

- `DashboardController`
- `EquipmentController`
- `FinancialController`
- `FieldsController`
- `ContractsController`
- `PaymentsController`
- `MarketplaceController`
- `SalesCRMController`
- `ComplianceController`
- `VeterinaryController`
- `FeedController`
- `FeedFormulationController`
- `ProductionManagementController`
- `WasteController`
- `PredictiveMaintenanceController`
- `FinancialAnalyticsController`
- `TraceabilityController`
- `QRInventoryController`
- `ImportController`
- `WeatherIrrigationController`
- `BreedingController`
- `InventoryController`
- `IoTController`
- `HRController`
- `LivestockController`
- `NotificationsController`
- `SuppliersController`
- `TaskController`
- `SystemController`
- `TimesheetsController`
- `UsersController`
- `WeatherController`
- `CircularityController`
- `BiogasController`
- `AccountingPlatformController`
- `InventoryPlatformController`
- `LivestockPlatformController`

That makes the current web app best supported in these areas:

- auth
- livestock
- inventory
- tasks
- dashboard/reporting/analytics
- weather
- IoT
- users and settings
- fields and equipment
- notifications
- suppliers
- timesheets
- HR operations
- contracts
- payments
- marketplace
- sales CRM
- compliance
- veterinary
- feed inventory and milling
- feed formulation
- production management
- energy management
- waste operations
- predictive maintenance
- financial analytics
- traceability
- QR inventory
- data import
- weather irrigation
- breeding
- circularity and carbon
- biogas monitoring
- full accounting APIs (chart of accounts, journal entries, trial balance, receivables, payables)
- advanced inventory APIs (warehouses, stock movements, transfers, valuation, reorder)
- advanced livestock APIs (health records, reproduction cycles, production logs, vaccination schedule)

## Platform Expansion APIs (April 9, 2026)

Added enterprise API surfaces for finance, inventory, and livestock platform depth:

- Accounting platform
	- `GET/POST /api/accounting/accounts`
	- `GET/POST /api/accounting/journal-entries`
	- `GET /api/accounting/trial-balance`
	- `GET/POST /api/accounting/receivables`
	- `GET/POST /api/accounting/payables`
- Inventory platform
	- `GET/POST /api/inventory-platform/warehouses`
	- `GET/POST /api/inventory-platform/movements`
	- `POST /api/inventory-platform/transfers`
	- `GET /api/inventory-platform/valuation`
	- `GET /api/inventory-platform/reorder`
- Livestock platform
	- `GET/POST /api/livestock-platform/health`
	- `GET/POST /api/livestock-platform/reproduction`
	- `GET/POST /api/livestock-platform/production`
	- `GET/POST /api/livestock-platform/vaccinations`

Frontend integration progress for platform APIs:

- `financial.php` now renders accounting platform data (trial balance totals/accounts and AP/AR aging snapshot).
- `inventory.php` now renders inventory platform data (warehouses, valuation totals, and reorder recommendations).
- `livestock.php` now renders livestock platform operational summaries and vaccination schedule view.
- Operational create workflows are now wired in these pages:
	- `financial.php`: create chart-of-account records, post balanced two-line journal entries, create receivables/payables.
	- `inventory.php`: create warehouses, post inventory-platform movements, and execute warehouse-to-warehouse transfers.
	- `livestock.php`: create health records, reproduction cycles, production logs, and vaccination schedule entries.
- Inventory platform UX was further improved with reorder-table quick restock actions and a recent movement ledger panel, plus inline page notices replacing alert-heavy failure handling.
- UX notification handling is now standardized in `financial.php`, `inventory.php`, and `livestock.php` using inline notice banners for error/info feedback during platform-form operations.
- Cross-module notification standard is now enforced at shared layout level (`components/header.php` + `components/footer.php`): all modules receive a global inline notice area, `window.AppNotice` helper methods, online/offline status notices, and alert-to-inline fallback for legacy pages.
- Cross-module form-quality guard is now active in shared footer logic: invalid HTML form submissions are intercepted, native field validation is surfaced, and a consistent warning notice is shown before any API request.
- Route-contract normalization pass completed for canonical API naming: trailing-slash drift was removed in key modules (`breeding`, `livestock`, `equipment`, `users`, `fields`, `timesheets`, `notifications`) and relative fetch usage was normalized to `API_BASE_URL` in `suppliers` and `timesheets`.
- Deprecated router compatibility aliases removed from `app/backend/public/index.php` for `/api/suppliers/suppliers` and `/api/contracts/contracts`; canonical routes `/api/suppliers` and `/api/contracts` remain the single supported contracts.
- Enterprise RBAC foundation implemented in backend scope: role templates, granular permission catalog, per-user allow/deny overrides, and farm-aware effective-permission resolution via `AccessControlService`.
- Permission-enforced management APIs added: `GET /api/access/catalog`, `GET /api/users/{id}/access`, `PUT /api/users/{id}/role`, `PUT|POST /api/users/{id}/permissions`; `/api/auth/me` now returns effective permissions for the active farm.
- Middleware and controller authorization upgraded from coarse admin-only checks to named permission checks for user and system administration surfaces.
- RBAC governance hardening added: super-admin lockout protections (cannot remove last active super_admin), restricted super_admin assignment/mutation rules, and full access-change audit trail persisted in `access_audit_log`.
- New access-audit endpoint added: `GET /api/access/audit`.
- `users.php` now includes an Access modal for role assignment and granular permission override management using the new RBAC APIs.
- Named-permission enforcement was expanded to additional high-risk controllers: accounting platform, inventory platform, livestock platform, compliance, contracts, suppliers, payments, and financial analytics now validate `PermissionMiddleware` permissions (`accounting.*`, `inventory.*`, `livestock.*`, `compliance.*`, `marketplace.*`, `financial.*`, `analytics.read`) before processing requests.
- RBAC enforcement expansion wave 2 completed: HR, timesheets, veterinary, feed, production management, and waste controllers now enforce named permissions via `PermissionMiddleware` with read/write splits (`tasks.*`, `livestock.read`, `inventory.*`, `reports.read`, `compliance.*`) before business logic execution.
- Mobile app alignment completed for RBAC and platform expansion: endpoint map now includes access-control and platform APIs; auth user state now hydrates permission sets from `/api/auth/me`; mobile Users module now supports role assignment, permission overrides, and access-audit viewing against `/api/access/*` and `/api/users/{id}/*` contracts.
- Mobile navigation and module visibility are now permission-aware (router redirects + More menu gating) for users/reports/analytics/settings/notifications using effective permission checks.
- Mobile operational screens now surface platform snapshots: inventory platform (warehouses/value/reorder), accounting platform (trial-balance state + open AR/AP), and livestock platform (health/reproduction/production/vaccination summaries).
- Mobile Notifications module is now fully integrated with backend contracts: list notifications (`GET /api/notifications`), mark single read (`POST /api/notifications/{id}/mark-read`), and mark all read (`POST /api/notifications/mark-all-read`), including permission-aware UI handling.
- Mobile Timesheets module is now integrated end-to-end with backend contracts: list (`GET /api/timesheets`), stats (`GET /api/timesheets/stats`), log hours (`POST /api/timesheets/log`), and status updates (`PUT /api/timesheets/{id}/status`), with permission-aware route/menu gating and in-screen action controls.
- Mobile Veterinary module is now integrated end-to-end with backend contracts: treatment logs list/create (`GET|POST /api/veterinary/logs`), treatment status updates (`PUT /api/veterinary/logs/{id}/status`), vaccination schedule list/create (`GET|POST /api/veterinary/vaccinations`), and withdrawal windows (`GET /api/veterinary/withdrawals`), including permission-aware route/menu gating and in-screen action controls.
- Mobile HR module is now integrated with backend contracts: SOP list/create (`GET|POST /api/hr/sops`), HR task list/create (`GET|POST /api/hr/tasks`), schedule list/create (`GET|POST /api/hr/schedules`), SOP execution history (`GET /api/hr/sops/executions`), and SOP run submissions (`POST /api/hr/sops/run`), with permission-aware route/menu gating and in-screen action controls.
- Mobile Feed module is now integrated with backend contracts: ingredient list/create (`GET|POST /api/feed/ingredients`), milling-log list (`GET /api/feed/milling-logs`), and Pearson feed calculation (`POST /api/feed/calculate-pearson`), with permission-aware route/menu gating and in-screen action controls.

## Recommended Build Order

### Phase 1: Route Alignment and Core Reliability

1. `WEB-01` Auth and session consolidation
2. `WEB-02` Dashboard route alignment
3. `WEB-04` Inventory route alignment
4. `WEB-05` Financial route alignment
5. `WEB-08` Weather route alignment
6. `WEB-X2` Service worker and offline paths
7. `WEB-X3` Shared API client adoption

### Phase 2: Core Admin and Operations

1. `WEB-10` Users management
2. `WEB-11` Settings and tenancy
3. `WEB-12` Fields and crop management
4. `WEB-13` Equipment management
5. `WEB-14` Suppliers management
6. `WEB-15` Notifications
7. `WEB-16` Timesheets

### Phase 3: Extended Operations and Finance

1. `WEB-17` HR operations
2. `WEB-18` Contracts
3. `WEB-19` Payments
4. `WEB-24` Feed inventory and milling
5. `WEB-25` Feed formulation
6. `WEB-26` Production management

### Phase 4: Advanced and Specialized Modules

1. `WEB-20` Marketplace
2. `WEB-21` Sales CRM
3. `WEB-22` Compliance
4. `WEB-23` Veterinary
5. `WEB-27` Energy management
6. `WEB-28` Waste operations
7. `WEB-29` Circularity and carbon
8. `WEB-30` Biogas monitoring
9. `WEB-31` Predictive maintenance
10. `WEB-32` Financial analytics
11. `WEB-33` Traceability
12. `WEB-34` QR inventory
13. `WEB-35` Data import
14. `WEB-36` Weather irrigation
15. `WEB-37` Breeding page alignment

## Completion Criteria

A ticket is done only when all of the following are true:

1. The frontend page no longer depends on mock or fallback data for its primary workflow.
2. Every route used by the page exists in `app/backend/public/index.php` and is backed by controller logic.
3. The route names are consistent between frontend and backend.
4. Authentication and tenant handling are consistent with the rest of the web app.
5. The page has at least one integration test or verified manual test path documented.
