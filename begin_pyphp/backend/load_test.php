<?php declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(400);
    echo "CLI only\n";
    exit(1);
}

$args = $argv;
array_shift($args);

$url = $args[0] ?? 'http://127.0.0.1:8001/health';
$total = isset($args[1]) ? (int) $args[1] : 500;
$concurrency = isset($args[2]) ? (int) $args[2] : 25;

if ($total < 1 || $concurrency < 1) {
    fwrite(STDERR, "Usage: php load_test.php <url> [total] [concurrency]\n");
    exit(2);
}

if ($concurrency > $total) {
    $concurrency = $total;
}

$latenciesMs = [];
$ok = 0;
$fail = 0;

$mh = curl_multi_init();
$inFlight = [];
$startedAt = microtime(true);
$sent = 0;

$makeHandle = static function () use ($url) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3);
    curl_setopt($ch, CURLOPT_FAILONERROR, false);
    return $ch;
};

while ($sent < $concurrency) {
    $ch = $makeHandle();
    curl_multi_add_handle($mh, $ch);
    $inFlight[(int) $ch] = microtime(true);
    $sent++;
}

do {
    do {
        $status = curl_multi_exec($mh, $running);
    } while ($status === CURLM_CALL_MULTI_PERFORM);

    while ($info = curl_multi_info_read($mh)) {
        $ch = $info['handle'];
        $key = (int) $ch;
        $end = microtime(true);
        $start = $inFlight[$key] ?? $end;
        unset($inFlight[$key]);

        $latMs = ($end - $start) * 1000.0;
        $latenciesMs[] = $latMs;

        $errno = curl_errno($ch);
        $code = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        if ($errno === 0 && $code >= 200 && $code < 300) {
            $ok++;
        } else {
            $fail++;
        }

        curl_multi_remove_handle($mh, $ch);
        curl_close($ch);

        if ($sent < $total) {
            $next = $makeHandle();
            curl_multi_add_handle($mh, $next);
            $inFlight[(int) $next] = microtime(true);
            $sent++;
        }
    }

    if ($running > 0) {
        curl_multi_select($mh, 0.2);
    }
} while ($running > 0);

curl_multi_close($mh);

$duration = microtime(true) - $startedAt;
sort($latenciesMs);
$count = count($latenciesMs);

$percentile = static function (float $p) use ($latenciesMs, $count): float {
    if ($count === 0) {
        return 0.0;
    }
    $idx = (int) floor(($p / 100.0) * ($count - 1));
    return $latenciesMs[max(0, min($count - 1, $idx))];
};

$p50 = $percentile(50);
$p90 = $percentile(90);
$p95 = $percentile(95);
$p99 = $percentile(99);
$rps = $duration > 0 ? ($total / $duration) : 0.0;

printf("URL: %s\n", $url);
printf("Total: %d  Concurrency: %d\n", $total, $concurrency);
printf("OK: %d  Fail: %d\n", $ok, $fail);
printf("Duration: %.3fs  RPS: %.2f\n", $duration, $rps);
printf("Latency ms: p50=%.1f  p90=%.1f  p95=%.1f  p99=%.1f\n", $p50, $p90, $p95, $p99);

