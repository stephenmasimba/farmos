<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};

class TraceabilityController
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

    private function getFarmId(): int
    {
        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS traceability_events (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                item VARCHAR(180) NOT NULL,
                sender VARCHAR(120) NOT NULL,
                receiver VARCHAR(120) NOT NULL,
                quantity DECIMAL(12,2) NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_traceability_farm (farm_id, created_at)
            )'
        );
    }

    public function chain(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $farmId = $this->getFarmId();

            $rows = $this->db->query(
                'SELECT item, sender, receiver, quantity, created_at
                 FROM traceability_events
                 WHERE farm_id = ?
                 ORDER BY created_at ASC, id ASC
                 LIMIT 500',
                [$farmId]
            );

            $chain = [[
                'index' => 0,
                'timestamp' => gmdate('c'),
                'hash' => hash('sha256', 'genesis-' . (string) $farmId),
                'transactions' => [],
            ]];

            $index = 1;
            foreach ($rows as $row) {
                $tx = [
                    'item' => (string) ($row['item'] ?? ''),
                    'sender' => (string) ($row['sender'] ?? ''),
                    'receiver' => (string) ($row['receiver'] ?? ''),
                    'quantity' => (float) ($row['quantity'] ?? 0),
                ];

                $timestamp = (string) ($row['created_at'] ?? gmdate('c'));
                $hash = hash('sha256', $index . '|' . $timestamp . '|' . json_encode($tx));

                $chain[] = [
                    'index' => $index,
                    'timestamp' => $timestamp,
                    'hash' => $hash,
                    'transactions' => [$tx],
                ];
                $index++;
            }

            return Response::success($chain);
        } catch (\Exception $e) {
            Logger::error('Failed to build traceability chain', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch traceability chain', 'TRACEABILITY_CHAIN_ERROR', 500);
        }
    }
}
