<?php

namespace FarmOS\Controllers;

use FarmOS\{
    Request, Response, Database, Logger, Validation
};
use FarmOS\Models\Inventory;

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

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            // Pagination
            $page = (int) ($this->request->getQuery()['page'] ?? 1);
            $perPage = (int) ($this->request->getQuery()['per_page'] ?? 15);
            $page = max(1, $page);
            $perPage = min($perPage, 100);

            // Filters
            $category = $this->request->getQuery()['category'] ?? null;
            $status = $this->request->getQuery()['status'] ?? null;

            $query = Inventory::query($this->db)
                ->where('farm_id', $farmId);

            if ($category) {
                $category = Validation::sanitizeString($category);
                $query->where('category', $category);
            }

            $result = $query
                ->orderBy('category', 'ASC')
                ->orderBy('name', 'ASC')
                ->paginate($page, $perPage);

            // Apply status filter post-query if needed
            if ($status) {
                $items = $result['data'];
                if ($status === 'low_stock') {
                    $items = array_filter($items, fn($item) => $item->isLowStock());
                } elseif ($status === 'expired') {
                    $items = array_filter($items, fn($item) => $item->isExpired());
                }
                $result['data'] = $items;
            }

            Logger::info('Listed inventory', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'count' => count($result['data']),
            ]);

            return Response::success([
                'inventory' => array_map(fn($m) => $m->getFullProfile(), $result['data']),
                'pagination' => [
                    'page' => $result['page'],
                    'per_page' => $result['per_page'],
                    'total' => $result['total'],
                    'last_page' => $result['last_page'],
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

            // Validate required fields
            $errors = [];
            if (empty($input['farm_id'])) {
                $errors['farm_id'] = 'Farm ID is required';
            }
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
            $input['supplier'] = Validation::sanitizeString($input['supplier'] ?? '');
            $input['location'] = Validation::sanitizeString($input['location'] ?? '');
            $input['batch_number'] = Validation::sanitizeString($input['batch_number'] ?? '');
            $input['notes'] = Validation::sanitizeString($input['notes'] ?? '');
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

            if (isset($input['max_level'])) {
                if (!is_numeric($input['max_level']) || $input['max_level'] < 0) {
                    return Response::validationError(['max_level' => 'Max level must be a non-negative number']);
                }
            }

            if (isset($input['cost_per_unit'])) {
                if (!is_numeric($input['cost_per_unit']) || $input['cost_per_unit'] < 0) {
                    return Response::validationError(['cost_per_unit' => 'Cost must be a non-negative number']);
                }
            } else {
                $input['cost_per_unit'] = 0;
            }

            // Validate expiry date if provided
            if (!empty($input['expiry_date'])) {
                if (!Validation::validateDate($input['expiry_date'], 'Y-m-d')) {
                    return Response::validationError(['expiry_date' => 'Invalid date format (YYYY-MM-DD)']);
                }
            }

            // Create inventory
            $inventory = new Inventory($this->db, array_filter($input, fn($k) => in_array($k, Inventory::fillable()), ARRAY_FILTER_USE_KEY));
            $inventoryId = $inventory->save();

            Logger::info('Created inventory item', [
                'user_id' => $user['user_id'],
                'inventory_id' => $inventoryId,
                'farm_id' => $input['farm_id'],
                'name' => $input['name'],
                'category' => $input['category'],
            ]);

            return Response::success(
                array_merge($inventory->toArray(), ['id' => $inventoryId]),
                'Inventory item created successfully',
                201
            );
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

            $inventory = Inventory::find($id, $this->db);
            if (!$inventory) {
                return Response::notFound('Inventory item not found');
            }

            Logger::info('Retrieved inventory item', [
                'user_id' => $user['user_id'],
                'inventory_id' => $id,
            ]);

            return Response::success($inventory->getFullProfile());
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

            $inventory = Inventory::find($id, $this->db);
            if (!$inventory) {
                return Response::notFound('Inventory item not found');
            }

            $input = $this->request->getBody();

            // Update allowed fields
            if (!empty($input['name'])) {
                $inventory->name = Validation::sanitizeString($input['name']);
            }
            if (!empty($input['category'])) {
                $inventory->category = Validation::sanitizeString($input['category']);
            }
            if (!empty($input['description'])) {
                $inventory->description = Validation::sanitizeString($input['description']);
            }
            if (isset($input['min_level'])) {
                if (!is_numeric($input['min_level']) || $input['min_level'] < 0) {
                    return Response::validationError(['min_level' => 'Min level must be non-negative']);
                }
                $inventory->min_level = (float) $input['min_level'];
            }
            if (isset($input['cost_per_unit'])) {
                if (!is_numeric($input['cost_per_unit']) || $input['cost_per_unit'] < 0) {
                    return Response::validationError(['cost_per_unit' => 'Cost must be non-negative']);
                }
                $inventory->cost_per_unit = (float) $input['cost_per_unit'];
            }
            if (!empty($input['supplier'])) {
                $inventory->supplier = Validation::sanitizeString($input['supplier']);
            }
            if (!empty($input['location'])) {
                $inventory->location = Validation::sanitizeString($input['location']);
            }
            if (!empty($input['notes'])) {
                $inventory->notes = Validation::sanitizeString($input['notes']);
            }

            $inventory->updated_at = date('Y-m-d H:i:s');
            $inventory->save();

            Logger::info('Updated inventory item', [
                'user_id' => $user['user_id'],
                'inventory_id' => $id,
                'fields' => array_keys($input),
            ]);

            return Response::success($inventory->getFullProfile(), 'Inventory item updated successfully');
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

            $affected = Inventory::destroy($id, $this->db);
            if (!$affected) {
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

            $inventory = Inventory::find($id, $this->db);
            if (!$inventory) {
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
            $currentQuantity = (float) ($inventory->quantity ?? 0);
            $newQuantity = $currentQuantity + $amount;
            if ($newQuantity < 0) {
                return Response::validationError(['amount' => 'Adjustment would result in negative quantity']);
            }

            $inventory->adjustQuantity($this->db, $amount, $reason);

            Logger::info('Adjusted inventory quantity', [
                'user_id' => $user['user_id'],
                'inventory_id' => $id,
                'amount' => $amount,
                'reason' => $reason,
                'new_quantity' => $newQuantity,
            ]);

            return Response::success(
                $inventory->getFullProfile(),
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

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $category = Validation::sanitizeString($category);
            $items = Inventory::byCategory($farmId, $category, $this->db);

            Logger::info('Retrieved inventory by category', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'category' => $category,
                'count' => count($items),
            ]);

            return Response::success([
                'category' => $category,
                'inventory' => array_map(fn($item) => $item->getFullProfile(), $items),
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

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $lowStock = Inventory::lowStock($farmId, $this->db);
            $expiring = Inventory::expiringSoon($farmId, $this->db, 30);

            Logger::info('Retrieved inventory alerts', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'low_stock_count' => count($lowStock),
                'expiring_count' => count($expiring),
            ]);

            return Response::success([
                'alerts' => [
                    'low_stock' => array_map(fn($item) => $item->getFullProfile(), $lowStock),
                    'expiring_soon' => array_map(fn($item) => $item->getFullProfile(), $expiring),
                ],
                'low_stock_count' => count($lowStock),
                'expiring_count' => count($expiring),
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

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $total = Inventory::countByFarm($farmId, $this->db);
            $value = Inventory::totalValue($farmId, $this->db);
            $categories = Inventory::categories($farmId, $this->db);
            $lowStock = count(Inventory::lowStock($farmId, $this->db));
            $expiring = count(Inventory::expiringSoon($farmId, $this->db, 30));

            Logger::info('Retrieved inventory statistics', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success([
                'total_items' => $total,
                'total_value' => round($value, 2),
                'categories_count' => count($categories),
                'categories' => $categories,
                'low_stock_count' => $lowStock,
                'expiring_soon_count' => $expiring,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve inventory statistics', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve statistics', 'STATS_ERROR', 500);
        }
    }
}
