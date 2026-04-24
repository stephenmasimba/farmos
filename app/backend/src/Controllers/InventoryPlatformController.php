<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class InventoryPlatformController
{
    protected Database $db;
    protected Request $request;
    private static bool $tablesEnsured = false;
    private static ?bool $inventoryHasFarmId = null;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    private function authorizePermission(string $permission)
    {
        $middleware = new PermissionMiddleware($this->request, $this->db, $permission);
        return $middleware->handle();
    }

    private function userId(): ?int
    {
        $user = $this->request->getUser();
        if (!$user || empty($user['user_id'])) {
            return null;
        }
        return (int) $user['user_id'];
    }

    private function farmId(): int
    {
        $input = $this->request->getBody();
        if (!empty($input['farm_id'])) {
            return (int) $input['farm_id'];
        }
        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function ensureTables(): void
    {
        if (self::$tablesEnsured) {
            return;
        }

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_warehouses (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                name VARCHAR(150) NOT NULL,
                location VARCHAR(180) NULL,
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_wh_farm_active (farm_id, is_active)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_locations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                warehouse_id INT NOT NULL,
                code VARCHAR(60) NOT NULL,
                name VARCHAR(150) NOT NULL,
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_location (warehouse_id, code),
                INDEX idx_locations_farm_wh (farm_id, warehouse_id, is_active)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_lots (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                item_id INT NOT NULL,
                lot_number VARCHAR(80) NOT NULL,
                expiry_date DATE NULL,
                received_at DATETIME NULL,
                supplier VARCHAR(180) NULL,
                notes VARCHAR(255) NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_lot (farm_id, item_id, lot_number),
                INDEX idx_lots_item_expiry (farm_id, item_id, expiry_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_serials (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                item_id INT NOT NULL,
                serial_number VARCHAR(120) NOT NULL,
                lot_id BIGINT NOT NULL DEFAULT 0,
                warehouse_id INT NOT NULL DEFAULT 0,
                location_id INT NOT NULL DEFAULT 0,
                status VARCHAR(30) NOT NULL DEFAULT "in_stock",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_serial (farm_id, serial_number),
                INDEX idx_serials_item_status (farm_id, item_id, status)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_stock_levels (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                warehouse_id INT NOT NULL,
                item_id INT NOT NULL,
                qty_on_hand DECIMAL(14,3) NOT NULL DEFAULT 0,
                qty_reserved DECIMAL(14,3) NOT NULL DEFAULT 0,
                reorder_point DECIMAL(14,3) NOT NULL DEFAULT 0,
                reorder_qty DECIMAL(14,3) NOT NULL DEFAULT 0,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_stock_level (warehouse_id, item_id),
                INDEX idx_stock_farm_item (farm_id, item_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_stock_positions (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                warehouse_id INT NOT NULL,
                location_id INT NOT NULL DEFAULT 0,
                item_id INT NOT NULL,
                lot_id BIGINT NOT NULL DEFAULT 0,
                serial_id BIGINT NOT NULL DEFAULT 0,
                qty_on_hand DECIMAL(14,3) NOT NULL DEFAULT 0,
                qty_reserved DECIMAL(14,3) NOT NULL DEFAULT 0,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_pos (farm_id, warehouse_id, location_id, item_id, lot_id, serial_id),
                INDEX idx_pos_item (farm_id, item_id),
                INDEX idx_pos_wh (farm_id, warehouse_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_movements (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                warehouse_id INT NULL,
                item_id INT NOT NULL,
                movement_type VARCHAR(20) NOT NULL,
                quantity DECIMAL(14,3) NOT NULL,
                unit_cost DECIMAL(14,4) NOT NULL DEFAULT 0,
                reference_no VARCHAR(80) NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_movements_farm_date (farm_id, created_at),
                INDEX idx_movements_item (item_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_ledger (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                warehouse_id INT NOT NULL DEFAULT 0,
                location_id INT NOT NULL DEFAULT 0,
                item_id INT NOT NULL,
                lot_id BIGINT NOT NULL DEFAULT 0,
                serial_id BIGINT NOT NULL DEFAULT 0,
                entry_type VARCHAR(40) NOT NULL,
                qty_delta DECIMAL(14,3) NOT NULL,
                unit_cost DECIMAL(14,4) NOT NULL DEFAULT 0,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                reference_type VARCHAR(40) NULL,
                reference_id VARCHAR(80) NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_ledger_farm_date (farm_id, created_at),
                INDEX idx_ledger_item (farm_id, item_id, created_at),
                INDEX idx_ledger_ref (reference_type, reference_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_item_costing (
                farm_id INT NOT NULL,
                item_id INT NOT NULL,
                method VARCHAR(20) NOT NULL DEFAULT "wavg",
                standard_cost DECIMAL(14,4) NOT NULL DEFAULT 0,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (farm_id, item_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_item_cost_state (
                farm_id INT NOT NULL,
                item_id INT NOT NULL,
                avg_cost DECIMAL(14,4) NOT NULL DEFAULT 0,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (farm_id, item_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_cost_layers (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                item_id INT NOT NULL,
                warehouse_id INT NOT NULL DEFAULT 0,
                lot_id BIGINT NOT NULL DEFAULT 0,
                received_at DATETIME NOT NULL,
                qty_received DECIMAL(14,3) NOT NULL,
                qty_remaining DECIMAL(14,3) NOT NULL,
                unit_cost DECIMAL(14,4) NOT NULL,
                reference_type VARCHAR(40) NULL,
                reference_id VARCHAR(80) NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_layers_item (farm_id, item_id, warehouse_id, received_at),
                INDEX idx_layers_remaining (farm_id, item_id, qty_remaining)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_cogs (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                item_id INT NOT NULL,
                warehouse_id INT NOT NULL DEFAULT 0,
                lot_id BIGINT NOT NULL DEFAULT 0,
                qty DECIMAL(14,3) NOT NULL,
                total_cost DECIMAL(14,4) NOT NULL,
                unit_cost DECIMAL(14,4) NOT NULL,
                reference_type VARCHAR(40) NULL,
                reference_id VARCHAR(80) NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_cogs_farm_date (farm_id, created_at),
                INDEX idx_cogs_item (farm_id, item_id, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_reservations (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                warehouse_id INT NOT NULL,
                location_id INT NOT NULL DEFAULT 0,
                item_id INT NOT NULL,
                lot_id BIGINT NOT NULL DEFAULT 0,
                serial_id BIGINT NOT NULL DEFAULT 0,
                qty DECIMAL(14,3) NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "open",
                reference_type VARCHAR(40) NULL,
                reference_id VARCHAR(80) NULL,
                expires_at DATETIME NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_res_farm_status (farm_id, status, created_at),
                INDEX idx_res_item (farm_id, item_id, status)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_transfers (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                item_id INT NOT NULL,
                from_warehouse_id INT NOT NULL,
                to_warehouse_id INT NOT NULL,
                quantity DECIMAL(14,3) NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "completed",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_transfers_farm_date (farm_id, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_transfer_headers (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                from_warehouse_id INT NOT NULL,
                to_warehouse_id INT NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "draft",
                reference_no VARCHAR(80) NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                shipped_at DATETIME NULL,
                received_at DATETIME NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_transfer_hdr (farm_id, status, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_transfer_lines (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                transfer_id BIGINT NOT NULL,
                item_id INT NOT NULL,
                lot_id BIGINT NOT NULL DEFAULT 0,
                qty DECIMAL(14,3) NOT NULL,
                unit_cost DECIMAL(14,4) NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_transfer_lines (transfer_id, item_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS purchase_orders (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                supplier VARCHAR(180) NULL,
                status VARCHAR(20) NOT NULL DEFAULT "draft",
                order_date DATE NULL,
                expected_date DATE NULL,
                reference_no VARCHAR(80) NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_po_farm_status (farm_id, status, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS purchase_order_lines (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                po_id BIGINT NOT NULL,
                item_id INT NOT NULL,
                qty_ordered DECIMAL(14,3) NOT NULL,
                unit_cost DECIMAL(14,4) NOT NULL DEFAULT 0,
                qty_received DECIMAL(14,3) NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_po_lines (po_id, item_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_receipts (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                po_id BIGINT NOT NULL DEFAULT 0,
                warehouse_id INT NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "received",
                received_at DATETIME NOT NULL,
                reference_no VARCHAR(80) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_receipts (farm_id, warehouse_id, received_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_receipt_lines (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                receipt_id BIGINT NOT NULL,
                item_id INT NOT NULL,
                lot_id BIGINT NOT NULL DEFAULT 0,
                lot_number VARCHAR(80) NULL,
                expiry_date DATE NULL,
                qty_received DECIMAL(14,3) NOT NULL,
                unit_cost DECIMAL(14,4) NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_receipt_lines (receipt_id, item_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_stocktakes (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                warehouse_id INT NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "open",
                started_at DATETIME NOT NULL,
                posted_at DATETIME NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_stocktakes (farm_id, warehouse_id, status, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_stocktake_lines (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                stocktake_id BIGINT NOT NULL,
                item_id INT NOT NULL,
                lot_id BIGINT NOT NULL DEFAULT 0,
                system_qty DECIMAL(14,3) NOT NULL DEFAULT 0,
                counted_qty DECIMAL(14,3) NULL,
                variance_qty DECIMAL(14,3) NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_stocktake_lines (stocktake_id, item_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS inventory_audit_events (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                event_type VARCHAR(40) NOT NULL,
                entity_type VARCHAR(60) NOT NULL,
                entity_id VARCHAR(80) NOT NULL,
                payload_json LONGTEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_audit_farm_date (farm_id, created_at),
                INDEX idx_audit_entity (entity_type, entity_id)
            )'
        );

        self::$tablesEnsured = true;
    }

    private function currency(): string
    {
        $q = $this->request->getQuery();
        $c = trim((string) ($q['currency'] ?? ''));
        if ($c === '') {
            return 'USD';
        }
        return strtoupper(substr($c, 0, 10));
    }

    private function inventoryHasFarmId(): bool
    {
        if (self::$inventoryHasFarmId !== null) {
            return self::$inventoryHasFarmId;
        }
        try {
            $row = $this->db->queryOne("SHOW COLUMNS FROM inventory LIKE 'farm_id'");
            self::$inventoryHasFarmId = $row !== null;
        } catch (\Throwable $e) {
            self::$inventoryHasFarmId = false;
        }
        return self::$inventoryHasFarmId;
    }

    private function audit(int $farmId, string $eventType, string $entityType, string $entityId, array $payload = []): void
    {
        $userId = $this->userId();
        $this->db->execute(
            'INSERT INTO inventory_audit_events (farm_id, event_type, entity_type, entity_id, payload_json, created_by)
             VALUES (?, ?, ?, ?, ?, ?)',
            [
                $farmId,
                $eventType,
                $entityType,
                $entityId,
                json_encode($payload),
                $userId,
            ]
        );
    }

    private function ensureCostingDefaults(int $farmId, int $itemId): void
    {
        $this->db->execute(
            'INSERT IGNORE INTO inventory_item_costing (farm_id, item_id, method, standard_cost, currency) VALUES (?, ?, "wavg", 0, ?)',
            [$farmId, $itemId, $this->currency()]
        );
        $this->db->execute(
            'INSERT IGNORE INTO inventory_item_cost_state (farm_id, item_id, avg_cost) VALUES (?, ?, 0)',
            [$farmId, $itemId]
        );
    }

    private function costingMethod(int $farmId, int $itemId): array
    {
        $this->ensureCostingDefaults($farmId, $itemId);
        $row = $this->db->queryOne('SELECT method, standard_cost, currency FROM inventory_item_costing WHERE farm_id = ? AND item_id = ?', [$farmId, $itemId]);
        return $row ?: ['method' => 'wavg', 'standard_cost' => 0, 'currency' => $this->currency()];
    }

    private function recordLedger(
        int $farmId,
        int $warehouseId,
        int $locationId,
        int $itemId,
        int $lotId,
        int $serialId,
        string $entryType,
        float $qtyDelta,
        float $unitCost,
        ?string $referenceType,
        ?string $referenceId,
        ?string $notes
    ): void {
        $userId = $this->userId();
        $this->db->execute(
            'INSERT INTO inventory_ledger (farm_id, warehouse_id, location_id, item_id, lot_id, serial_id, entry_type, qty_delta, unit_cost, currency, reference_type, reference_id, notes, created_by)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                $farmId,
                $warehouseId,
                $locationId,
                $itemId,
                $lotId,
                $serialId,
                $entryType,
                $qtyDelta,
                $unitCost,
                $this->currency(),
                $referenceType,
                $referenceId,
                $notes,
                $userId,
            ]
        );
    }

    private function applyStockDelta(
        int $farmId,
        int $warehouseId,
        int $locationId,
        int $itemId,
        int $lotId,
        int $serialId,
        float $deltaOnHand,
        float $deltaReserved
    ): void {
        $warehouseId = max(0, (int) $warehouseId);
        $locationId = max(0, (int) $locationId);
        $lotId = max(0, (int) $lotId);
        $serialId = max(0, (int) $serialId);

        $row = $this->db->queryOne(
            'SELECT id, qty_on_hand, qty_reserved
             FROM inventory_stock_positions
             WHERE farm_id = ? AND warehouse_id = ? AND location_id = ? AND item_id = ? AND lot_id = ? AND serial_id = ?
             LIMIT 1',
            [$farmId, $warehouseId, $locationId, $itemId, $lotId, $serialId]
        );

        if ($row) {
            $newOnHand = (float) ($row['qty_on_hand'] ?? 0) + $deltaOnHand;
            $newReserved = (float) ($row['qty_reserved'] ?? 0) + $deltaReserved;
            if ($newOnHand < -0.0001) {
                throw new \Exception('Insufficient stock on hand');
            }
            if ($newReserved < -0.0001) {
                throw new \Exception('Reserved quantity cannot be negative');
            }
            if ($newReserved - $newOnHand > 0.0001) {
                throw new \Exception('Reserved quantity exceeds on hand');
            }
            $this->db->execute(
                'UPDATE inventory_stock_positions SET qty_on_hand = ?, qty_reserved = ? WHERE id = ?',
                [$newOnHand, $newReserved, (int) $row['id']]
            );
        } else {
            $newOnHand = $deltaOnHand;
            $newReserved = $deltaReserved;
            if ($newOnHand < -0.0001) {
                throw new \Exception('Insufficient stock on hand');
            }
            if ($newReserved < -0.0001) {
                throw new \Exception('Reserved quantity cannot be negative');
            }
            if ($newReserved - $newOnHand > 0.0001) {
                throw new \Exception('Reserved quantity exceeds on hand');
            }
            $this->db->execute(
                'INSERT INTO inventory_stock_positions (farm_id, warehouse_id, location_id, item_id, lot_id, serial_id, qty_on_hand, qty_reserved)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [$farmId, $warehouseId, $locationId, $itemId, $lotId, $serialId, $newOnHand, $newReserved]
            );
        }

        if ($warehouseId > 0) {
            $sum = $this->db->queryOne(
                'SELECT COALESCE(SUM(qty_on_hand), 0) AS qty_on_hand, COALESCE(SUM(qty_reserved), 0) AS qty_reserved
                 FROM inventory_stock_positions
                 WHERE farm_id = ? AND warehouse_id = ? AND item_id = ?',
                [$farmId, $warehouseId, $itemId]
            );
            $whOnHand = (float) ($sum['qty_on_hand'] ?? 0);
            $whReserved = (float) ($sum['qty_reserved'] ?? 0);
            $existing = $this->db->queryOne(
                'SELECT id FROM inventory_stock_levels WHERE farm_id = ? AND warehouse_id = ? AND item_id = ?',
                [$farmId, $warehouseId, $itemId]
            );
            if ($existing) {
                $this->db->execute(
                    'UPDATE inventory_stock_levels SET qty_on_hand = ?, qty_reserved = ? WHERE id = ?',
                    [$whOnHand, $whReserved, (int) $existing['id']]
                );
            } else {
                $this->db->execute(
                    'INSERT INTO inventory_stock_levels (farm_id, warehouse_id, item_id, qty_on_hand, qty_reserved, reorder_point, reorder_qty)
                     VALUES (?, ?, ?, ?, ?, 0, 0)',
                    [$farmId, $warehouseId, $itemId, $whOnHand, $whReserved]
                );
            }
        }

        if ($this->inventoryHasFarmId()) {
            $this->db->execute(
                'UPDATE inventory SET quantity = GREATEST(0, quantity + ?) WHERE farm_id = ? AND id = ?',
                [$deltaOnHand, $farmId, $itemId]
            );
        } else {
            $this->db->execute(
                'UPDATE inventory SET quantity = GREATEST(0, quantity + ?) WHERE id = ?',
                [$deltaOnHand, $itemId]
            );
        }
    }

    private function updateAvgCostOnReceipt(int $farmId, int $itemId, float $receiptQty, float $unitCost): void
    {
        $this->ensureCostingDefaults($farmId, $itemId);
        $state = $this->db->queryOne(
            'SELECT avg_cost FROM inventory_item_cost_state WHERE farm_id = ? AND item_id = ?',
            [$farmId, $itemId]
        );
        $avg = (float) ($state['avg_cost'] ?? 0);
        $qtyRow = $this->db->queryOne(
            'SELECT COALESCE(SUM(qty_on_hand), 0) AS qty_on_hand FROM inventory_stock_levels WHERE farm_id = ? AND item_id = ?',
            [$farmId, $itemId]
        );
        $oldQty = (float) ($qtyRow['qty_on_hand'] ?? 0);
        $newQty = $oldQty + $receiptQty;
        if ($newQty <= 0) {
            $newAvg = 0.0;
        } else {
            $newAvg = (($oldQty * $avg) + ($receiptQty * $unitCost)) / $newQty;
        }
        $this->db->execute(
            'UPDATE inventory_item_cost_state SET avg_cost = ? WHERE farm_id = ? AND item_id = ?',
            [$newAvg, $farmId, $itemId]
        );
    }

    private function createCostLayer(int $farmId, int $itemId, int $warehouseId, int $lotId, float $qty, float $unitCost, ?string $referenceType, ?string $referenceId): void
    {
        $this->db->execute(
            'INSERT INTO inventory_cost_layers (farm_id, item_id, warehouse_id, lot_id, received_at, qty_received, qty_remaining, unit_cost, reference_type, reference_id)
             VALUES (?, ?, ?, ?, NOW(), ?, ?, ?, ?, ?)',
            [$farmId, $itemId, $warehouseId, $lotId, $qty, $qty, $unitCost, $referenceType, $referenceId]
        );
    }

    private function consumeCostLayers(int $farmId, int $itemId, int $warehouseId, int $lotId, float $qty, string $method): array
    {
        $direction = strtolower($method) === 'lifo' ? 'DESC' : 'ASC';
        $filters = 'farm_id = ? AND item_id = ? AND warehouse_id = ? AND qty_remaining > 0';
        $params = [$farmId, $itemId, $warehouseId];
        if ($lotId > 0) {
            $filters .= ' AND lot_id = ?';
            $params[] = $lotId;
        }
        $layers = $this->db->query(
            "SELECT id, qty_remaining, unit_cost FROM inventory_cost_layers WHERE {$filters} ORDER BY received_at {$direction}, id {$direction}",
            $params
        );
        $remaining = $qty;
        $totalCost = 0.0;
        foreach ($layers as $layer) {
            if ($remaining <= 0) {
                break;
            }
            $layerQty = (float) ($layer['qty_remaining'] ?? 0);
            if ($layerQty <= 0) {
                continue;
            }
            $take = min($layerQty, $remaining);
            $unitCost = (float) ($layer['unit_cost'] ?? 0);
            $totalCost += $take * $unitCost;
            $newRemaining = $layerQty - $take;
            $this->db->execute(
                'UPDATE inventory_cost_layers SET qty_remaining = ? WHERE id = ?',
                [$newRemaining, (int) $layer['id']]
            );
            $remaining -= $take;
        }
        if ($remaining > 0.0001) {
            $fallbackCostRow = $this->db->queryOne('SELECT avg_cost FROM inventory_item_cost_state WHERE farm_id = ? AND item_id = ?', [$farmId, $itemId]);
            $fallback = (float) ($fallbackCostRow['avg_cost'] ?? 0);
            $totalCost += $remaining * $fallback;
        }
        $unit = $qty > 0 ? $totalCost / $qty : 0.0;
        return ['total_cost' => $totalCost, 'unit_cost' => $unit];
    }

    private function computeIssueCost(int $farmId, int $itemId, int $warehouseId, int $lotId, float $qty): array
    {
        $costing = $this->costingMethod($farmId, $itemId);
        $method = strtolower((string) ($costing['method'] ?? 'wavg'));
        if ($method === 'fifo' || $method === 'lifo') {
            return $this->consumeCostLayers($farmId, $itemId, $warehouseId, $lotId, $qty, $method);
        }
        if ($method === 'standard') {
            $standard = (float) ($costing['standard_cost'] ?? 0);
            if ($standard <= 0) {
                if ($this->inventoryHasFarmId()) {
                    $inv = $this->db->queryOne('SELECT cost_per_unit FROM inventory WHERE farm_id = ? AND id = ? LIMIT 1', [$farmId, $itemId]);
                } else {
                    $inv = $this->db->queryOne('SELECT cost_per_unit FROM inventory WHERE id = ? LIMIT 1', [$itemId]);
                }
                $standard = (float) ($inv['cost_per_unit'] ?? 0);
            }
            return ['total_cost' => $qty * $standard, 'unit_cost' => $standard];
        }
        $state = $this->db->queryOne('SELECT avg_cost FROM inventory_item_cost_state WHERE farm_id = ? AND item_id = ?', [$farmId, $itemId]);
        $avg = (float) ($state['avg_cost'] ?? 0);
        return ['total_cost' => $qty * $avg, 'unit_cost' => $avg];
    }

    private function recordCogs(int $farmId, int $itemId, int $warehouseId, int $lotId, float $qty, float $totalCost, float $unitCost, ?string $referenceType, ?string $referenceId): void
    {
        $this->db->execute(
            'INSERT INTO inventory_cogs (farm_id, item_id, warehouse_id, lot_id, qty, total_cost, unit_cost, reference_type, reference_id)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [$farmId, $itemId, $warehouseId, $lotId, $qty, $totalCost, $unitCost, $referenceType, $referenceId]
        );
    }

    private function ensureLot(int $farmId, int $itemId, string $lotNumber, ?string $expiryDate, ?string $supplier, ?string $notes): int
    {
        $lotNumber = trim($lotNumber);
        if ($lotNumber === '') {
            return 0;
        }
        $existing = $this->db->queryOne(
            'SELECT id FROM inventory_lots WHERE farm_id = ? AND item_id = ? AND lot_number = ? LIMIT 1',
            [$farmId, $itemId, $lotNumber]
        );
        if ($existing) {
            return (int) $existing['id'];
        }
        $this->db->execute(
            'INSERT INTO inventory_lots (farm_id, item_id, lot_number, expiry_date, received_at, supplier, notes) VALUES (?, ?, ?, ?, NOW(), ?, ?)',
            [
                $farmId,
                $itemId,
                Validation::sanitizeString($lotNumber),
                $expiryDate ?: null,
                $supplier ? Validation::sanitizeString($supplier) : null,
                $notes ? Validation::sanitizeString($notes) : null,
            ]
        );
        return (int) $this->db->lastInsertId();
    }

    public function warehouses(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'inventory.read' : 'inventory.create';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, name, location, is_active
                     FROM inventory_warehouses
                     WHERE farm_id = ?
                     ORDER BY name ASC',
                    [$farmId]
                );
                if (empty($rows)) {
                    $this->db->execute(
                        'INSERT INTO inventory_warehouses (farm_id, name, location, is_active) VALUES (?, ?, NULL, 1)',
                        [$farmId, 'Main Warehouse']
                    );
                    $rows = $this->db->query(
                        'SELECT id, name, location, is_active
                         FROM inventory_warehouses
                         WHERE farm_id = ?
                         ORDER BY name ASC',
                        [$farmId]
                    );
                }
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            $location = trim((string) ($input['location'] ?? ''));
            if ($name === '') {
                return Response::validationError(['name' => 'Warehouse name is required']);
            }

            $this->db->execute(
                'INSERT INTO inventory_warehouses (farm_id, name, location, is_active) VALUES (?, ?, ?, 1)',
                [$farmId, Validation::sanitizeString($name), $location !== '' ? Validation::sanitizeString($location) : null]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Warehouse created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle warehouses', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle warehouses', 'INVENTORY_WAREHOUSES_ERROR', 500);
        }
    }

    public function movements(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'inventory.read' : 'inventory.adjust';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, warehouse_id, item_id, movement_type, quantity, unit_cost, reference_no, notes, created_at
                     FROM inventory_movements
                     WHERE farm_id = ?
                     ORDER BY created_at DESC, id DESC
                     LIMIT 500',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $warehouseId = isset($input['warehouse_id']) ? (int) $input['warehouse_id'] : null;
            $locationId = isset($input['location_id']) && is_numeric($input['location_id']) ? (int) $input['location_id'] : 0;
            $itemId = (int) ($input['item_id'] ?? 0);
            $movementType = strtolower(trim((string) ($input['movement_type'] ?? '')));
            $quantity = $input['quantity'] ?? null;
            $unitCost = (float) ($input['unit_cost'] ?? 0);
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));
            $lotId = isset($input['lot_id']) && is_numeric($input['lot_id']) ? (int) $input['lot_id'] : 0;
            $lotNumber = trim((string) ($input['lot_number'] ?? ''));
            $expiryDate = trim((string) ($input['expiry_date'] ?? ''));
            $serialNumbers = $input['serial_numbers'] ?? null;

            $errors = [];
            if ($itemId <= 0) {
                $errors['item_id'] = 'Item ID is required';
            }
            if (!Validation::validateEnum($movementType, ['in', 'out', 'adjustment'])) {
                $errors['movement_type'] = 'Movement type must be in, out, or adjustment';
            }
            if (!is_numeric($quantity) || (float) $quantity <= 0) {
                $errors['quantity'] = 'Quantity must be positive';
            }
            if ($unitCost < 0) {
                $errors['unit_cost'] = 'Unit cost cannot be negative';
            }
            if ($expiryDate !== '' && !Validation::validateDate($expiryDate)) {
                $errors['expiry_date'] = 'Invalid date format (YYYY-MM-DD)';
            }
            if ($serialNumbers !== null && !is_array($serialNumbers)) {
                $errors['serial_numbers'] = 'serial_numbers must be an array';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            if ($lotId <= 0 && $lotNumber !== '') {
                $lotId = $this->ensureLot($farmId, $itemId, $lotNumber, $expiryDate !== '' ? $expiryDate : null, null, $notes !== '' ? $notes : null);
            }

            $qty = (float) $quantity;
            $delta = $movementType === 'out' ? -1 * $qty : $qty;

            if ($warehouseId !== null && $warehouseId > 0) {
                $this->db->beginTransaction();
                try {
                    $this->db->execute(
                        'INSERT INTO inventory_movements (farm_id, warehouse_id, item_id, movement_type, quantity, unit_cost, reference_no, notes, created_by)
                         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [
                            $farmId,
                            $warehouseId,
                            $itemId,
                            $movementType,
                            $qty,
                            $unitCost,
                            $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null,
                            $notes !== '' ? Validation::sanitizeString($notes) : null,
                            $userId,
                        ]
                    );
                    $movementId = (int) $this->db->lastInsertId();

                    if ($serialNumbers !== null && $serialNumbers !== []) {
                        $count = count($serialNumbers);
                        if (abs($qty - $count) > 0.0001) {
                            throw new \Exception('Quantity must match the number of serial numbers');
                        }
                        foreach ($serialNumbers as $snRaw) {
                            $sn = trim((string) $snRaw);
                            if ($sn === '') {
                                continue;
                            }
                            if ($movementType === 'in') {
                                $this->db->execute(
                                    'INSERT INTO inventory_serials (farm_id, item_id, serial_number, lot_id, warehouse_id, location_id, status)
                                     VALUES (?, ?, ?, ?, ?, ?, "in_stock")
                                     ON DUPLICATE KEY UPDATE warehouse_id = VALUES(warehouse_id), location_id = VALUES(location_id), status = "in_stock", lot_id = VALUES(lot_id)',
                                    [$farmId, $itemId, Validation::sanitizeString($sn), $lotId, (int) $warehouseId, $locationId]
                                );
                                $serialRow = $this->db->queryOne('SELECT id FROM inventory_serials WHERE farm_id = ? AND serial_number = ? LIMIT 1', [$farmId, $sn]);
                                $serialId = (int) ($serialRow['id'] ?? 0);
                                $this->applyStockDelta($farmId, (int) $warehouseId, $locationId, $itemId, $lotId, $serialId, 1.0, 0.0);
                                $this->recordLedger($farmId, (int) $warehouseId, $locationId, $itemId, $lotId, $serialId, 'receipt', 1.0, $unitCost, 'movement', (string) $movementId, $notes !== '' ? $notes : null);
                            } elseif ($movementType === 'out') {
                                $serialRow = $this->db->queryOne('SELECT id, warehouse_id, location_id, lot_id FROM inventory_serials WHERE farm_id = ? AND serial_number = ? LIMIT 1', [$farmId, $sn]);
                                if (!$serialRow) {
                                    throw new \Exception('Serial not found: ' . $sn);
                                }
                                $serialId = (int) ($serialRow['id'] ?? 0);
                                $wh = (int) ($serialRow['warehouse_id'] ?? $warehouseId);
                                $loc = (int) ($serialRow['location_id'] ?? $locationId);
                                $lot = (int) ($serialRow['lot_id'] ?? $lotId);
                                $this->applyStockDelta($farmId, $wh, $loc, $itemId, $lot, $serialId, -1.0, 0.0);
                                $this->db->execute('UPDATE inventory_serials SET status = "issued" WHERE id = ?', [$serialId]);
                                $cost = $this->computeIssueCost($farmId, $itemId, $wh, $lot, 1.0);
                                $this->recordCogs($farmId, $itemId, $wh, $lot, 1.0, (float) $cost['total_cost'], (float) $cost['unit_cost'], 'movement', (string) $movementId);
                                $this->recordLedger($farmId, $wh, $loc, $itemId, $lot, $serialId, 'issue', -1.0, (float) $cost['unit_cost'], 'movement', (string) $movementId, $notes !== '' ? $notes : null);
                            } else {
                                throw new \Exception('Serial handling only supported for in/out');
                            }
                        }
                    } else {
                        if ($movementType === 'in') {
                            $this->applyStockDelta($farmId, (int) $warehouseId, $locationId, $itemId, $lotId, 0, $qty, 0.0);
                            $this->recordLedger($farmId, (int) $warehouseId, $locationId, $itemId, $lotId, 0, 'receipt', $qty, $unitCost, 'movement', (string) $movementId, $notes !== '' ? $notes : null);
                            $costing = $this->costingMethod($farmId, $itemId);
                            $method = strtolower((string) ($costing['method'] ?? 'wavg'));
                            if ($method === 'fifo' || $method === 'lifo') {
                                $this->createCostLayer($farmId, $itemId, (int) $warehouseId, $lotId, $qty, $unitCost, 'movement', (string) $movementId);
                            } else {
                                $this->updateAvgCostOnReceipt($farmId, $itemId, $qty, $unitCost);
                            }
                        } elseif ($movementType === 'out') {
                            $this->applyStockDelta($farmId, (int) $warehouseId, $locationId, $itemId, $lotId, 0, -1.0 * $qty, 0.0);
                            $cost = $this->computeIssueCost($farmId, $itemId, (int) $warehouseId, $lotId, $qty);
                            $this->recordCogs($farmId, $itemId, (int) $warehouseId, $lotId, $qty, (float) $cost['total_cost'], (float) $cost['unit_cost'], 'movement', (string) $movementId);
                            $this->recordLedger($farmId, (int) $warehouseId, $locationId, $itemId, $lotId, 0, 'issue', -1.0 * $qty, (float) $cost['unit_cost'], 'movement', (string) $movementId, $notes !== '' ? $notes : null);
                        } else {
                            $this->applyStockDelta($farmId, (int) $warehouseId, $locationId, $itemId, $lotId, 0, $delta, 0.0);
                            $this->recordLedger($farmId, (int) $warehouseId, $locationId, $itemId, $lotId, 0, 'adjustment', $delta, $unitCost, 'movement', (string) $movementId, $notes !== '' ? $notes : null);
                        }
                    }
                    $this->audit($farmId, 'movement.recorded', 'inventory_movement', (string) $movementId, [
                        'movement_type' => $movementType,
                        'warehouse_id' => $warehouseId,
                        'location_id' => $locationId,
                        'item_id' => $itemId,
                        'lot_id' => $lotId,
                        'quantity' => $qty,
                    ]);
                    $this->db->commit();
                    return Response::success(['movement_id' => $movementId], 'Inventory movement recorded', 201);
                } catch (\Throwable $e) {
                    $this->db->rollback();
                    return Response::validationError(['movement' => $e->getMessage()]);
                }
            }
            $this->db->execute(
                'INSERT INTO inventory_movements (farm_id, warehouse_id, item_id, movement_type, quantity, unit_cost, reference_no, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $warehouseId,
                    $itemId,
                    $movementType,
                    $qty,
                    $unitCost,
                    $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );
            return Response::success(['movement_id' => (int) $this->db->lastInsertId()], 'Inventory movement recorded', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle inventory movements', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle movements', 'INVENTORY_MOVEMENTS_ERROR', 500);
        }
    }

    public function transfer(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.transfer');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            $input = $this->request->getBody();
            $itemId = (int) ($input['item_id'] ?? 0);
            $fromWh = (int) ($input['from_warehouse_id'] ?? 0);
            $toWh = (int) ($input['to_warehouse_id'] ?? 0);
            $quantity = $input['quantity'] ?? null;
            $lotId = isset($input['lot_id']) && is_numeric($input['lot_id']) ? (int) $input['lot_id'] : 0;
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));

            $errors = [];
            if ($itemId <= 0) {
                $errors['item_id'] = 'Item ID is required';
            }
            if ($fromWh <= 0 || $toWh <= 0 || $fromWh === $toWh) {
                $errors['warehouses'] = 'Valid source and destination warehouses are required';
            }
            if (!is_numeric($quantity) || (float) $quantity <= 0) {
                $errors['quantity'] = 'Quantity must be positive';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $qty = (float) $quantity;
            $this->db->beginTransaction();
            try {
                $this->db->execute(
                    'INSERT INTO inventory_transfer_headers (farm_id, from_warehouse_id, to_warehouse_id, status, reference_no, notes, created_by)
                     VALUES (?, ?, ?, "draft", ?, NULL, ?)',
                    [$farmId, $fromWh, $toWh, $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null, $userId]
                );
                $transferId = (int) $this->db->lastInsertId();
                $this->db->execute(
                    'INSERT INTO inventory_transfer_lines (transfer_id, item_id, lot_id, qty, unit_cost) VALUES (?, ?, ?, ?, 0)',
                    [$transferId, $itemId, $lotId, $qty]
                );

                $this->shipTransferInternal($farmId, $transferId, $userId);
                $this->receiveTransferInternal($farmId, $transferId, $userId);

                $this->db->execute(
                    'INSERT INTO inventory_transfers (farm_id, item_id, from_warehouse_id, to_warehouse_id, quantity, status, created_by)
                     VALUES (?, ?, ?, ?, ?, ?, ?)',
                    [$farmId, $itemId, $fromWh, $toWh, $qty, 'completed', $userId]
                );

                $this->audit($farmId, 'transfer.completed', 'inventory_transfer', (string) $transferId, [
                    'from_warehouse_id' => $fromWh,
                    'to_warehouse_id' => $toWh,
                    'item_id' => $itemId,
                    'lot_id' => $lotId,
                    'quantity' => $qty,
                ]);
                $this->db->commit();
                return Response::success(['id' => $transferId], 'Transfer completed', 201);
            } catch (\Throwable $e) {
                $this->db->rollback();
                return Response::validationError(['transfer' => $e->getMessage()]);
            }
        } catch (\Exception $e) {
            Logger::error('Failed to transfer stock', ['error' => $e->getMessage()]);
            return Response::error('Failed to transfer stock', 'INVENTORY_TRANSFER_ERROR', 500);
        }
    }

    private function shipTransferInternal(int $farmId, int $transferId, int $userId): void
    {
        $hdr = $this->db->queryOne('SELECT id, from_warehouse_id, to_warehouse_id, status FROM inventory_transfer_headers WHERE id = ? AND farm_id = ? LIMIT 1', [$transferId, $farmId]);
        if (!$hdr) {
            throw new \Exception('Transfer not found');
        }
        $status = (string) ($hdr['status'] ?? 'draft');
        if ($status !== 'draft') {
            throw new \Exception('Transfer cannot be shipped from status: ' . $status);
        }
        $lines = $this->db->query('SELECT id, item_id, lot_id, qty FROM inventory_transfer_lines WHERE transfer_id = ?', [$transferId]);
        $fromWh = (int) $hdr['from_warehouse_id'];
        foreach ($lines as $line) {
            $itemId = (int) ($line['item_id'] ?? 0);
            $lotId = (int) ($line['lot_id'] ?? 0);
            $qty = (float) ($line['qty'] ?? 0);
            if ($qty <= 0) {
                continue;
            }
            $this->applyStockDelta($farmId, $fromWh, 0, $itemId, $lotId, 0, -1.0 * $qty, 0.0);
            $this->recordLedger($farmId, $fromWh, 0, $itemId, $lotId, 0, 'transfer_out', -1.0 * $qty, 0.0, 'transfer', (string) $transferId, null);
        }
        $this->db->execute('UPDATE inventory_transfer_headers SET status = "in_transit", shipped_at = NOW(), created_by = ? WHERE id = ?', [$userId, $transferId]);
    }

    private function receiveTransferInternal(int $farmId, int $transferId, int $userId): void
    {
        $hdr = $this->db->queryOne('SELECT id, from_warehouse_id, to_warehouse_id, status FROM inventory_transfer_headers WHERE id = ? AND farm_id = ? LIMIT 1', [$transferId, $farmId]);
        if (!$hdr) {
            throw new \Exception('Transfer not found');
        }
        $status = (string) ($hdr['status'] ?? 'draft');
        if ($status !== 'in_transit') {
            throw new \Exception('Transfer cannot be received from status: ' . $status);
        }
        $lines = $this->db->query('SELECT id, item_id, lot_id, qty FROM inventory_transfer_lines WHERE transfer_id = ?', [$transferId]);
        $toWh = (int) $hdr['to_warehouse_id'];
        foreach ($lines as $line) {
            $itemId = (int) ($line['item_id'] ?? 0);
            $lotId = (int) ($line['lot_id'] ?? 0);
            $qty = (float) ($line['qty'] ?? 0);
            if ($qty <= 0) {
                continue;
            }
            $this->applyStockDelta($farmId, $toWh, 0, $itemId, $lotId, 0, $qty, 0.0);
            $this->recordLedger($farmId, $toWh, 0, $itemId, $lotId, 0, 'transfer_in', $qty, 0.0, 'transfer', (string) $transferId, null);
        }
        $this->db->execute('UPDATE inventory_transfer_headers SET status = "received", received_at = NOW(), created_by = ? WHERE id = ?', [$userId, $transferId]);
    }

    public function valuation(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $method = strtolower(trim((string) ($q['method'] ?? 'wavg')));
            if (!Validation::validateEnum($method, ['wavg', 'fifo', 'lifo', 'standard'])) {
                $method = 'wavg';
            }

            $onHand = $this->db->query(
                'SELECT item_id, COALESCE(SUM(qty_on_hand), 0) AS qty_on_hand
                 FROM inventory_stock_levels
                 WHERE farm_id = ?
                 GROUP BY item_id',
                [$farmId]
            );

            $items = [];
            $total = 0.0;
            foreach ($onHand as $row) {
                $itemId = (int) ($row['item_id'] ?? 0);
                $qty = (float) ($row['qty_on_hand'] ?? 0);
                if ($qty <= 0) {
                    continue;
                }
                $value = 0.0;
                $unitCost = 0.0;
                if ($method === 'fifo' || $method === 'lifo') {
                    $layers = $this->db->queryOne(
                        'SELECT COALESCE(SUM(qty_remaining * unit_cost), 0) AS value, COALESCE(SUM(qty_remaining), 0) AS qty
                         FROM inventory_cost_layers
                         WHERE farm_id = ? AND item_id = ? AND qty_remaining > 0',
                        [$farmId, $itemId]
                    );
                    $value = (float) ($layers['value'] ?? 0);
                    $layerQty = (float) ($layers['qty'] ?? 0);
                    $unitCost = $layerQty > 0 ? $value / $layerQty : 0.0;
                } elseif ($method === 'standard') {
                    $costing = $this->costingMethod($farmId, $itemId);
                    $unitCost = (float) ($costing['standard_cost'] ?? 0);
                    if ($unitCost <= 0) {
                        if ($this->inventoryHasFarmId()) {
                            $inv = $this->db->queryOne('SELECT cost_per_unit FROM inventory WHERE farm_id = ? AND id = ? LIMIT 1', [$farmId, $itemId]);
                        } else {
                            $inv = $this->db->queryOne('SELECT cost_per_unit FROM inventory WHERE id = ? LIMIT 1', [$itemId]);
                        }
                        $unitCost = (float) ($inv['cost_per_unit'] ?? 0);
                    }
                    $value = $qty * $unitCost;
                } else {
                    $this->ensureCostingDefaults($farmId, $itemId);
                    $state = $this->db->queryOne('SELECT avg_cost FROM inventory_item_cost_state WHERE farm_id = ? AND item_id = ?', [$farmId, $itemId]);
                    $unitCost = (float) ($state['avg_cost'] ?? 0);
                    $value = $qty * $unitCost;
                }
                $items[] = [
                    'item_id' => $itemId,
                    'qty_on_hand' => round($qty, 3),
                    'unit_cost' => round($unitCost, 4),
                    'valuation' => round($value, 2),
                    'method' => $method,
                ];
                $total += $value;
            }

            return Response::success(['items' => $items, 'total_inventory_value' => round($total, 2), 'method' => $method]);
        } catch (\Exception $e) {
            Logger::error('Failed to calculate inventory valuation', ['error' => $e->getMessage()]);
            return Response::error('Failed to calculate valuation', 'INVENTORY_VALUATION_ERROR', 500);
        }
    }

    public function reorder(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            $rows = $this->db->query(
                'SELECT warehouse_id, item_id, qty_on_hand, reorder_point, reorder_qty
                 FROM inventory_stock_levels
                 WHERE farm_id = ? AND reorder_point > 0 AND qty_on_hand <= reorder_point
                 ORDER BY warehouse_id ASC, item_id ASC',
                [$farmId]
            );

            return Response::success(['reorder_recommendations' => $rows]);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch reorder recommendations', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch reorder recommendations', 'INVENTORY_REORDER_ERROR', 500);
        }
    }

    public function locations(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'inventory.read' : 'inventory.create';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $warehouseId = isset($q['warehouse_id']) && is_numeric($q['warehouse_id']) ? (int) $q['warehouse_id'] : 0;

            if ($this->request->getMethod() === 'GET') {
                $sql = 'SELECT id, warehouse_id, code, name, is_active FROM inventory_locations WHERE farm_id = ?';
                $params = [$farmId];
                if ($warehouseId > 0) {
                    $sql .= ' AND warehouse_id = ?';
                    $params[] = $warehouseId;
                }
                $sql .= ' ORDER BY warehouse_id ASC, code ASC';
                return Response::success($this->db->query($sql, $params));
            }

            $input = $this->request->getBody();
            $warehouseId = (int) ($input['warehouse_id'] ?? 0);
            $code = trim((string) ($input['code'] ?? ''));
            $name = trim((string) ($input['name'] ?? ''));
            $errors = [];
            if ($warehouseId <= 0) {
                $errors['warehouse_id'] = 'warehouse_id is required';
            }
            if ($code === '') {
                $errors['code'] = 'code is required';
            }
            if ($name === '') {
                $errors['name'] = 'name is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }
            $this->db->execute(
                'INSERT INTO inventory_locations (farm_id, warehouse_id, code, name, is_active) VALUES (?, ?, ?, ?, 1)',
                [$farmId, $warehouseId, Validation::sanitizeString($code), Validation::sanitizeString($name)]
            );
            $id = (int) $this->db->lastInsertId();
            $this->audit($farmId, 'location.created', 'inventory_location', (string) $id, ['warehouse_id' => $warehouseId, 'code' => $code, 'name' => $name]);
            return Response::success(['id' => $id], 'Location created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle locations', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle locations', 'INVENTORY_LOCATIONS_ERROR', 500);
        }
    }

    public function stock(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $warehouseId = isset($q['warehouse_id']) && is_numeric($q['warehouse_id']) ? (int) $q['warehouse_id'] : 0;
            $itemId = isset($q['item_id']) && is_numeric($q['item_id']) ? (int) $q['item_id'] : 0;
            $lotId = isset($q['lot_id']) && is_numeric($q['lot_id']) ? (int) $q['lot_id'] : 0;

            $sql = 'SELECT warehouse_id, location_id, item_id, lot_id, serial_id, qty_on_hand, qty_reserved
                    FROM inventory_stock_positions WHERE farm_id = ?';
            $params = [$farmId];
            if ($warehouseId > 0) {
                $sql .= ' AND warehouse_id = ?';
                $params[] = $warehouseId;
            }
            if ($itemId > 0) {
                $sql .= ' AND item_id = ?';
                $params[] = $itemId;
            }
            if ($lotId > 0) {
                $sql .= ' AND lot_id = ?';
                $params[] = $lotId;
            }
            $sql .= ' ORDER BY warehouse_id ASC, item_id ASC, lot_id ASC, serial_id ASC LIMIT 2000';
            $rows = $this->db->query($sql, $params);
            $summary = [];
            foreach ($rows as $r) {
                $key = ($r['warehouse_id'] ?? 0) . ':' . ($r['item_id'] ?? 0);
                if (!isset($summary[$key])) {
                    $summary[$key] = [
                        'warehouse_id' => (int) ($r['warehouse_id'] ?? 0),
                        'item_id' => (int) ($r['item_id'] ?? 0),
                        'qty_on_hand' => 0.0,
                        'qty_reserved' => 0.0,
                        'qty_available' => 0.0,
                    ];
                }
                $summary[$key]['qty_on_hand'] += (float) ($r['qty_on_hand'] ?? 0);
                $summary[$key]['qty_reserved'] += (float) ($r['qty_reserved'] ?? 0);
            }
            foreach ($summary as &$s) {
                $s['qty_available'] = round($s['qty_on_hand'] - $s['qty_reserved'], 3);
                $s['qty_on_hand'] = round($s['qty_on_hand'], 3);
                $s['qty_reserved'] = round($s['qty_reserved'], 3);
            }
            return Response::success(['positions' => $rows, 'summary' => array_values($summary)]);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch stock', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch stock', 'INVENTORY_STOCK_ERROR', 500);
        }
    }

    public function reservations(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'inventory.read' : 'inventory.adjust';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $q = $this->request->getQuery();
                $status = strtolower(trim((string) ($q['status'] ?? 'open')));
                if (!Validation::validateEnum($status, ['open', 'fulfilled', 'canceled', 'released'])) {
                    $status = 'open';
                }
                $rows = $this->db->query(
                    'SELECT id, warehouse_id, location_id, item_id, lot_id, serial_id, qty, status, reference_type, reference_id, expires_at, created_at
                     FROM inventory_reservations
                     WHERE farm_id = ? AND status = ?
                     ORDER BY created_at DESC, id DESC
                     LIMIT 500',
                    [$farmId, $status]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $warehouseId = (int) ($input['warehouse_id'] ?? 0);
            $locationId = isset($input['location_id']) && is_numeric($input['location_id']) ? (int) $input['location_id'] : 0;
            $itemId = (int) ($input['item_id'] ?? 0);
            $lotId = isset($input['lot_id']) && is_numeric($input['lot_id']) ? (int) $input['lot_id'] : 0;
            $serialId = isset($input['serial_id']) && is_numeric($input['serial_id']) ? (int) $input['serial_id'] : 0;
            $qty = $input['qty'] ?? null;
            $referenceType = trim((string) ($input['reference_type'] ?? ''));
            $referenceId = trim((string) ($input['reference_id'] ?? ''));
            $expiresAt = trim((string) ($input['expires_at'] ?? ''));

            $errors = [];
            if ($warehouseId <= 0) {
                $errors['warehouse_id'] = 'warehouse_id is required';
            }
            if ($itemId <= 0) {
                $errors['item_id'] = 'item_id is required';
            }
            if (!is_numeric($qty) || (float) $qty <= 0) {
                $errors['qty'] = 'qty must be positive';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $qtyF = (float) $qty;
            $this->db->beginTransaction();
            try {
                $pos = $this->db->queryOne(
                    'SELECT COALESCE(SUM(qty_on_hand), 0) AS qty_on_hand, COALESCE(SUM(qty_reserved), 0) AS qty_reserved
                     FROM inventory_stock_positions
                     WHERE farm_id = ? AND warehouse_id = ? AND item_id = ? AND lot_id = ? AND serial_id = ? AND location_id = ?',
                    [$farmId, $warehouseId, $itemId, $lotId, $serialId, $locationId]
                );
                $onHand = (float) ($pos['qty_on_hand'] ?? 0);
                $reserved = (float) ($pos['qty_reserved'] ?? 0);
                if (($onHand - $reserved) + 0.0001 < $qtyF) {
                    throw new \Exception('Insufficient available stock to reserve');
                }

                $this->db->execute(
                    'INSERT INTO inventory_reservations (farm_id, warehouse_id, location_id, item_id, lot_id, serial_id, qty, status, reference_type, reference_id, expires_at, created_by)
                     VALUES (?, ?, ?, ?, ?, ?, ?, "open", ?, ?, ?, ?)',
                    [
                        $farmId,
                        $warehouseId,
                        $locationId,
                        $itemId,
                        $lotId,
                        $serialId,
                        $qtyF,
                        $referenceType !== '' ? Validation::sanitizeString($referenceType) : null,
                        $referenceId !== '' ? Validation::sanitizeString($referenceId) : null,
                        $expiresAt !== '' ? $expiresAt : null,
                        $userId,
                    ]
                );
                $reservationId = (int) $this->db->lastInsertId();
                $this->applyStockDelta($farmId, $warehouseId, $locationId, $itemId, $lotId, $serialId, 0.0, $qtyF);
                $this->recordLedger($farmId, $warehouseId, $locationId, $itemId, $lotId, $serialId, 'reserve', 0.0, 0.0, 'reservation', (string) $reservationId, null);
                $this->audit($farmId, 'reservation.created', 'inventory_reservation', (string) $reservationId, ['qty' => $qtyF]);
                $this->db->commit();
                return Response::success(['id' => $reservationId], 'Reserved', 201);
            } catch (\Throwable $e) {
                $this->db->rollback();
                return Response::validationError(['reservation' => $e->getMessage()]);
            }
        } catch (\Exception $e) {
            Logger::error('Failed to handle reservations', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle reservations', 'INVENTORY_RESERVATIONS_ERROR', 500);
        }
    }

    public function reservationAction(int $id, string $action): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.adjust');
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $res = $this->db->queryOne(
                'SELECT id, warehouse_id, location_id, item_id, lot_id, serial_id, qty, status
                 FROM inventory_reservations WHERE farm_id = ? AND id = ? LIMIT 1',
                [$farmId, $id]
            );
            if (!$res) {
                return Response::notFound('Reservation not found');
            }
            $status = (string) ($res['status'] ?? 'open');
            if ($status !== 'open') {
                return Response::validationError(['status' => 'Reservation is not open']);
            }
            $warehouseId = (int) ($res['warehouse_id'] ?? 0);
            $locationId = (int) ($res['location_id'] ?? 0);
            $itemId = (int) ($res['item_id'] ?? 0);
            $lotId = (int) ($res['lot_id'] ?? 0);
            $serialId = (int) ($res['serial_id'] ?? 0);
            $qty = (float) ($res['qty'] ?? 0);
            if ($qty <= 0) {
                return Response::validationError(['qty' => 'Invalid reservation qty']);
            }

            $this->db->beginTransaction();
            try {
                if ($action === 'cancel' || $action === 'release') {
                    $newStatus = $action === 'cancel' ? 'canceled' : 'released';
                    $this->applyStockDelta($farmId, $warehouseId, $locationId, $itemId, $lotId, $serialId, 0.0, -1.0 * $qty);
                    $this->recordLedger($farmId, $warehouseId, $locationId, $itemId, $lotId, $serialId, 'release', 0.0, 0.0, 'reservation', (string) $id, null);
                    $this->db->execute('UPDATE inventory_reservations SET status = ? WHERE id = ?', [$newStatus, $id]);
                    $this->audit($farmId, 'reservation.' . $newStatus, 'inventory_reservation', (string) $id);
                    $this->db->commit();
                    return Response::success(['id' => $id, 'status' => $newStatus], 'Reservation updated');
                }
                if ($action === 'fulfill') {
                    $this->applyStockDelta($farmId, $warehouseId, $locationId, $itemId, $lotId, $serialId, -1.0 * $qty, -1.0 * $qty);
                    $cost = $this->computeIssueCost($farmId, $itemId, $warehouseId, $lotId, $qty);
                    $this->recordCogs($farmId, $itemId, $warehouseId, $lotId, $qty, (float) $cost['total_cost'], (float) $cost['unit_cost'], 'reservation', (string) $id);
                    $this->recordLedger($farmId, $warehouseId, $locationId, $itemId, $lotId, $serialId, 'issue', -1.0 * $qty, (float) $cost['unit_cost'], 'reservation', (string) $id, null);
                    $this->db->execute('UPDATE inventory_reservations SET status = "fulfilled" WHERE id = ?', [$id]);
                    $this->audit($farmId, 'reservation.fulfilled', 'inventory_reservation', (string) $id);
                    $this->db->commit();
                    return Response::success(['id' => $id, 'status' => 'fulfilled'], 'Reservation fulfilled');
                }
                $this->db->rollback();
                return Response::validationError(['action' => 'Invalid action']);
            } catch (\Throwable $e) {
                $this->db->rollback();
                return Response::validationError(['reservation' => $e->getMessage()]);
            }
        } catch (\Exception $e) {
            Logger::error('Failed reservation action', ['error' => $e->getMessage()]);
            return Response::error('Failed reservation action', 'INVENTORY_RESERVATION_ACTION_ERROR', 500);
        }
    }

    public function lots(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $itemId = isset($q['item_id']) && is_numeric($q['item_id']) ? (int) $q['item_id'] : 0;
            $days = isset($q['days']) && is_numeric($q['days']) ? (int) $q['days'] : 0;
            if ($days > 0) {
                $rows = $this->db->query(
                    'SELECT id, item_id, lot_number, expiry_date, received_at
                     FROM inventory_lots
                     WHERE farm_id = ? AND expiry_date IS NOT NULL AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
                     ORDER BY expiry_date ASC, id ASC
                     LIMIT 500',
                    [$farmId, $days]
                );
                return Response::success($rows);
            }
            $sql = 'SELECT id, item_id, lot_number, expiry_date, received_at, supplier, notes FROM inventory_lots WHERE farm_id = ?';
            $params = [$farmId];
            if ($itemId > 0) {
                $sql .= ' AND item_id = ?';
                $params[] = $itemId;
            }
            $sql .= ' ORDER BY item_id ASC, expiry_date ASC, id ASC LIMIT 500';
            return Response::success($this->db->query($sql, $params));
        } catch (\Exception $e) {
            Logger::error('Failed to fetch lots', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch lots', 'INVENTORY_LOTS_ERROR', 500);
        }
    }

    public function serials(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $itemId = isset($q['item_id']) && is_numeric($q['item_id']) ? (int) $q['item_id'] : 0;
            $status = strtolower(trim((string) ($q['status'] ?? '')));
            $sql = 'SELECT id, item_id, serial_number, lot_id, warehouse_id, location_id, status, created_at FROM inventory_serials WHERE farm_id = ?';
            $params = [$farmId];
            if ($itemId > 0) {
                $sql .= ' AND item_id = ?';
                $params[] = $itemId;
            }
            if ($status !== '') {
                $sql .= ' AND status = ?';
                $params[] = $status;
            }
            $sql .= ' ORDER BY created_at DESC, id DESC LIMIT 500';
            return Response::success($this->db->query($sql, $params));
        } catch (\Exception $e) {
            Logger::error('Failed to fetch serials', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch serials', 'INVENTORY_SERIALS_ERROR', 500);
        }
    }

    public function transfers(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'inventory.read' : 'inventory.transfer';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            if ($this->request->getMethod() === 'GET') {
                $q = $this->request->getQuery();
                $status = strtolower(trim((string) ($q['status'] ?? '')));
                $sql = 'SELECT id, from_warehouse_id, to_warehouse_id, status, reference_no, shipped_at, received_at, created_at
                        FROM inventory_transfer_headers WHERE farm_id = ?';
                $params = [$farmId];
                if ($status !== '') {
                    $sql .= ' AND status = ?';
                    $params[] = $status;
                }
                $sql .= ' ORDER BY created_at DESC, id DESC LIMIT 200';
                $hdrs = $this->db->query($sql, $params);
                return Response::success($hdrs);
            }

            $input = $this->request->getBody();
            $fromWh = (int) ($input['from_warehouse_id'] ?? 0);
            $toWh = (int) ($input['to_warehouse_id'] ?? 0);
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));
            $lines = $input['lines'] ?? null;
            if (!is_array($lines) || $lines === []) {
                return Response::validationError(['lines' => 'At least one line is required']);
            }
            if ($fromWh <= 0 || $toWh <= 0 || $fromWh === $toWh) {
                return Response::validationError(['warehouses' => 'Valid from/to warehouses are required']);
            }
            $this->db->beginTransaction();
            try {
                $this->db->execute(
                    'INSERT INTO inventory_transfer_headers (farm_id, from_warehouse_id, to_warehouse_id, status, reference_no, notes, created_by)
                     VALUES (?, ?, ?, "draft", ?, ?, ?)',
                    [
                        $farmId,
                        $fromWh,
                        $toWh,
                        $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null,
                        $notes !== '' ? Validation::sanitizeString($notes) : null,
                        $userId,
                    ]
                );
                $transferId = (int) $this->db->lastInsertId();
                foreach ($lines as $line) {
                    $itemId = isset($line['item_id']) && is_numeric($line['item_id']) ? (int) $line['item_id'] : 0;
                    $lotId = isset($line['lot_id']) && is_numeric($line['lot_id']) ? (int) $line['lot_id'] : 0;
                    $qty = isset($line['qty']) && is_numeric($line['qty']) ? (float) $line['qty'] : 0;
                    if ($itemId <= 0 || $qty <= 0) {
                        continue;
                    }
                    $this->db->execute(
                        'INSERT INTO inventory_transfer_lines (transfer_id, item_id, lot_id, qty, unit_cost) VALUES (?, ?, ?, ?, 0)',
                        [$transferId, $itemId, $lotId, $qty]
                    );
                }
                $this->audit($farmId, 'transfer.created', 'inventory_transfer', (string) $transferId);
                $this->db->commit();
                return Response::success(['id' => $transferId], 'Transfer created', 201);
            } catch (\Throwable $e) {
                $this->db->rollback();
                return Response::validationError(['transfer' => $e->getMessage()]);
            }
        } catch (\Exception $e) {
            Logger::error('Failed to handle transfers', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle transfers', 'INVENTORY_TRANSFERS_ERROR', 500);
        }
    }

    public function transferAction(int $id, string $action): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.transfer');
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $this->db->beginTransaction();
            try {
                if ($action === 'ship') {
                    $this->shipTransferInternal($farmId, $id, $userId);
                    $this->audit($farmId, 'transfer.shipped', 'inventory_transfer', (string) $id);
                    $this->db->commit();
                    return Response::success(['id' => $id, 'status' => 'in_transit'], 'Transfer shipped');
                }
                if ($action === 'receive') {
                    $this->receiveTransferInternal($farmId, $id, $userId);
                    $this->audit($farmId, 'transfer.received', 'inventory_transfer', (string) $id);
                    $this->db->commit();
                    return Response::success(['id' => $id, 'status' => 'received'], 'Transfer received');
                }
                $this->db->rollback();
                return Response::validationError(['action' => 'Invalid action']);
            } catch (\Throwable $e) {
                $this->db->rollback();
                return Response::validationError(['transfer' => $e->getMessage()]);
            }
        } catch (\Exception $e) {
            Logger::error('Failed transfer action', ['error' => $e->getMessage()]);
            return Response::error('Failed transfer action', 'INVENTORY_TRANSFER_ACTION_ERROR', 500);
        }
    }

    public function purchaseOrders(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'inventory.read' : 'inventory.create';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            if ($this->request->getMethod() === 'GET') {
                $q = $this->request->getQuery();
                $status = strtolower(trim((string) ($q['status'] ?? '')));
                $sql = 'SELECT id, supplier, status, order_date, expected_date, reference_no, created_at
                        FROM purchase_orders WHERE farm_id = ?';
                $params = [$farmId];
                if ($status !== '') {
                    $sql .= ' AND status = ?';
                    $params[] = $status;
                }
                $sql .= ' ORDER BY created_at DESC, id DESC LIMIT 200';
                $rows = $this->db->query($sql, $params);
                return Response::success($rows);
            }
            $input = $this->request->getBody();
            $supplier = trim((string) ($input['supplier'] ?? ''));
            $orderDate = trim((string) ($input['order_date'] ?? ''));
            $expectedDate = trim((string) ($input['expected_date'] ?? ''));
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));
            $lines = $input['lines'] ?? null;
            if (!is_array($lines) || $lines === []) {
                return Response::validationError(['lines' => 'At least one line is required']);
            }
            $this->db->beginTransaction();
            try {
                $this->db->execute(
                    'INSERT INTO purchase_orders (farm_id, supplier, status, order_date, expected_date, reference_no, notes, created_by)
                     VALUES (?, ?, "draft", ?, ?, ?, ?, ?)',
                    [
                        $farmId,
                        $supplier !== '' ? Validation::sanitizeString($supplier) : null,
                        $orderDate !== '' ? $orderDate : null,
                        $expectedDate !== '' ? $expectedDate : null,
                        $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null,
                        $notes !== '' ? Validation::sanitizeString($notes) : null,
                        $userId,
                    ]
                );
                $poId = (int) $this->db->lastInsertId();
                foreach ($lines as $line) {
                    $itemId = isset($line['item_id']) && is_numeric($line['item_id']) ? (int) $line['item_id'] : 0;
                    $qty = isset($line['qty_ordered']) && is_numeric($line['qty_ordered']) ? (float) $line['qty_ordered'] : (isset($line['qty']) && is_numeric($line['qty']) ? (float) $line['qty'] : 0);
                    $unitCost = isset($line['unit_cost']) && is_numeric($line['unit_cost']) ? (float) $line['unit_cost'] : 0;
                    if ($itemId <= 0 || $qty <= 0) {
                        continue;
                    }
                    $this->db->execute(
                        'INSERT INTO purchase_order_lines (po_id, item_id, qty_ordered, unit_cost) VALUES (?, ?, ?, ?)',
                        [$poId, $itemId, $qty, $unitCost]
                    );
                }
                $this->audit($farmId, 'po.created', 'purchase_order', (string) $poId);
                $this->db->commit();
                return Response::success(['id' => $poId], 'Purchase order created', 201);
            } catch (\Throwable $e) {
                $this->db->rollback();
                return Response::validationError(['po' => $e->getMessage()]);
            }
        } catch (\Exception $e) {
            Logger::error('Failed to handle purchase orders', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle purchase orders', 'INVENTORY_PO_ERROR', 500);
        }
    }

    public function purchaseOrderDetails(int $id): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $po = $this->db->queryOne(
                'SELECT id, supplier, status, order_date, expected_date, reference_no, notes, created_at
                 FROM purchase_orders
                 WHERE farm_id = ? AND id = ? LIMIT 1',
                [$farmId, $id]
            );
            if (!$po) {
                return Response::notFound('Purchase order not found');
            }
            $lines = $this->db->query(
                'SELECT id, item_id, qty_ordered, unit_cost, qty_received
                 FROM purchase_order_lines
                 WHERE po_id = ?
                 ORDER BY id ASC',
                [$id]
            );
            return Response::success(['po' => $po, 'lines' => $lines]);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch purchase order details', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch purchase order details', 'INVENTORY_PO_DETAILS_ERROR', 500);
        }
    }

    public function purchaseOrderAction(int $id, string $action): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.create');
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $po = $this->db->queryOne('SELECT id, status, supplier FROM purchase_orders WHERE farm_id = ? AND id = ? LIMIT 1', [$farmId, $id]);
            if (!$po) {
                return Response::notFound('Purchase order not found');
            }
            if ($action === 'approve') {
                if (($po['status'] ?? 'draft') !== 'draft') {
                    return Response::validationError(['status' => 'Only draft POs can be approved']);
                }
                $this->db->execute('UPDATE purchase_orders SET status = "approved" WHERE id = ?', [$id]);
                $this->audit($farmId, 'po.approved', 'purchase_order', (string) $id);
                return Response::success(['id' => $id, 'status' => 'approved'], 'Approved');
            }
            if ($action === 'receive') {
                $input = $this->request->getBody();
                $warehouseId = (int) ($input['warehouse_id'] ?? 0);
                $referenceNo = trim((string) ($input['reference_no'] ?? ''));
                $lines = $input['lines'] ?? null;
                if ($warehouseId <= 0) {
                    return Response::validationError(['warehouse_id' => 'warehouse_id is required']);
                }
                if (!is_array($lines) || $lines === []) {
                    return Response::validationError(['lines' => 'At least one receipt line is required']);
                }
                $this->db->beginTransaction();
                try {
                    $this->db->execute(
                        'INSERT INTO inventory_receipts (farm_id, po_id, warehouse_id, status, received_at, reference_no, created_by)
                         VALUES (?, ?, ?, "received", NOW(), ?, ?)',
                        [$farmId, $id, $warehouseId, $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null, $userId]
                    );
                    $receiptId = (int) $this->db->lastInsertId();
                    foreach ($lines as $line) {
                        $itemId = isset($line['item_id']) && is_numeric($line['item_id']) ? (int) $line['item_id'] : 0;
                        $qty = isset($line['qty_received']) && is_numeric($line['qty_received']) ? (float) $line['qty_received'] : (isset($line['qty']) && is_numeric($line['qty']) ? (float) $line['qty'] : 0);
                        $unitCost = isset($line['unit_cost']) && is_numeric($line['unit_cost']) ? (float) $line['unit_cost'] : 0;
                        $lotNumber = trim((string) ($line['lot_number'] ?? ''));
                        $expiryDate = trim((string) ($line['expiry_date'] ?? ''));
                        if ($expiryDate !== '' && !Validation::validateDate($expiryDate)) {
                            throw new \Exception('Invalid expiry_date');
                        }
                        if ($itemId <= 0 || $qty <= 0) {
                            continue;
                        }
                        $lotId = 0;
                        if ($lotNumber !== '') {
                            $lotId = $this->ensureLot($farmId, $itemId, $lotNumber, $expiryDate !== '' ? $expiryDate : null, (string) ($po['supplier'] ?? ''), null);
                        }
                        $this->db->execute(
                            'INSERT INTO inventory_receipt_lines (receipt_id, item_id, lot_id, lot_number, expiry_date, qty_received, unit_cost)
                             VALUES (?, ?, ?, ?, ?, ?, ?)',
                            [
                                $receiptId,
                                $itemId,
                                $lotId,
                                $lotNumber !== '' ? Validation::sanitizeString($lotNumber) : null,
                                $expiryDate !== '' ? $expiryDate : null,
                                $qty,
                                $unitCost,
                            ]
                        );
                        $this->applyStockDelta($farmId, $warehouseId, 0, $itemId, $lotId, 0, $qty, 0.0);
                        $this->recordLedger($farmId, $warehouseId, 0, $itemId, $lotId, 0, 'receipt', $qty, $unitCost, 'receipt', (string) $receiptId, null);
                        $costing = $this->costingMethod($farmId, $itemId);
                        $method = strtolower((string) ($costing['method'] ?? 'wavg'));
                        if ($method === 'fifo' || $method === 'lifo') {
                            $this->createCostLayer($farmId, $itemId, $warehouseId, $lotId, $qty, $unitCost, 'receipt', (string) $receiptId);
                        } else {
                            $this->updateAvgCostOnReceipt($farmId, $itemId, $qty, $unitCost);
                        }
                        $this->db->execute(
                            'UPDATE purchase_order_lines SET qty_received = qty_received + ? WHERE po_id = ? AND item_id = ?',
                            [$qty, $id, $itemId]
                        );
                    }
                    $this->audit($farmId, 'po.received', 'purchase_order', (string) $id, ['receipt_id' => $receiptId, 'warehouse_id' => $warehouseId]);
                    $this->db->commit();
                    return Response::success(['receipt_id' => $receiptId], 'Received', 201);
                } catch (\Throwable $e) {
                    $this->db->rollback();
                    return Response::validationError(['receive' => $e->getMessage()]);
                }
            }
            return Response::validationError(['action' => 'Invalid action']);
        } catch (\Exception $e) {
            Logger::error('Failed PO action', ['error' => $e->getMessage()]);
            return Response::error('Failed purchase order action', 'INVENTORY_PO_ACTION_ERROR', 500);
        }
    }

    public function receipts(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $rows = $this->db->query(
                'SELECT id, po_id, warehouse_id, status, received_at, reference_no, created_at
                 FROM inventory_receipts WHERE farm_id = ?
                 ORDER BY received_at DESC, id DESC
                 LIMIT 200',
                [$farmId]
            );
            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list receipts', ['error' => $e->getMessage()]);
            return Response::error('Failed to list receipts', 'INVENTORY_RECEIPTS_ERROR', 500);
        }
    }

    public function cogs(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $from = trim((string) ($q['from'] ?? ''));
            $to = trim((string) ($q['to'] ?? ''));
            $where = 'farm_id = ?';
            $params = [$farmId];
            if ($from !== '') {
                $where .= ' AND created_at >= ?';
                $params[] = $from;
            }
            if ($to !== '') {
                $where .= ' AND created_at <= ?';
                $params[] = $to;
            }
            $rows = $this->db->query(
                "SELECT item_id, COALESCE(SUM(qty),0) AS qty, COALESCE(SUM(total_cost),0) AS total_cost
                 FROM inventory_cogs
                 WHERE {$where}
                 GROUP BY item_id
                 ORDER BY total_cost DESC",
                $params
            );
            return Response::success(['items' => $rows]);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch COGS', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch COGS', 'INVENTORY_COGS_ERROR', 500);
        }
    }

    public function stocktakes(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'inventory.read' : 'inventory.adjust';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, warehouse_id, status, started_at, posted_at, created_at
                     FROM inventory_stocktakes
                     WHERE farm_id = ?
                     ORDER BY created_at DESC, id DESC
                     LIMIT 200',
                    [$farmId]
                );
                return Response::success($rows);
            }
            $input = $this->request->getBody();
            $warehouseId = (int) ($input['warehouse_id'] ?? 0);
            $notes = trim((string) ($input['notes'] ?? ''));
            if ($warehouseId <= 0) {
                return Response::validationError(['warehouse_id' => 'warehouse_id is required']);
            }
            $this->db->beginTransaction();
            try {
                $this->db->execute(
                    'INSERT INTO inventory_stocktakes (farm_id, warehouse_id, status, started_at, notes, created_by) VALUES (?, ?, "open", NOW(), ?, ?)',
                    [$farmId, $warehouseId, $notes !== '' ? Validation::sanitizeString($notes) : null, $userId]
                );
                $stocktakeId = (int) $this->db->lastInsertId();
                $levels = $this->db->query(
                    'SELECT item_id, qty_on_hand FROM inventory_stock_levels WHERE farm_id = ? AND warehouse_id = ?',
                    [$farmId, $warehouseId]
                );
                foreach ($levels as $lvl) {
                    $itemId = (int) ($lvl['item_id'] ?? 0);
                    $systemQty = (float) ($lvl['qty_on_hand'] ?? 0);
                    $this->db->execute(
                        'INSERT INTO inventory_stocktake_lines (stocktake_id, item_id, lot_id, system_qty) VALUES (?, ?, 0, ?)',
                        [$stocktakeId, $itemId, $systemQty]
                    );
                }
                $this->audit($farmId, 'stocktake.created', 'inventory_stocktake', (string) $stocktakeId, ['warehouse_id' => $warehouseId]);
                $this->db->commit();
                return Response::success(['id' => $stocktakeId], 'Stocktake created', 201);
            } catch (\Throwable $e) {
                $this->db->rollback();
                return Response::validationError(['stocktake' => $e->getMessage()]);
            }
        } catch (\Exception $e) {
            Logger::error('Failed to handle stocktakes', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle stocktakes', 'INVENTORY_STOCKTAKES_ERROR', 500);
        }
    }

    public function stocktakeAction(int $id, string $action): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.adjust');
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $hdr = $this->db->queryOne('SELECT id, warehouse_id, status FROM inventory_stocktakes WHERE farm_id = ? AND id = ? LIMIT 1', [$farmId, $id]);
            if (!$hdr) {
                return Response::notFound('Stocktake not found');
            }
            $warehouseId = (int) ($hdr['warehouse_id'] ?? 0);
            $status = (string) ($hdr['status'] ?? 'open');

            if ($action === 'lines') {
                $lines = $this->db->query(
                    'SELECT id, item_id, lot_id, system_qty, counted_qty, variance_qty FROM inventory_stocktake_lines WHERE stocktake_id = ? ORDER BY item_id ASC',
                    [$id]
                );
                return Response::success($lines);
            }

            if ($action === 'count') {
                if ($status !== 'open') {
                    return Response::validationError(['status' => 'Stocktake is not open']);
                }
                $input = $this->request->getBody();
                $counts = $input['counts'] ?? null;
                if (!is_array($counts) || $counts === []) {
                    return Response::validationError(['counts' => 'counts is required']);
                }
                $this->db->beginTransaction();
                try {
                    foreach ($counts as $c) {
                        $itemId = isset($c['item_id']) && is_numeric($c['item_id']) ? (int) $c['item_id'] : 0;
                        $counted = isset($c['counted_qty']) && is_numeric($c['counted_qty']) ? (float) $c['counted_qty'] : null;
                        if ($itemId <= 0 || $counted === null) {
                            continue;
                        }
                        $row = $this->db->queryOne(
                            'SELECT id, system_qty FROM inventory_stocktake_lines WHERE stocktake_id = ? AND item_id = ? AND lot_id = 0 LIMIT 1',
                            [$id, $itemId]
                        );
                        if (!$row) {
                            $this->db->execute(
                                'INSERT INTO inventory_stocktake_lines (stocktake_id, item_id, lot_id, system_qty, counted_qty, variance_qty) VALUES (?, ?, 0, 0, ?, ?)',
                                [$id, $itemId, $counted, $counted]
                            );
                        } else {
                            $system = (float) ($row['system_qty'] ?? 0);
                            $variance = $counted - $system;
                            $this->db->execute(
                                'UPDATE inventory_stocktake_lines SET counted_qty = ?, variance_qty = ? WHERE id = ?',
                                [$counted, $variance, (int) $row['id']]
                            );
                        }
                    }
                    $this->audit($farmId, 'stocktake.counted', 'inventory_stocktake', (string) $id);
                    $this->db->commit();
                    return Response::success(['id' => $id], 'Counts saved');
                } catch (\Throwable $e) {
                    $this->db->rollback();
                    return Response::validationError(['count' => $e->getMessage()]);
                }
            }

            if ($action === 'post') {
                if ($status !== 'open') {
                    return Response::validationError(['status' => 'Stocktake is not open']);
                }
                $lines = $this->db->query(
                    'SELECT item_id, lot_id, system_qty, counted_qty, variance_qty FROM inventory_stocktake_lines WHERE stocktake_id = ?',
                    [$id]
                );
                $this->db->beginTransaction();
                try {
                    foreach ($lines as $line) {
                        if ($line['counted_qty'] === null) {
                            continue;
                        }
                        $itemId = (int) ($line['item_id'] ?? 0);
                        $lotId = (int) ($line['lot_id'] ?? 0);
                        $variance = (float) ($line['variance_qty'] ?? 0);
                        if (abs($variance) < 0.0001) {
                            continue;
                        }
                        $this->applyStockDelta($farmId, $warehouseId, 0, $itemId, $lotId, 0, $variance, 0.0);
                        if ($variance < 0) {
                            $qty = abs($variance);
                            $cost = $this->computeIssueCost($farmId, $itemId, $warehouseId, $lotId, $qty);
                            $this->recordCogs($farmId, $itemId, $warehouseId, $lotId, $qty, (float) $cost['total_cost'], (float) $cost['unit_cost'], 'stocktake', (string) $id);
                            $this->recordLedger($farmId, $warehouseId, 0, $itemId, $lotId, 0, 'stocktake_adjustment', $variance, (float) $cost['unit_cost'], 'stocktake', (string) $id, null);
                        } else {
                            $this->recordLedger($farmId, $warehouseId, 0, $itemId, $lotId, 0, 'stocktake_adjustment', $variance, 0.0, 'stocktake', (string) $id, null);
                        }
                    }
                    $this->db->execute('UPDATE inventory_stocktakes SET status = "posted", posted_at = NOW() WHERE id = ?', [$id]);
                    $this->audit($farmId, 'stocktake.posted', 'inventory_stocktake', (string) $id);
                    $this->db->commit();
                    return Response::success(['id' => $id, 'status' => 'posted'], 'Stocktake posted');
                } catch (\Throwable $e) {
                    $this->db->rollback();
                    return Response::validationError(['post' => $e->getMessage()]);
                }
            }

            return Response::validationError(['action' => 'Invalid action']);
        } catch (\Exception $e) {
            Logger::error('Failed stocktake action', ['error' => $e->getMessage()]);
            return Response::error('Failed stocktake action', 'INVENTORY_STOCKTAKE_ACTION_ERROR', 500);
        }
    }

    public function reconcile(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            $mismatches = $this->db->query(
                'SELECT i.id AS item_id, i.quantity AS item_quantity, COALESCE(SUM(s.qty_on_hand), 0) AS warehouses_quantity
                 FROM inventory i
                 LEFT JOIN inventory_stock_levels s ON s.farm_id = ? AND s.item_id = i.id
                 GROUP BY i.id, i.quantity
                 HAVING ABS(i.quantity - COALESCE(SUM(s.qty_on_hand), 0)) > 0.001
                 ORDER BY i.id ASC
                 LIMIT 500',
                [$farmId]
            );

            $negativeAvailable = $this->db->query(
                'SELECT warehouse_id, item_id, qty_on_hand, qty_reserved, (qty_on_hand - qty_reserved) AS qty_available
                 FROM inventory_stock_levels
                 WHERE farm_id = ? AND (qty_on_hand - qty_reserved) < -0.001
                 ORDER BY warehouse_id ASC, item_id ASC
                 LIMIT 500',
                [$farmId]
            );

            $openReservations = $this->db->query(
                'SELECT id, warehouse_id, item_id, qty, status, created_at
                 FROM inventory_reservations
                 WHERE farm_id = ? AND status = "open"
                 ORDER BY created_at DESC
                 LIMIT 500',
                [$farmId]
            );

            $inTransit = $this->db->queryOne(
                'SELECT COUNT(*) AS count FROM inventory_transfer_headers WHERE farm_id = ? AND status = "in_transit"',
                [$farmId]
            );

            return Response::success([
                'quantity_mismatches' => $mismatches,
                'negative_available' => $negativeAvailable,
                'open_reservations' => $openReservations,
                'transfers_in_transit' => (int) ($inTransit['count'] ?? 0),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed reconciliation', ['error' => $e->getMessage()]);
            return Response::error('Failed reconciliation', 'INVENTORY_RECONCILE_ERROR', 500);
        }
    }

    public function auditLog(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $entityType = trim((string) ($q['entity_type'] ?? ''));
            $entityId = trim((string) ($q['entity_id'] ?? ''));
            $sql = 'SELECT id, event_type, entity_type, entity_id, payload_json, created_by, created_at
                    FROM inventory_audit_events
                    WHERE farm_id = ?';
            $params = [$farmId];
            if ($entityType !== '') {
                $sql .= ' AND entity_type = ?';
                $params[] = $entityType;
            }
            if ($entityId !== '') {
                $sql .= ' AND entity_id = ?';
                $params[] = $entityId;
            }
            $sql .= ' ORDER BY created_at DESC, id DESC LIMIT 500';
            return Response::success($this->db->query($sql, $params));
        } catch (\Exception $e) {
            Logger::error('Failed to fetch audit log', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch audit log', 'INVENTORY_AUDIT_ERROR', 500);
        }
    }
}
