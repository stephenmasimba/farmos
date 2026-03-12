<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$pest_res = call_api('/api/production-management/pest-disease', 'GET');
$pest_data = $pest_res['data'] ?? $pest_res ?? [];
$pest_reports = [];
if (is_array($pest_data)) {
    foreach ($pest_data as $item) {
        if (is_array($item)) {
            $pest_reports[] = $item;
        }
    }
}

$rotation_res = call_api('/api/production-management/crop-rotation', 'GET');
$rotation_data = $rotation_res['data'] ?? $rotation_res ?? [];
$rotation_analysis = [];
if (is_array($rotation_data)) {
    foreach ($rotation_data as $item) {
        if (is_array($item)) {
            $rotation_analysis[] = $item;
        }
    }
}

$page_title = 'Production Management - Begin Masimba';
$active_page = 'production_management';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Production Management</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Pest scouting and crop rotation analysis</p>
        </div>
    </div>

    <!-- Pest & Disease Section -->
    <div class="mb-12">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-xl font-bold text-gray-900 dark:text-white">Pest & Disease Scouting</h3>
            <button class="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700">
                New Report
            </button>
        </div>
        <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
            <?php foreach ($pest_reports as $report): ?>
            <?php
                $pestType = $report['pest_disease_type'] ?? 'Pest / Disease';
                $fieldName = $report['field_name'] ?? 'Unknown Field';
                $cropName = $report['crop_name'] ?? 'Unknown Crop';
                $severityLevel = $report['severity_level'] ?? 'medium';
                $severityDisplay = $report['severity_display'] ?? strtoupper($severityLevel);
                $affectedArea = isset($report['affected_area_percentage']) ? (int)$report['affected_area_percentage'] : 0;
                $recommendation = $report['treatment_recommendation'] ?? 'No recommendation available';
                $severityClass = ($severityLevel === 'high') ? 'bg-red-100 text-red-800' : 'bg-amber-100 text-amber-800';
                $areaWidth = max(0, min(100, $affectedArea));
            ?>
            <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 overflow-hidden">
                <div class="p-5">
                    <div class="flex justify-between items-start mb-3">
                        <div>
                            <h4 class="text-lg font-semibold text-gray-900 dark:text-white"><?php echo htmlspecialchars($pestType); ?></h4>
                            <p class="text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($fieldName); ?> • <?php echo htmlspecialchars($cropName); ?></p>
                        </div>
                        <span class="px-2 py-1 text-xs font-bold rounded <?php 
                            echo $severityClass; 
                        ?>">
                            <?php echo htmlspecialchars($severityDisplay); ?>
                        </span>
                    </div>
                    <div class="mb-4">
                        <div class="flex justify-between text-xs mb-1">
                            <span class="text-gray-500">Affected Area</span>
                            <span class="font-medium"><?php echo $affectedArea; ?>%</span>
                        </div>
                        <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-1.5">
                            <div class="bg-red-500 h-1.5 rounded-full" style="width: <?php echo $areaWidth; ?>%"></div>
                        </div>
                    </div>
                    <div class="bg-blue-50 dark:bg-blue-900/20 p-3 rounded-lg text-sm text-blue-800 dark:text-blue-300">
                        <strong>Recommendation:</strong> <?php echo htmlspecialchars($recommendation); ?>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Crop Rotation Section -->
    <div>
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">Crop Rotation Analysis</h3>
        <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/30">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Field</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Recent History</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Compliance</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Recommendation</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                    <?php foreach ($rotation_analysis as $analysis): ?>
                    <?php
                        $fieldName = $analysis['field_name'] ?? 'Field';
                        $areaHa = isset($analysis['area_hectares']) ? $analysis['area_hectares'] : 0;
                        $recentCrops = $analysis['recent_crops'] ?? [];
                        $rotationCompliance = !empty($analysis['rotation_compliance']);
                        $recommendation = $analysis['recommendation'] ?? '';
                    ?>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($fieldName); ?></div>
                            <div class="text-xs text-gray-500"><?php echo $areaHa; ?> ha</div>
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex space-x-2">
                                <?php foreach ($recentCrops as $crop): ?>
                                <span class="px-2 py-0.5 text-[10px] rounded bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300" title="<?php echo $crop['family']; ?>">
                                    <?php echo $crop['crop']; ?>
                                </span>
                                <?php endforeach; ?>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium <?php 
                                echo $rotationCompliance ? 'bg-emerald-100 text-emerald-800' : 'bg-red-100 text-red-800'; 
                            ?>">
                                <?php echo $rotationCompliance ? 'Compliant' : 'Violation'; ?>
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-500 dark:text-gray-400">
                            <?php echo htmlspecialchars($recommendation); ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
