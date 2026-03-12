-- Database Performance Indexes for Begin Masimba FarmOS
-- These indexes improve query performance for frequently accessed data

-- User table indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_users_tenant_active ON users(tenant_id, is_active);

-- Livestock batches indexes
CREATE INDEX IF NOT EXISTS idx_livestock_batches_type ON livestock_batches(animal_type);
CREATE INDEX IF NOT EXISTS idx_livestock_batches_status ON livestock_batches(status);
CREATE INDEX IF NOT EXISTS idx_livestock_batches_created_at ON livestock_batches(created_at);
CREATE INDEX IF NOT EXISTS idx_livestock_batches_tenant_active ON livestock_batches(tenant_id, is_active);

-- Transactions indexes
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_tenant ON transactions(tenant_id);

-- Inventory items indexes
CREATE INDEX IF NOT EXISTS idx_inventory_items_category ON inventory_items(category);
CREATE INDEX IF NOT EXISTS idx_inventory_items_quantity ON inventory_items(quantity);
CREATE INDEX IF NOT EXISTS idx_inventory_items_reorder_level ON inventory_items(reorder_level);
CREATE INDEX IF NOT EXISTS idx_inventory_items_created_at ON inventory_items(created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_items_tenant ON inventory_items(tenant_id);

-- Inventory transactions indexes
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_item_date ON inventory_transactions(item_id, transaction_date);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_type ON inventory_transactions(transaction_type);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_created_at ON inventory_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_tenant ON inventory_transactions(tenant_id);

-- Tasks indexes
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at);
CREATE INDEX IF NOT EXISTS idx_tasks_tenant ON tasks(tenant_id);

-- Fields indexes
CREATE INDEX IF NOT EXISTS idx_fields_current_crop ON fields(current_crop);
CREATE INDEX IF NOT EXISTS idx_fields_status ON fields(status);
CREATE INDEX IF NOT EXISTS idx_fields_planting_date ON fields(planting_date);
CREATE INDEX IF NOT EXISTS idx_fields_harvest_date ON fields(expected_harvest_date);
CREATE INDEX IF NOT EXISTS idx_fields_created_at ON fields(created_at);
CREATE INDEX IF NOT EXISTS idx_fields_tenant ON fields(tenant_id);

-- Weather logs indexes
CREATE INDEX IF NOT EXISTS idx_weather_logs_date ON weather_logs(log_date);
CREATE INDEX IF NOT EXISTS idx_weather_logs_conditions ON weather_logs(conditions);
CREATE INDEX IF NOT EXISTS idx_weather_logs_created_at ON weather_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_weather_logs_tenant ON weather_logs(tenant_id);

-- IoT devices indexes
CREATE INDEX IF NOT EXISTS idx_iot_devices_type ON iot_devices(device_type);
CREATE INDEX IF NOT EXISTS idx_iot_devices_active ON iot_devices(is_active);
CREATE INDEX IF NOT EXISTS idx_iot_devices_created_at ON iot_devices(created_at);
CREATE INDEX IF NOT EXISTS idx_iot_devices_tenant ON iot_devices(tenant_id);

-- Sensor readings indexes (performance critical for time-series data)
CREATE INDEX IF NOT EXISTS idx_sensor_readings_device_timestamp ON sensor_readings(device_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_timestamp ON sensor_readings(timestamp);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_type ON sensor_readings(sensor_type);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_created_at ON sensor_readings(created_at);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_tenant ON sensor_readings(tenant_id);

-- Alerts indexes
CREATE INDEX IF NOT EXISTS idx_alerts_type ON alerts(alert_type);
CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON alerts(created_at);
CREATE INDEX IF NOT EXISTS idx_alerts_tenant ON alerts(tenant_id);

-- Timesheets indexes
CREATE INDEX IF NOT EXISTS idx_timesheets_user_date ON timesheets(user_id, work_date);
CREATE INDEX IF NOT EXISTS idx_timesheets_date ON timesheets(work_date);
CREATE INDEX IF NOT EXISTS idx_timesheets_status ON timesheets(status);
CREATE INDEX IF NOT EXISTS idx_timesheets_created_at ON timesheets(created_at);
CREATE INDEX IF NOT EXISTS idx_timesheets_tenant ON timesheets(tenant_id);

-- Suppliers indexes
CREATE INDEX IF NOT EXISTS idx_suppliers_name ON suppliers(name);
CREATE INDEX IF NOT EXISTS idx_suppliers_created_at ON suppliers(created_at);
CREATE INDEX IF NOT EXISTS idx_suppliers_tenant ON suppliers(tenant_id);

-- Livestock events indexes
CREATE INDEX IF NOT EXISTS idx_livestock_events_batch_date ON livestock_events(batch_id, event_date);
CREATE INDEX IF NOT EXISTS idx_livestock_events_type ON livestock_events(event_type);
CREATE INDEX IF NOT EXISTS idx_livestock_events_created_at ON livestock_events(created_at);
CREATE INDEX IF NOT EXISTS idx_livestock_events_tenant ON livestock_events(tenant_id);

-- Growth records indexes
CREATE INDEX IF NOT EXISTS idx_growth_records_batch_date ON growth_records(batch_id, measurement_date);
CREATE INDEX IF NOT EXISTS idx_growth_records_created_at ON growth_records(created_at);
CREATE INDEX IF NOT EXISTS idx_growth_records_tenant ON growth_records(tenant_id);

-- Feed logs indexes
CREATE INDEX IF NOT EXISTS idx_feed_logs_batch_date ON feed_logs(batch_id, feed_date);
CREATE INDEX IF NOT EXISTS idx_feed_logs_item ON feed_logs(feed_item_id);
CREATE INDEX IF NOT EXISTS idx_feed_logs_created_at ON feed_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_feed_logs_tenant ON feed_logs(tenant_id);

-- Health records indexes
CREATE INDEX IF NOT EXISTS idx_health_records_batch_date ON health_records(batch_id, record_date);
CREATE INDEX IF NOT EXISTS idx_health_records_condition ON health_records(condition);
CREATE INDEX IF NOT EXISTS idx_health_records_created_at ON health_records(created_at);
CREATE INDEX IF NOT EXISTS idx_health_records_tenant ON health_records(tenant_id);

-- User invitations indexes
CREATE INDEX IF NOT EXISTS idx_user_invitations_email ON user_invitations(email);
CREATE INDEX IF NOT EXISTS idx_user_invitations_token ON user_invitations(invitation_token);
CREATE INDEX IF NOT EXISTS idx_user_invitations_status ON user_invitations(status);
CREATE INDEX IF NOT EXISTS idx_user_invitations_created_at ON user_invitations(created_at);

-- Password reset tokens indexes
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token ON password_reset_tokens(reset_token);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user ON password_reset_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_expires ON password_reset_tokens(expires_at);

-- Audit logs indexes (for compliance and security)
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_action ON audit_logs(user_id, action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_logs_resource ON audit_logs(resource_type, resource_id);

-- Tenant settings indexes
CREATE INDEX IF NOT EXISTS idx_tenant_settings_tenant_key ON tenant_settings(tenant_id, setting_key);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_livestock_events_batch_type_date ON livestock_events(batch_id, event_type, event_date);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_device_type_timestamp ON sensor_readings(device_id, sensor_type, timestamp);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_item_type_date ON inventory_transactions(item_id, transaction_type, created_at);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_status_due ON tasks(assigned_to, status, due_date);
CREATE INDEX IF NOT EXISTS idx_alerts_tenant_type_status_created ON alerts(tenant_id, alert_type, status, created_at);