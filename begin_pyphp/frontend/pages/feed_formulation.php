<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$ingredients_res = call_api('/api/feed-formulation/ingredients', 'GET');
$ingredients = $ingredients_res['data'] ?? [];

$recent_res = call_api('/api/feed-formulation/recent', 'GET');
$recent = $recent_res['data'] ?? [];

$page_title = 'Feed Formulation - Begin Masimba';
$active_page = 'feed_formulation';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Feed Formulation</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Pearson Square and nutritional analysis for livestock feed</p>
        </div>
        <div class="flex space-x-3">
            <button class="bg-primary-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-primary-700">
                New Formulation
            </button>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Formulation Calculator -->
        <div class="lg:col-span-2 space-y-8">
            <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-6">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-6">Pearson Square Calculator</h3>
                <form id="calculatorForm" class="space-y-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Ingredient 1 (High Protein)</label>
                            <select name="ingredient_1" class="w-full bg-gray-50 dark:bg-gray-700 border-gray-200 dark:border-gray-600 rounded-lg p-2.5 text-sm">
                                <?php foreach ($ingredients as $ing): ?>
                                    <option value="<?php echo $ing['id']; ?>"><?php echo htmlspecialchars($ing['name']); ?> (<?php echo $ing['protein']; ?>%)</option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Ingredient 2 (Low Protein)</label>
                            <select name="ingredient_2" class="w-full bg-gray-50 dark:bg-gray-700 border-gray-200 dark:border-gray-600 rounded-lg p-2.5 text-sm">
                                <?php foreach (array_reverse($ingredients) as $ing): ?>
                                    <option value="<?php echo $ing['id']; ?>"><?php echo htmlspecialchars($ing['name']); ?> (<?php echo $ing['protein']; ?>%)</option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Target Protein Content (%)</label>
                        <input type="number" name="target_protein" step="0.1" value="20.0" class="w-full bg-gray-50 dark:bg-gray-700 border-gray-200 dark:border-gray-600 rounded-lg p-2.5 text-sm">
                    </div>
                    <button type="submit" class="w-full bg-primary-600 text-white font-bold py-3 rounded-xl hover:bg-primary-700 transition-colors">
                        Calculate Optimized Proportions
                    </button>
                </form>
                
                <div id="resultContainer" class="hidden mt-6 p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg border border-gray-200 dark:border-gray-600">
                    <h4 class="font-bold text-gray-900 dark:text-white mb-2">Result</h4>
                    <div id="resultContent" class="text-sm text-gray-700 dark:text-gray-300 space-y-2"></div>
                </div>
            </div>

            <!-- Recent Formulations -->
            <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                <div class="p-6 border-b border-gray-100 dark:border-gray-700">
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white">Recent Formulations</h3>
                </div>
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/30">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Formulation Name</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Target CP</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Cost/KG</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($recent as $item): ?>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($item['name']); ?></div>
                                <div class="text-xs text-gray-500">Calculated <?php echo $item['date']; ?></div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><?php echo $item['target_protein']; ?>%</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900 dark:text-white">$<?php echo number_format($item['cost_per_kg'], 2); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-2 py-1 text-[10px] font-bold rounded <?php 
                                    echo $item['status'] === 'active' ? 'bg-emerald-100 text-emerald-800' : 'bg-gray-100 text-gray-800'; 
                                ?>">
                                    <?php echo strtoupper($item['status']); ?>
                                </span>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Nutritional Guidelines -->
        <div class="space-y-6">
            <div class="bg-gray-900 rounded-xl p-6 text-white">
                <h3 class="text-lg font-bold mb-4">Nutritional Targets</h3>
                <div class="space-y-4">
                    <div class="flex justify-between items-center p-3 bg-white/5 rounded-lg">
                        <span class="text-sm opacity-80">Broiler Starter</span>
                        <span class="font-bold">22-24% CP</span>
                    </div>
                    <div class="flex justify-between items-center p-3 bg-white/5 rounded-lg">
                        <span class="text-sm opacity-80">Layers Mash</span>
                        <span class="font-bold">16-18% CP</span>
                    </div>
                    <div class="flex justify-between items-center p-3 bg-white/5 rounded-lg">
                        <span class="text-sm opacity-80">Dairy Meal (High)</span>
                        <span class="font-bold">18-20% CP</span>
                    </div>
                    <div class="flex justify-between items-center p-3 bg-white/5 rounded-lg">
                        <span class="text-sm opacity-80">Pig Finisher</span>
                        <span class="font-bold">13-14% CP</span>
                    </div>
                </div>
            </div>

            <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Ingredient Library</h3>
                <div class="space-y-4">
                    <?php foreach ($ingredients as $ing): ?>
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-bold text-gray-900 dark:text-white"><?php echo htmlspecialchars($ing['name']); ?></p>
                            <p class="text-[10px] text-gray-500 uppercase"><?php echo $ing['type']; ?></p>
                        </div>
                        <div class="text-right">
                            <p class="text-sm font-bold text-primary-600"><?php echo $ing['protein']; ?>% CP</p>
                            <p class="text-[10px] text-gray-500">$<?php echo $ing['cost_per_kg']; ?>/kg</p>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const API_BASE_URL = '<?php echo api_base_url(); ?>';
document.getElementById('calculatorForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = {
        ingredient_1: parseInt(formData.get('ingredient_1')),
        ingredient_2: parseInt(formData.get('ingredient_2')),
        target_protein: parseFloat(formData.get('target_protein'))
    };

    try {
        const response = await fetch(`${API_BASE_URL}/api/feed-formulation/calculate`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer <?php echo $_SESSION['access_token']; ?>',
                'X-Tenant-ID': '1'
            },
            body: JSON.stringify(data)
        });

        const result = await response.json();
        const resultContainer = document.getElementById('resultContainer');
        const resultContent = document.getElementById('resultContent');
        
        resultContainer.classList.remove('hidden');
        
        if (result.error) {
            resultContent.innerHTML = `<p class="text-red-600 font-bold">Error: ${result.error}</p>`;
        } else {
            resultContent.innerHTML = `
                <div class="grid grid-cols-2 gap-4">
                    <div class="p-3 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-600">
                        <p class="font-bold text-primary-600">${result.ingredients[0].name}</p>
                        <p class="text-2xl font-bold">${result.ingredients[0].percentage}%</p>
                        <p class="text-xs text-gray-500">${result.ingredients[0].parts} parts</p>
                    </div>
                    <div class="p-3 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-600">
                        <p class="font-bold text-primary-600">${result.ingredients[1].name}</p>
                        <p class="text-2xl font-bold">${result.ingredients[1].percentage}%</p>
                        <p class="text-xs text-gray-500">${result.ingredients[1].parts} parts</p>
                    </div>
                </div>
                <div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-600">
                    <div class="flex justify-between items-center">
                        <span class="font-medium">Final Cost:</span>
                        <span class="font-bold text-lg">$${result.analysis.cost_per_kg}/kg</span>
                    </div>
                    <div class="flex justify-between items-center mt-1">
                        <span class="font-medium">Total Parts:</span>
                        <span>${result.analysis.total_parts}</span>
                    </div>
                </div>
            `;
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred during calculation');
    }
});
</script>
