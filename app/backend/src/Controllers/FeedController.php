<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class FeedController
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

    private function getUserId(): ?int
    {
        $user = $this->request->getUser();
        if (!$user || empty($user['user_id'])) {
            return null;
        }

        return (int) $user['user_id'];
    }

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS feed_ingredients (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                protein_content DECIMAL(5,2) NOT NULL,
                quantity_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
                cost_per_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_feed_ingredients_name (name)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS feed_milling_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                milling_date DATE NOT NULL,
                batch_name VARCHAR(150) NOT NULL,
                ingredients TEXT NOT NULL,
                total_output_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_feed_milling_logs_date (milling_date)
            )'
        );
    }

    public function ingredients(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT id, name, protein_content, quantity_kg, cost_per_kg
                 FROM feed_ingredients
                 ORDER BY name ASC, id ASC'
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list feed ingredients', ['error' => $e->getMessage()]);
            return Response::error('Failed to list feed ingredients', 'FEED_INGREDIENTS_ERROR', 500);
        }
    }

    public function storeIngredient(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.create');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            $proteinContent = $input['protein_content'] ?? null;
            $quantityKg = $input['quantity_kg'] ?? null;
            $costPerKg = $input['cost_per_kg'] ?? null;

            $errors = [];
            if ($name === '') {
                $errors['name'] = 'Name is required';
            }
            if (!is_numeric($proteinContent) || (float) $proteinContent < 0) {
                $errors['protein_content'] = 'Protein content must be numeric';
            }
            if (!is_numeric($quantityKg) || (float) $quantityKg < 0) {
                $errors['quantity_kg'] = 'Quantity must be numeric';
            }
            if (!is_numeric($costPerKg) || (float) $costPerKg < 0) {
                $errors['cost_per_kg'] = 'Cost per kg must be numeric';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO feed_ingredients (name, protein_content, quantity_kg, cost_per_kg, created_by)
                 VALUES (?, ?, ?, ?, ?)',
                [
                    Validation::sanitizeString($name),
                    (float) $proteinContent,
                    (float) $quantityKg,
                    (float) $costPerKg,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Ingredient created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create feed ingredient', ['error' => $e->getMessage()]);
            return Response::error('Failed to create feed ingredient', 'FEED_INGREDIENT_CREATE_ERROR', 500);
        }
    }

    public function millingLogs(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT milling_date AS date, batch_name, ingredients, total_output_kg
                 FROM feed_milling_logs
                 ORDER BY milling_date DESC, id DESC
                 LIMIT 50'
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list feed milling logs', ['error' => $e->getMessage()]);
            return Response::error('Failed to list feed milling logs', 'FEED_MILLING_LOGS_ERROR', 500);
        }
    }

    public function calculatePearson(): Response
    {
        try {
            $auth = $this->authorizePermission('inventory.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $targetProtein = $input['target_protein'] ?? null;
            $totalQuantityKg = $input['total_quantity_kg'] ?? null;
            $ingredient1Id = isset($input['ingredient_1_id']) ? (int) $input['ingredient_1_id'] : 0;
            $ingredient2Id = isset($input['ingredient_2_id']) ? (int) $input['ingredient_2_id'] : 0;

            $errors = [];
            if (!is_numeric($targetProtein)) {
                $errors['target_protein'] = 'Target protein must be numeric';
            }
            if (!is_numeric($totalQuantityKg) || (float) $totalQuantityKg <= 0) {
                $errors['total_quantity_kg'] = 'Total quantity must be greater than zero';
            }
            if ($ingredient1Id <= 0 || $ingredient2Id <= 0 || $ingredient1Id === $ingredient2Id) {
                $errors['ingredients'] = 'Choose two different ingredients';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $ingredients = $this->db->query(
                'SELECT id, name, protein_content, cost_per_kg FROM feed_ingredients WHERE id IN (?, ?)',
                [$ingredient1Id, $ingredient2Id]
            );
            if (count($ingredients) !== 2) {
                return Response::notFound('One or more ingredients were not found');
            }

            $byId = [];
            foreach ($ingredients as $ingredient) {
                $byId[(int) $ingredient['id']] = $ingredient;
            }
            $ingredient1 = $byId[$ingredient1Id] ?? null;
            $ingredient2 = $byId[$ingredient2Id] ?? null;
            if (!$ingredient1 || !$ingredient2) {
                return Response::notFound('One or more ingredients were not found');
            }

            $protein1 = (float) $ingredient1['protein_content'];
            $protein2 = (float) $ingredient2['protein_content'];
            $target = (float) $targetProtein;
            $minProtein = min($protein1, $protein2);
            $maxProtein = max($protein1, $protein2);

            if ($target < $minProtein || $target > $maxProtein || abs($protein1 - $protein2) < 0.0001) {
                return Response::validationError([
                    'target_protein' => 'Target protein must fall between the selected ingredient protein values',
                ]);
            }

            $partsIngredient1 = abs($target - $protein2);
            $partsIngredient2 = abs($protein1 - $target);
            $totalParts = $partsIngredient1 + $partsIngredient2;
            if ($totalParts <= 0) {
                return Response::validationError(['ingredients' => 'Unable to calculate Pearson square result']);
            }

            $qty1 = round(((float) $totalQuantityKg) * ($partsIngredient1 / $totalParts), 2);
            $qty2 = round(((float) $totalQuantityKg) * ($partsIngredient2 / $totalParts), 2);
            $totalCost = round(($qty1 * (float) $ingredient1['cost_per_kg']) + ($qty2 * (float) $ingredient2['cost_per_kg']), 2);

            return Response::success([
                'ingredient_1' => [
                    'id' => $ingredient1Id,
                    'name' => $ingredient1['name'],
                    'quantity_kg' => $qty1,
                ],
                'ingredient_2' => [
                    'id' => $ingredient2Id,
                    'name' => $ingredient2['name'],
                    'quantity_kg' => $qty2,
                ],
                'total_cost' => $totalCost,
                'notes' => $ingredient1['name'] . ': ' . $qty1 . ' kg, ' . $ingredient2['name'] . ': ' . $qty2 . ' kg',
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to calculate Pearson square', ['error' => $e->getMessage()]);
            return Response::error('Failed to calculate Pearson square', 'FEED_PEARSON_ERROR', 500);
        }
    }
}
