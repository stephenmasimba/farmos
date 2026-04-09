<?php

declare(strict_types=1);

/**
 * Compare mobile ApiEndpoints definitions against backend router cases.
 *
 * Usage:
 *   php app/backend/tools/check_mobile_backend_parity.php
 */

$projectRoot = realpath(__DIR__ . '/../../..');
if ($projectRoot === false) {
    fwrite(STDERR, "Unable to resolve project root.\n");
    exit(1);
}

$mobileEndpointsFile = $projectRoot . '/mobile/lib/core/api/api_endpoints.dart';
$backendRouterFile = $projectRoot . '/app/backend/public/index.php';
$reportFile = $projectRoot . '/docs/MOBILE_BACKEND_PARITY_REPORT.md';

if (!is_file($mobileEndpointsFile)) {
    fwrite(STDERR, "Missing file: {$mobileEndpointsFile}\n");
    exit(1);
}

if (!is_file($backendRouterFile)) {
    fwrite(STDERR, "Missing file: {$backendRouterFile}\n");
    exit(1);
}

$mobileSource = (string) file_get_contents($mobileEndpointsFile);
$backendSource = (string) file_get_contents($backendRouterFile);

/**
 * Normalize dynamic endpoint segments to a common token.
 */
function normalizeEndpoint(string $path): string
{
    $path = trim($path);
    if ($path === '') {
        return '';
    }

    $path = str_replace('\\/', '/', $path);
    $path = preg_replace('/\$[A-Za-z_][A-Za-z0-9_]*/', '{param}', $path) ?? $path;
    $path = preg_replace('/\([^)]*\)/', '{param}', $path) ?? $path;
    $path = preg_replace('/\{param\}(?:\/{param\})+/', '{param}', $path) ?? $path;
    $path = preg_replace('#//+#', '/', $path) ?? $path;

    return $path;
}

/**
 * Convert a PHP regex route literal like '/^\/api\/fields\/(\d+)\/boundary$/' to '/api/fields/{param}/boundary'.
 */
function regexRouteToEndpoint(string $regexLiteral): string
{
    $regex = trim($regexLiteral);
    if ($regex === '') {
        return '';
    }

    if ($regex[0] === '/' && str_ends_with($regex, '/')) {
        $regex = substr($regex, 1, -1);
    }

    $regex = preg_replace('/^\^/', '', $regex) ?? $regex;
    $regex = preg_replace('/\$$/', '', $regex) ?? $regex;
    $regex = str_replace('\\/', '/', $regex);
    $regex = preg_replace('/\([^)]*\)/', '{param}', $regex) ?? $regex;
    $regex = str_replace('\\', '', $regex);

    return normalizeEndpoint($regex);
}

$mobileEndpoints = [];

if (preg_match_all("/static const String\\s+\\w+\\s*=\\s*'([^']+)'\\s*;/", $mobileSource, $matchesConst)) {
    foreach ($matchesConst[1] as $path) {
        $normalized = normalizeEndpoint($path);
        if (str_starts_with($normalized, '/')) {
            $mobileEndpoints[$normalized] = true;
        }
    }
}

if (preg_match_all("/static String\\s+\\w+\\([^)]*\\)\\s*=>\\s*'([^']+)'\\s*;/", $mobileSource, $matchesFn)) {
    foreach ($matchesFn[1] as $path) {
        $normalized = normalizeEndpoint($path);
        if (str_starts_with($normalized, '/')) {
            $mobileEndpoints[$normalized] = true;
        }
    }
}

$backendRoutes = [];

if (preg_match_all("/case\\s+'([^']+)'\\s*:/", $backendSource, $matchesCaseLiteral)) {
    foreach ($matchesCaseLiteral[1] as $path) {
        $normalized = normalizeEndpoint($path);
        if (str_starts_with($normalized, '/')) {
            $backendRoutes[$normalized] = true;
        }
    }
}

if (preg_match_all("/preg_match\\('([^']+)'\\s*,\\s*\\$path/", $backendSource, $matchesCaseRegex)) {
    foreach ($matchesCaseRegex[1] as $regexLiteral) {
        $endpoint = regexRouteToEndpoint($regexLiteral);
        if (str_starts_with($endpoint, '/')) {
            $backendRoutes[$endpoint] = true;
        }
    }
}

$mobileList = array_keys($mobileEndpoints);
$backendList = array_keys($backendRoutes);
sort($mobileList);
sort($backendList);

$missingInBackend = array_values(array_filter($mobileList, static fn(string $ep): bool => !isset($backendRoutes[$ep])));
$extraInBackend = array_values(array_filter($backendList, static fn(string $ep): bool => !isset($mobileEndpoints[$ep])));

$timestamp = date('Y-m-d H:i:s');

$report = [];
$report[] = '# Mobile-Backend Endpoint Parity Report';
$report[] = '';
$report[] = '- Generated at: ' . $timestamp;
$report[] = '- Mobile endpoints scanned: ' . count($mobileList);
$report[] = '- Backend routes scanned: ' . count($backendList);
$report[] = '- Missing in backend: ' . count($missingInBackend);
$report[] = '- Backend-only routes: ' . count($extraInBackend);
$report[] = '';

$report[] = '## Missing In Backend';
$report[] = '';
if ($missingInBackend === []) {
    $report[] = '- None';
} else {
    foreach ($missingInBackend as $endpoint) {
        $report[] = '- ' . $endpoint;
    }
}

$report[] = '';
$report[] = '## Backend-Only Routes';
$report[] = '';
if ($extraInBackend === []) {
    $report[] = '- None';
} else {
    foreach ($extraInBackend as $endpoint) {
        $report[] = '- ' . $endpoint;
    }
}

$reportContent = implode(PHP_EOL, $report) . PHP_EOL;

if (file_put_contents($reportFile, $reportContent) === false) {
    fwrite(STDERR, "Failed to write report: {$reportFile}\n");
    exit(1);
}

echo "Report written: {$reportFile}" . PHP_EOL;
echo "Missing in backend: " . count($missingInBackend) . PHP_EOL;

exit(0);
