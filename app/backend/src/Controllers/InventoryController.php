<?php

namespace FarmOS\Controllers;

use FarmOS\{
    Request, Response, Database, Logger, Validation
};

/**
 * InventoryController - Manages farm inventory and supplies
 */
class InventoryController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    private function farmId(): int
    {
        $body = $this->request->getBody();
        $q = $this->request->getQuery();
        $farmId = (int) ($body['farm_id'] ?? ($q['farm_id'] ?? 0));
        return $farmId > 0 ? $farmId : 1;
    }

    private function normalizeItemRow(array $row, int $farmId): array
    {
        $qty = (float) ($row['quantity'] ?? 0);
        $min = (float) ($row['reorder_level'] ?? 0);
        $cpu = (float) ($row['cost_per_unit'] ?? 0);
        $name = (string) ($row['item_name'] ?? '');
        $category = (string) ($row['category'] ?? '');
        $unit = (string) ($row['unit'] ?? 'unit');
        $desc = (string) ($row['description'] ?? '');
        $updated = (string) ($row['last_updated'] ?? '');

        return [
            'id' => (int) ($row['id'] ?? 0),
            'farm_id' => $farmId,
            'name' => $name,
            'category' => $category,
            'description' => $desc,
            'quantity' => $qty,
            'unit' => $unit,
            'min_level' => $min,
            'max_level' => null,
            'cost_per_unit' => $cpu,
            'supplier' => null,
            'location' => null,
            'expiry_date' => null,
            'batch_number' => null,
            'notes' => null,
            'created_at' => $updated,
            'updated_at' => $updated,
            'is_low_stock' => $qty < $min,
            'is_expired' => false,
            'total_value' => round($qty * $cpu, 2),
        ];
    }

    /**
     * List inventory items
     * GET /api/inventory?farm_id={id}&page={page}&category={category}&status={status}
     */
    public function index(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = $this->farmId();

            // Pagination
            $page = (int) ($this->request->getQuery()['page'] ?? 1);
            $perPage = (int) ($this->request->getQuery()['per_page'] ?? 15);
            $page = max(1, $page);
            $perPage = min($perPage, 100);

            // Filters
            $category = $this->request->getQuery()['category'] ?? null;
            $status = $this->request->getQuery()['status'] ?? null;

            $where = '1=1';
            $params = [];

            if ($category) {
                $category = Validation::sanitizeString($category);
                $where .= ' AND category = ?';
                $params[] = $category;
            }

            $countRow = $this->db->queryOne("SELECT COUNT(*) AS total FROM inventory WHERE {$where}", $params);
            $total = (int) ($countRow['total'] ?? 0);
            $offset = ($page - 1) * $perPage;
            $rows = $this->db->query(
                "SELECT id, item_name, category, quantity, unit, reorder_level, cost_per_unit, description, last_updated
                 FROM inventory
                 WHERE {$where}
                 ORDER BY category ASC, item_name ASC
                 LIMIT {$perPage} OFFSET {$offset}",
                $params
            );

            // Apply status filter post-query if needed
            if ($status) {
                $items = $rows;
                if ($status === 'low_stock') {
                    $items = array_filter($items, fn($item) => (float) ($item['quantity'] ?? 0) < (float) ($item['reorder_level'] ?? 0));
                } elseif ($status === 'expired') {
                    $items = [];
                }
                $rows = array_values($items);
            }

            Logger::info('Listed inventory', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'count' => count($rows),
            ]);

            return Response::success([
                'inventory' => array_map(fn($r) => $this->normalizeItemRow($r, $farmId), $rows),
                'pagination' => [
                    'page' => $page,
                    'per_page' => $perPage,
                    'total' => $total,
                    'last_page' => (int) ceil($total / max(1, $perPage)),
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to list inventory', ['error' => $e->getMessage()]);
            return Response::error('Failed to list inventory', 'LIST_ERROR', 500);
        }
    }

    /**
     * Create inventory item
     * POST /api/inventory
     */
    public function store(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $input = $this->request->getBody();
            $farmId = $this->farmId();

            // Validate required fields
            $errors = [];
            if (empty($input['name'])) {
                $errors['name'] = 'Item name is required';
            }
            if (empty($input['category'])) {
                $errors['category'] = 'Category is required';
            }
            if (!isset($input['quantity'])) {
                $errors['quantity'] = 'Quantity is required';
            }

            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            // Validate data
            $input['name'] = Validation::sanitizeString($input['name']);
            $input['category'] = Validation::sanitizeString($input['category']);
            $input['description'] = Validation::sanitizeString($input['description'] ?? '');
            $input['unit'] = $input['unit'] ?? 'unit';

            // Validate numbers
            if (!is_numeric($input['quantity']) || $input['quantity'] < 0) {
                return Response::validationError(['quantity' => 'Quantity must be a non-negative number']);
            }

            if (isset($input['min_level'])) {
                if (!is_numeric($input['min_level']) || $input['min_level'] < 0) {
                    return Response::validationError(['min_level' => 'Min level must be a non-negative number']);
                }
            } else {
                $input['min_level'] = 0;
            }

            if (isset($input['cost_per_unit'])) {
                if (!is_numeric($input['cost_per_unit']) || $input['cost_per_unit'] < 0) {
                    return Response::validationError(['cost_per_unit' => 'Cost must be a non-negative number']);
                }
            } else {
                $input['cost_per_unit'] = 0;
            }

            $this->db->execute(
                'INSERT INTO inventory (item_name, category, quantity, unit, reorder_level, cost_per_unit, description, last_updated)
                 VALUES (?, ?, ?, ?, ?, ?, ?, NOW())',
                [
                    $input['name'],
                    $input['category'],
                    (float) $input['quantity'],
                    Validation::sanitizeString((string) $input['unit']),
                    (float) $input['min_level'],
                    (float) $input['cost_per_unit'],
                    $input['description'],
                ]
            );
            $inventoryId = (int) $this->db->lastInsertId();

            Logger::info('Created inventory item', [
                'user_id' => $user['user_id'],
                'inventory_id' => $inventoryId,
                'farm_id' => $farmId,
                'name' => $input['name'],
                'category' => $input['category'],
            ]);

            $row = $this->db->queryOne(
                'SELECT id, item_name, category, quantity, unit, reorder_level, cost_per_unit, description, last_updated FROM inventory WHERE id = ? LIMIT 1',
                [$inventoryId]
            );
            return Response::success($this->normalizeItemRow($row ?: ['id' => $inventoryId], $farmId), 'Inventory item created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create inventory', ['error' => $e->getMessage()]);
            return Response::error('Failed to create inventory', 'CREATE_ERROR', 500);
        }
    }

    /**
     * Get inventory item details
     * GET /api/inventory/{id}
     */
    public function show(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = $this->farmId();
            $row = $this->db->queryOne(
                'SELECT id, item_name, category, quantity, unit, reorder_level, cost_per_unit, description, last_updated FROM inventory WHERE id = ? LIMIT 1',
                [$id]
            );
            if (!$row) {
                return Response::notFound('Inventory item not found');
            }

            Logger::info('Retrieved inventory item', [
                'user_id' => $user['user_id'],
                'inventory_id' => $id,
            ]);

            return Response::success($this->normalizeItemRow($row, $farmId));
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve inventory', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve inventory', 'RETRIEVE_ERROR', 500);
        }
    }

    /**
     * Update inventory item
     * PUT /api/inventory/{id}
     */
    public function update(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = $this->farmId();
            $existing = $this->db->queryOne('SELECT id FROM inventory WHERE id = ? LIMIT 1', [$id]);
            if (!$existing) {
                return Response::notFound('Inventory item not found');
            }

            $input = $this->request->getBody();

            $sets = [];
            $params = [];

            if (!empty($input['name'])) {
                $sets[] = 'item_name = ?';
                $params[] = Validation::sanitizeString($input['name']);
            }
            if (!empty($input['category'])) {
                $sets[] = 'category = ?';
                $params[] = Validation::sanitizeString($input['category']);
            }
            if (isset($input['description'])) {
                $sets[] = 'description = ?';
                $params[] = Validation::sanitizeString((string) $input['description']);
            }
            if (isset($input['min_level'])) {
                if (!is_numeric($input['min_level']) || $input['min_level'] < 0) {
                    return Response::validationError(['min_level' => 'Min level must be non-negative']);
                }
                $sets[] = 'reorder_level = ?';
                $params[] = (float) $input['min_level'];
            }
            if (isset($input['cost_per_unit'])) {
                if (!is_numeric($input['cost_per_unit']) || $input['cost_per_unit'] < 0) {
                    return Response::validationError(['cost_per_unit' => 'Cost must be non-negative']);
                }
                $sets[] = 'cost_per_unit = ?';
                $params[] = (float) $input['cost_per_unit'];
            }
            if (isset($input['quantity'])) {
                if (!is_numeric($input['quantity']) || $input['quantity'] < 0) {
                    return Response::validationError(['quantity' => 'Quantity must be non-negative']);
                }
                $sets[] = 'quantity = ?';
                $params[] = (float) $input['quantity'];
            }
            if (!empty($input['unit'])) {
                $sets[] = 'unit = ?';
                $params[] = Validation::sanitizeString($input['unit']);
            }

            if (!empty($sets)) {
                $sets[] = 'last_updated = NOW()';
                $params[] = $id;
                $this->db->execute('UPDATE inventory SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);
            }

            Logger::info('Updated inventory item', [
                'user_id' => $user['user_id'],
                'inventory_id' => $id,
                'fields' => array_keys($input),
            ]);

            $row = $this->db->queryOne(
                'SELECT id, item_name, category, quantity, unit, reorder_level, cost_per_unit, description, last_updated FROM inventory WHERE id = ? LIMIT 1',
                [$id]
            );
            return Response::success($this->normalizeItemRow($row ?: ['id' => $id], $farmId), 'Inventory item updated successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to update inventory', ['error' => $e->getMessage()]);
            return Response::error('Failed to update inventory', 'UPDATE_ERROR', 500);
        }
    }

    /**
     * Delete inventory item
     * DELETE /api/inventory/{id}
     */
    public function destroy(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $affected = $this->db->execute('DELETE FROM inventory WHERE id = ?', [$id]);
            if (!$affected || $affected <= 0) {
                return Response::notFound('Inventory item not found');
            }

            Logger::info('Deleted inventory item', [
                'user_id' => $user['user_id'],
                'inventory_id' => $id,
            ]);

            return Response::success(['id' => $id], 'Inventory item deleted successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to delete inventory', ['error' => $e->getMessage()]);
            return Response::error('Failed to delete inventory', 'DELETE_ERROR', 500);
        }
    }

    /**
     * Adjust inventory quantity
     * POST /api/inventory/{id}/adjust
     */
    public function adjustQuantity(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = $this->farmId();
            $row = $this->db->queryOne(
                'SELECT id, item_name, category, quantity, unit, reorder_level, cost_per_unit, description, last_updated FROM inventory WHERE id = ? LIMIT 1',
                [$id]
            );
            if (!$row) {
                return Response::notFound('Inventory item not found');
            }

            $input = $this->request->getBody();

            if (!isset($input['amount'])) {
                return Response::validationError(['amount' => 'Amount is required']);
            }

            if (!is_numeric($input['amount'])) {
                return Response::validationError(['amount' => 'Amount must be a number']);
            }

            $amount = (float) $input['amount'];
            $reason = isset($input['reason']) ? Validation::sanitizeString($input['reason']) : null;

            // Check if adjustment would make quantity negative
            $currentQuantity = (float) ($row['quantity'] ?? 0);
            $newQuantity = $currentQuantity + $amount;
            if ($newQuantity < 0) {
                return Response::validationError(['amount' => 'Adjustment would result in negative quantity']);
            }

            $this->db->execute('UPDATE inventory SET quantity = quantity + ?, last_updated = NOW() WHERE id = ?', [$amount, $id]);

            Logger::info('Adjusted inventory quantity', [
                'user_id' => $user['user_id'],
                'inventory_id' => $id,
                'amount' => $amount,
                'reason' => $reason,
                'new_quantity' => $newQuantity,
            ]);

            return Response::success(
                $this->normalizeItemRow(array_merge($row, ['quantity' => $newQuantity]), $farmId),
                'Inventory quantity adjusted successfully'
            );
        } catch (\Exception $e) {
            Logger::error('Failed to adjust inventory', ['error' => $e->getMessage()]);
            return Response::error('Failed to adjust inventory', 'ADJUST_ERROR', 500);
        }
    }

    /**
     * Get inventory by category
     * GET /api/inventory/category/{category}?farm_id={id}
     */
    public function byCategory(string $category): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = $this->farmId();

            $category = Validation::sanitizeString($category);
            $rows = $this->db->query(
                'SELECT id, item_name, category, quantity, unit, reorder_level, cost_per_unit, description, last_updated
                 FROM inventory
                 WHERE category = ?
                 ORDER BY item_name ASC',
                [$category]
            );

            Logger::info('Retrieved inventory by category', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'category' => $category,
                'count' => count($rows),
            ]);

            return Response::success([
                'category' => $category,
                'inventory' => array_map(fn($r) => $this->normalizeItemRow($r, $farmId), $rows),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve inventory by category', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve inventory', 'RETRIEVE_ERROR', 500);
        }
    }

    /**
     * Get low stock items
     * GET /api/inventory/alerts?farm_id={id}
     */
    public function getAlerts(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = $this->farmId();

            $lowRows = $this->db->query(
                'SELECT id, item_name, category, quantity, unit, reorder_level, cost_per_unit, description, last_updated
                 FROM inventory
                 WHERE quantity < reorder_level
                 ORDER BY (reorder_level - quantity) DESC
                 LIMIT 200'
            );

            $expiringLots = [];
            try {
                $expiringLots = $this->db->query(
                    'SELECT l.item_id AS id, i.item_name, i.category, i.quantity, i.unit, i.reorder_level, i.cost_per_unit, i.description, i.last_updated
                     FROM inventory_lots l
                     JOIN inventory i ON i.id = l.item_id
                     WHERE l.farm_id = ? AND l.expiry_date IS NOT NULL AND l.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
                     GROUP BY l.item_id
                     ORDER BY MIN(l.expiry_date) ASC
                     LIMIT 200',
                    [$farmId]
                );
            } catch (\Throwable $e) {
                $expiringLots = [];
            }

            Logger::info('Retrieved inventory alerts', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'low_stock_count' => count($lowRows),
                'expiring_count' => count($expiringLots),
            ]);

            return Response::success([
                'alerts' => [
                    'low_stock' => array_map(fn($r) => $this->normalizeItemRow($r, $farmId), $lowRows),
                    'expiring_soon' => array_map(fn($r) => $this->normalizeItemRow($r, $farmId), $expiringLots),
                ],
                'low_stock_count' => count($lowRows),
                'expiring_count' => count($expiringLots),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve inventory alerts', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve alerts', 'ALERTS_ERROR', 500);
        }
    }

    /**
     * Get inventory statistics
     * GET /api/inventory/stats?farm_id={id}
     */
    public function getStats(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = $this->farmId();

            $totalRow = $this->db->queryOne('SELECT COUNT(*) AS total FROM inventory');
            $valueRow = $this->db->queryOne('SELECT COALESCE(SUM(quantity * cost_per_unit), 0) AS total_value FROM inventory');
            $categories = $this->db->query('SELECT DISTINCT category FROM inventory ORDER BY category ASC');
            $lowStockRow = $this->db->queryOne('SELECT COUNT(*) AS cnt FROM inventory WHERE quantity < reorder_level');
            $expiring = 0;
            try {
                $expiringRow = $this->db->queryOne(
                    'SELECT COUNT(*) AS cnt FROM inventory_lots WHERE farm_id = ? AND expiry_date IS NOT NULL AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)',
                    [$farmId]
                );
                $expiring = (int) ($expiringRow['cnt'] ?? 0);
            } catch (\Throwable $e) {
                $expiring = 0;
            }

            Logger::info('Retrieved inventory statistics', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success([
                'total_items' => (int) ($totalRow['total'] ?? 0),
                'total_value' => round((float) ($valueRow['total_value'] ?? 0), 2),
                'categories_count' => count($categories),
                'categories' => array_map(fn($r) => (string) ($r['category'] ?? ''), $categories),
                'low_stock_count' => (int) ($lowStockRow['cnt'] ?? 0),
                'expiring_soon_count' => $expiring,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve inventory statistics', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve statistics', 'STATS_ERROR', 500);
        }
    }
}
