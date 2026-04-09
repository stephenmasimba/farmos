<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};

class FeedFormulationController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
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
            'CREATE TABLE IF NOT EXISTS feed_formulations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                target_protein DECIMAL(5,2) NOT NULL,
                ingredient_1_id INT NOT NULL,
                ingredient_2_id INT NOT NULL,
                ingredient_1_percentage DECIMAL(6,2) NOT NULL,
                ingredient_2_percentage DECIMAL(6,2) NOT NULL,
                cost_per_kg DECIMAL(10,2) NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "active",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_feed_formulations_created_at (created_at),
                INDEX idx_feed_formulations_status (status)
            )'
        );
    }

    public function ingredients(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT id, name, protein_content, cost_per_kg
                 FROM feed_ingredients
                 ORDER BY protein_content DESC, name ASC'
            );

            $ingredients = array_map(static function (array $row): array {
                return [
                    'id' => (int) $row['id'],
                    'name' => $row['name'] ?? '',
                    'protein' => (float) ($row['protein_content'] ?? 0),
                    'type' => 'ingredient',
                    'cost_per_kg' => (float) ($row['cost_per_kg'] ?? 0),
                ];
            }, $rows);

            return Response::success($ingredients);
        } catch (\Exception $e) {
            Logger::error('Failed to list feed formulation ingredients', ['error' => $e->getMessage()]);
            return Response::error('Failed to list formulation ingredients', 'FEED_FORMULATION_INGREDIENTS_ERROR', 500);
        }
    }

    public function recent(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT name, target_protein, cost_per_kg, status, created_at
                 FROM feed_formulations
                 ORDER BY created_at DESC, id DESC
                 LIMIT 20'
            );

            $recent = array_map(static function (array $row): array {
                return [
                    'name' => $row['name'] ?? 'Formulation',
                    'date' => $row['created_at'] ?? '',
                    'target_protein' => (float) ($row['target_protein'] ?? 0),
                    'cost_per_kg' => (float) ($row['cost_per_kg'] ?? 0),
                    'status' => $row['status'] ?? 'active',
                ];
            }, $rows);

            return Response::success($recent);
        } catch (\Exception $e) {
            Logger::error('Failed to list recent feed formulations', ['error' => $e->getMessage()]);
            return Response::error('Failed to list recent formulations', 'FEED_FORMULATION_RECENT_ERROR', 500);
        }
    }

    public function calculate(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $ingredient1Id = isset($input['ingredient_1']) ? (int) $input['ingredient_1'] : 0;
            $ingredient2Id = isset($input['ingredient_2']) ? (int) $input['ingredient_2'] : 0;
            $targetProtein = isset($input['target_protein']) ? (float) $input['target_protein'] : null;

            if ($ingredient1Id <= 0 || $ingredient2Id <= 0 || $ingredient1Id === $ingredient2Id) {
                return Response::json(['error' => 'Choose two different ingredients'], 422);
            }
            if (!is_numeric($targetProtein)) {
                return Response::json(['error' => 'Target protein must be numeric'], 422);
            }

            $rows = $this->db->query(
                'SELECT id, name, protein_content, cost_per_kg FROM feed_ingredients WHERE id IN (?, ?)',
                [$ingredient1Id, $ingredient2Id]
            );
            if (count($rows) !== 2) {
                return Response::json(['error' => 'One or more ingredients were not found'], 404);
            }

            $byId = [];
            foreach ($rows as $row) {
                $byId[(int) $row['id']] = $row;
            }
            $ingredient1 = $byId[$ingredient1Id] ?? null;
            $ingredient2 = $byId[$ingredient2Id] ?? null;
            if (!$ingredient1 || !$ingredient2) {
                return Response::json(['error' => 'One or more ingredients were not found'], 404);
            }

            $protein1 = (float) $ingredient1['protein_content'];
            $protein2 = (float) $ingredient2['protein_content'];
            $minProtein = min($protein1, $protein2);
            $maxProtein = max($protein1, $protein2);
            if ($targetProtein < $minProtein || $targetProtein > $maxProtein || abs($protein1 - $protein2) < 0.0001) {
                return Response::json(['error' => 'Target protein must fall between the selected ingredient protein values'], 422);
            }

            $parts1 = abs($targetProtein - $protein2);
            $parts2 = abs($protein1 - $targetProtein);
            $totalParts = $parts1 + $parts2;
            if ($totalParts <= 0) {
                return Response::json(['error' => 'Unable to calculate formulation'], 422);
            }

            $percentage1 = round(($parts1 / $totalParts) * 100, 2);
            $percentage2 = round(($parts2 / $totalParts) * 100, 2);
            $costPerKg = round((($percentage1 / 100) * (float) $ingredient1['cost_per_kg']) + (($percentage2 / 100) * (float) $ingredient2['cost_per_kg']), 2);
            $name = $ingredient1['name'] . ' + ' . $ingredient2['name'] . ' @ ' . rtrim(rtrim(number_format($targetProtein, 2, '.', ''), '0'), '.') . '%';

            $this->db->execute(
                'INSERT INTO feed_formulations (name, target_protein, ingredient_1_id, ingredient_2_id, ingredient_1_percentage, ingredient_2_percentage, cost_per_kg, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $name,
                    $targetProtein,
                    $ingredient1Id,
                    $ingredient2Id,
                    $percentage1,
                    $percentage2,
                    $costPerKg,
                    'active',
                    $userId,
                ]
            );

            return Response::json([
                'ingredients' => [
                    [
                        'name' => $ingredient1['name'],
                        'percentage' => $percentage1,
                        'parts' => round($parts1, 2),
                    ],
                    [
                        'name' => $ingredient2['name'],
                        'percentage' => $percentage2,
                        'parts' => round($parts2, 2),
                    ],
                ],
                'analysis' => [
                    'cost_per_kg' => $costPerKg,
                    'total_parts' => round($totalParts, 2),
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to calculate feed formulation', ['error' => $e->getMessage()]);
            return Response::json(['error' => 'Failed to calculate feed formulation'], 500);
        }
    }
}
