<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};

class NotificationsController
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

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                type VARCHAR(20) NOT NULL DEFAULT "info",
                title VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                is_read BOOLEAN DEFAULT FALSE,
                read_at TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_notifications_user (user_id),
                INDEX idx_notifications_read (user_id, is_read)
            )'
        );
    }

    public function index(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $rows = $this->db->query(
                'SELECT id, type, title, message, is_read, created_at
                 FROM notifications
                 WHERE user_id = ?
                 ORDER BY created_at DESC, id DESC',
                [$userId]
            );

            $notifications = array_map(static function (array $row): array {
                return [
                    'id' => (int) $row['id'],
                    'type' => $row['type'] ?? 'info',
                    'title' => $row['title'] ?? '',
                    'message' => $row['message'] ?? '',
                    'read' => !empty($row['is_read']),
                    'timestamp' => $row['created_at'] ?? null,
                ];
            }, $rows);

            return Response::success($notifications);
        } catch (\Exception $e) {
            Logger::error('Failed to list notifications', ['error' => $e->getMessage()]);
            return Response::error('Failed to list notifications', 'NOTIFICATIONS_LIST_ERROR', 500);
        }
    }

    public function markAllRead(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $this->db->execute(
                'UPDATE notifications SET is_read = 1, read_at = NOW() WHERE user_id = ? AND is_read = 0',
                [$userId]
            );

            return Response::success(['updated' => true], 'Notifications marked as read');
        } catch (\Exception $e) {
            Logger::error('Failed to mark all notifications as read', ['error' => $e->getMessage()]);
            return Response::error('Failed to update notifications', 'NOTIFICATIONS_MARK_ALL_ERROR', 500);
        }
    }

    public function markRead(int $notificationId): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $existing = $this->db->query(
                'SELECT id FROM notifications WHERE id = ? AND user_id = ? LIMIT 1',
                [$notificationId, $userId]
            );
            if (empty($existing)) {
                return Response::notFound('Notification not found');
            }

            $this->db->execute(
                'UPDATE notifications SET is_read = 1, read_at = NOW() WHERE id = ? AND user_id = ?',
                [$notificationId, $userId]
            );

            return Response::success(['id' => $notificationId], 'Notification marked as read');
        } catch (\Exception $e) {
            Logger::error('Failed to mark notification as read', ['id' => $notificationId, 'error' => $e->getMessage()]);
            return Response::error('Failed to update notification', 'NOTIFICATION_MARK_ERROR', 500);
        }
    }
}
