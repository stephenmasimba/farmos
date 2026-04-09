<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class InventoryPlatformController
{
    protected Database $db;
    protected Request $request;

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
            $itemId = (int) ($input['item_id'] ?? 0);
            $movementType = strtolower(trim((string) ($input['movement_type'] ?? '')));
            $quantity = $input['quantity'] ?? null;
            $unitCost = (float) ($input['unit_cost'] ?? 0);
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));

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
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $qty = (float) $quantity;
            $delta = $movementType === 'out' ? -1 * $qty : $qty;

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

            if ($warehouseId !== null && $warehouseId > 0) {
                $existing = $this->db->queryOne(
                    'SELECT id, qty_on_hand
                     FROM inventory_stock_levels
                     WHERE farm_id = ? AND warehouse_id = ? AND item_id = ?',
                    [$farmId, $warehouseId, $itemId]
                );

                if ($existing) {
                    $newQty = (float) ($existing['qty_on_hand'] ?? 0) + $delta;
                    if ($newQty < 0) {
                        return Response::validationError(['quantity' => 'Insufficient stock for movement']);
                    }
                    $this->db->execute(
                        'UPDATE inventory_stock_levels SET qty_on_hand = ? WHERE id = ?',
                        [$newQty, (int) $existing['id']]
                    );
                } else {
                    if ($delta < 0) {
                        return Response::validationError(['quantity' => 'No stock level found for outbound movement']);
                    }
                    $this->db->execute(
                        'INSERT INTO inventory_stock_levels (farm_id, warehouse_id, item_id, qty_on_hand, qty_reserved, reorder_point, reorder_qty)
                         VALUES (?, ?, ?, ?, 0, 0, 0)',
                        [$farmId, $warehouseId, $itemId, $delta]
                    );
                }
            }

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
            $fromRow = $this->db->queryOne(
                'SELECT id, qty_on_hand FROM inventory_stock_levels
                 WHERE farm_id = ? AND warehouse_id = ? AND item_id = ?',
                [$farmId, $fromWh, $itemId]
            );

            if (!$fromRow || (float) ($fromRow['qty_on_hand'] ?? 0) < $qty) {
                return Response::validationError(['quantity' => 'Insufficient source stock']);
            }

            $this->db->execute(
                'UPDATE inventory_stock_levels SET qty_on_hand = qty_on_hand - ? WHERE id = ?',
                [$qty, (int) $fromRow['id']]
            );

            $toRow = $this->db->queryOne(
                'SELECT id FROM inventory_stock_levels
                 WHERE farm_id = ? AND warehouse_id = ? AND item_id = ?',
                [$farmId, $toWh, $itemId]
            );

            if ($toRow) {
                $this->db->execute('UPDATE inventory_stock_levels SET qty_on_hand = qty_on_hand + ? WHERE id = ?', [$qty, (int) $toRow['id']]);
            } else {
                $this->db->execute(
                    'INSERT INTO inventory_stock_levels (farm_id, warehouse_id, item_id, qty_on_hand, qty_reserved, reorder_point, reorder_qty)
                     VALUES (?, ?, ?, ?, 0, 0, 0)',
                    [$farmId, $toWh, $itemId, $qty]
                );
            }

            $this->db->execute(
                'INSERT INTO inventory_transfers (farm_id, item_id, from_warehouse_id, to_warehouse_id, quantity, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [$farmId, $itemId, $fromWh, $toWh, $qty, 'completed', $userId]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Transfer completed', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to transfer stock', ['error' => $e->getMessage()]);
            return Response::error('Failed to transfer stock', 'INVENTORY_TRANSFER_ERROR', 500);
        }
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

            $rows = $this->db->query(
                'SELECT m.item_id,
                        SUM(CASE WHEN m.movement_type = "out" THEN -m.quantity ELSE m.quantity END) AS net_qty,
                        COALESCE(AVG(m.unit_cost), 0) AS avg_unit_cost
                 FROM inventory_movements m
                 WHERE m.farm_id = ?
                 GROUP BY m.item_id',
                [$farmId]
            );

            $total = 0.0;
            foreach ($rows as &$row) {
                $net = (float) ($row['net_qty'] ?? 0);
                $avg = (float) ($row['avg_unit_cost'] ?? 0);
                $value = max(0, $net) * $avg;
                $row['valuation'] = round($value, 2);
                $total += $value;
            }

            return Response::success([
                'items' => $rows,
                'total_inventory_value' => round($total, 2),
            ]);
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
}
