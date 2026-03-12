<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$chain = [];
$res = call_api('/api/blockchain/chain', 'GET');
if ($res['status'] === 200) $chain = $res['data'];

$page_title = 'Traceability - Begin Masimba';
$active_page = 'traceability';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Product Traceability</h1>
        <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">Blockchain-verified history of farm produce.</p>
    </div>

    <div class="relative border-l-4 border-primary-500 ml-4 space-y-8">
        <?php foreach (array_reverse($chain) as $block): ?>
            <?php if ($block['index'] === 0) continue; // Skip Genesis for display ?>
            <?php foreach ($block['transactions'] as $tx): ?>
            <div class="mb-8 ml-6">
                <span class="absolute flex items-center justify-center w-8 h-8 bg-primary-200 rounded-full -left-4 ring-4 ring-white dark:ring-gray-900 dark:bg-primary-900">
                    <svg class="w-4 h-4 text-primary-600 dark:text-primary-300" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path></svg>
                </span>
                <div class="p-4 bg-white rounded-lg border border-gray-200 shadow-sm dark:bg-gray-800 dark:border-gray-700">
                    <div class="justify-between items-center mb-3 sm:flex">
                        <time class="mb-1 text-xs font-normal text-gray-400 sm:order-last sm:mb-0"><?php echo htmlspecialchars($block['timestamp']); ?></time>
                        <div class="text-sm font-normal text-gray-500 lex dark:text-gray-300">
                            Transaction Hash: <span class="font-mono text-xs text-gray-400"><?php echo substr($block['hash'], 0, 16); ?>...</span>
                        </div>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white"><?php echo htmlspecialchars($tx['item']); ?></h3>
                    <p class="mb-2 text-base font-normal text-gray-500 dark:text-gray-400">
                        Moved <strong><?php echo htmlspecialchars($tx['quantity']); ?></strong> units from 
                        <span class="font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($tx['sender']); ?></span> to 
                        <span class="font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($tx['receiver']); ?></span>
                    </p>
                </div>
            </div>
            <?php endforeach; ?>
        <?php endforeach; ?>
    </div>
</main>

<?php require __DIR__ . '/../components/footer.php'; ?>
