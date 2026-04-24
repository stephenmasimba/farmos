<?php
if (empty($_SESSION['user'])) {
    header('Location: index.php?page=login');
    exit;
}

$summary = [];
$res = call_api('/api/financial/summary');
if ($res['status'] === 200) {
    $summary = $res['data']['summary'] ?? [];
}

$transactions = [];
$resTrans = call_api('/api/financial/records');
if ($resTrans['status'] === 200) {
    $transactions = $resTrans['data']['records'] ?? [];
}

$budgets = [];
$invoices = [];

$resBudgets = call_api('/api/financial/budgets');
if (($resBudgets['status'] ?? 0) === 200) {
    $rawBudgets = $resBudgets['data'] ?? [];
    if (!is_array($rawBudgets) && isset($resBudgets['data']['budgets']) && is_array($resBudgets['data']['budgets'])) {
        $rawBudgets = $resBudgets['data']['budgets'];
    }
    $budgets = is_array($rawBudgets) ? $rawBudgets : [];
}

$resInvoices = call_api('/api/financial/invoices');
if (($resInvoices['status'] ?? 0) === 200) {
    $rawInvoices = $resInvoices['data'] ?? [];
    if (!is_array($rawInvoices) && isset($resInvoices['data']['invoices']) && is_array($resInvoices['data']['invoices'])) {
        $rawInvoices = $resInvoices['data']['invoices'];
    }
    $invoices = is_array($rawInvoices) ? $rawInvoices : [];
}

$trialBalance = [];
$totalDebits = 0.0;
$totalCredits = 0.0;
$resTrialBalance = call_api('/api/accounting/trial-balance');
if (($resTrialBalance['status'] ?? 0) === 200) {
    $trialPayload = $resTrialBalance['data'] ?? [];
    $trialBalance = is_array($trialPayload['accounts'] ?? null) ? $trialPayload['accounts'] : [];
    $totalDebits = (float) ($trialPayload['total_debits'] ?? 0);
    $totalCredits = (float) ($trialPayload['total_credits'] ?? 0);
}

$receivables = [];
$receivableAging = ['current' => 0, '1_30' => 0, '31_60' => 0, '61_90' => 0, '90_plus' => 0];
$resReceivables = call_api('/api/accounting/receivables');
if (($resReceivables['status'] ?? 0) === 200) {
    $rcvPayload = $resReceivables['data'] ?? [];
    $receivables = is_array($rcvPayload['items'] ?? null) ? $rcvPayload['items'] : [];
    if (is_array($rcvPayload['aging'] ?? null)) {
        $receivableAging = array_merge($receivableAging, $rcvPayload['aging']);
    }
}

$payables = [];
$payableAging = ['current' => 0, '1_30' => 0, '31_60' => 0, '61_90' => 0, '90_plus' => 0];
$resPayables = call_api('/api/accounting/payables');
if (($resPayables['status'] ?? 0) === 200) {
    $payPayload = $resPayables['data'] ?? [];
    $payables = is_array($payPayload['items'] ?? null) ? $payPayload['items'] : [];
    if (is_array($payPayload['aging'] ?? null)) {
        $payableAging = array_merge($payableAging, $payPayload['aging']);
    }
}

$accounts = [];
$resAccounts = call_api('/api/accounting/accounts');
if (($resAccounts['status'] ?? 0) === 200) {
    $accountsPayload = $resAccounts['data'] ?? [];
    $accounts = is_array($accountsPayload) ? $accountsPayload : [];
}

$page_title = 'Financial - Begin Masimba';
$active_page = 'financial';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto">
    <div id="financialNotice" class="hidden mb-4 rounded-lg border px-4 py-3 text-sm"></div>
    <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 mb-8">
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700">
            <div class="px-4 py-5 sm:p-6">
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Total Revenue</dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900 dark:text-white">$<?php echo number_format($summary['total_income'] ?? 0, 2); ?></dd>
            </div>
        </div>
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700">
            <div class="px-4 py-5 sm:p-6">
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Total Expenses</dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900 dark:text-white">$<?php echo number_format($summary['total_expense'] ?? 0, 2); ?></dd>
            </div>
        </div>
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700">
            <div class="px-4 py-5 sm:p-6">
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Net Profit</dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900 dark:text-white">$<?php echo number_format($summary['net_profit'] ?? 0, 2); ?></dd>
            </div>
        </div>
    </div>

    <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Transactions</h2>
        <button onclick="openTransactionModal()" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm transition-colors flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
            Add Transaction
        </button>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700 mb-8">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700/50">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Date</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Description</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Category</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Type</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Amount</th>
                </tr>
            </thead>
            <tbody id="transactionsList" class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                <?php if (empty($transactions)): ?>
                    <tr><td colspan="5" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">No transactions found.</td></tr>
                <?php else: ?>
                    <?php foreach ($transactions as $transaction): ?>
                    <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($transaction['date']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars($transaction['description']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($transaction['category']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full <?php echo $transaction['type'] === 'income' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'; ?>">
                                <?php echo htmlspecialchars(ucfirst($transaction['type'])); ?>
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium <?php echo $transaction['type'] === 'income' ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'; ?>">
                            $<?php echo number_format($transaction['amount'], 2); ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

    <!-- Budget Section -->
    <div class="mb-8" id="budgetsGrid">
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Budget Tracking</h2>
            <button type="button" onclick="openBudgetModal()" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm transition-colors flex items-center gap-2 text-sm">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
                Set Budget
            </button>
        </div>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <?php foreach ($budgets as $budget): ?>
            <?php 
                $percent = ($budget['limit'] > 0) ? ($budget['spent'] / $budget['limit']) * 100 : 0;
                $color = $percent > 90 ? 'bg-red-600' : ($percent > 75 ? 'bg-yellow-500' : 'bg-green-500');
            ?>
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-5 hover:shadow-md transition-shadow">
                <div class="flex justify-between items-center mb-2">
                    <h3 class="text-lg font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($budget['category']); ?></h3>
                    <span class="text-sm text-gray-500 dark:text-gray-400"><?php echo ucfirst($budget['period']); ?></span>
                </div>
                <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2.5 mb-2">
                    <div class="<?php echo $color; ?> h-2.5 rounded-full" style="width: <?php echo min($percent, 100); ?>%"></div>
                </div>
                <div class="flex justify-between text-sm">
                    <span class="text-gray-600 dark:text-gray-400">$<?php echo number_format($budget['spent'], 2); ?> spent</span>
                    <span class="font-medium text-gray-900 dark:text-white">of $<?php echo number_format($budget['limit'], 2); ?></span>
                </div>
            </div>
            <?php endforeach; ?>
            <?php if (empty($budgets)): ?>
            <div class="col-span-full rounded-xl border border-dashed border-gray-300 dark:border-gray-600 p-6 text-sm text-gray-500 dark:text-gray-400">
                No budgets set yet.
            </div>
            <?php endif; ?>
        </div>
    </div>

    <div class="mb-8">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
            <div>
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Budget vs Actual</h2>
                <p class="text-sm text-gray-500 dark:text-gray-400">Compare budget limits against actual expenses and identify overspending.</p>
            </div>
            <button type="button" onclick="refreshBudgetVariance()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 px-3 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 text-sm">Refresh</button>
        </div>
        <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Category</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Budget</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Actual</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Variance</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Status</th>
                    </tr>
                </thead>
                <tbody id="budgetVarianceList" class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                    <tr><td colspan="5" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">Loading budget performance...</td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <div class="mb-8">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
            <div>
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Expense Classification Rules</h2>
                <p class="text-sm text-gray-500 dark:text-gray-400">Manage keyword-driven category mappings to automate expense classification.</p>
            </div>
            <div class="flex flex-wrap gap-2">
                <button type="button" onclick="openCategoryMappingModal()" class="bg-primary-600 text-white px-3 py-2 rounded-md hover:bg-primary-700 text-sm">Add Rule</button>
                <button type="button" onclick="refreshCategoryMappings()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 px-3 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 text-sm">Refresh Rules</button>
                <button type="button" onclick="openPeriodCloseModal()" class="bg-amber-600 text-white px-3 py-2 rounded-md hover:bg-amber-700 text-sm">Close Period</button>
            </div>
        </div>
        <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Keyword</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Category</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Active</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Actions</th>
                    </tr>
                </thead>
                <tbody id="categoryMappingsList" class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                    <tr><td colspan="4" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">Loading category mappings...</td></tr>
                </tbody>
            </table>
            <div class="px-6 py-4 border-t border-gray-100 dark:border-gray-700 text-sm text-gray-600 dark:text-gray-400">
                <div id="periodListContainer">Loading financial close history...</div>
            </div>
        </div>
    </div>

    <div class="mb-8">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
            <div>
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Accounting Statements</h2>
                <p class="text-sm text-gray-500 dark:text-gray-400">Seed a chart of accounts and generate P&amp;L, balance sheet, cash flow, and journal drill-down.</p>
            </div>
            <div class="flex flex-wrap gap-2">
                <button type="button" onclick="seedChartOfAccounts(false)" class="bg-slate-700 text-white px-3 py-2 rounded-md hover:bg-slate-800 text-sm">Seed COA</button>
                <button type="button" onclick="seedChartOfAccounts(true)" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 px-3 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 text-sm">Seed (force)</button>
            </div>
        </div>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden rounded-xl border border-gray-100 dark:border-gray-700 p-5">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">Run Statement</h3>
                <form id="accountingReportForm" class="grid grid-cols-1 gap-3">
                    <select name="report_type" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                        <option value="pl">Profit &amp; Loss</option>
                        <option value="bs">Balance Sheet</option>
                        <option value="cf">Cash Flow</option>
                    </select>
                    <div class="grid grid-cols-2 gap-3">
                        <input type="date" name="start_date" value="<?php echo date('Y-m-01'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                        <input type="date" name="end_date" value="<?php echo date('Y-m-d'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    </div>
                    <input type="date" name="as_of" value="<?php echo date('Y-m-d'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 text-sm">Run</button>
                </form>
            </div>

            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden rounded-xl border border-gray-100 dark:border-gray-700 p-5 lg:col-span-2">
                <div class="flex items-center justify-between gap-3 mb-3">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Output</h3>
                    <button type="button" onclick="clearAccountingOutput()" class="text-sm text-primary-600 hover:text-primary-700">Clear</button>
                </div>
                <pre id="accountingOutput" class="p-3 text-xs bg-gray-50 dark:bg-gray-900/40 rounded border border-gray-200 dark:border-gray-700 overflow-x-auto max-h-72">Run a statement to see results.</pre>
            </div>

            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden rounded-xl border border-gray-100 dark:border-gray-700 p-5 lg:col-span-3">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">Journal Tools</h3>
                <div class="grid grid-cols-1 md:grid-cols-4 gap-3 mb-3">
                    <input type="number" id="journalEntryId" placeholder="Entry ID" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <input type="date" id="journalReverseDate" value="<?php echo date('Y-m-d'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <button type="button" onclick="loadJournalDetails()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 text-sm">Details</button>
                    <button type="button" onclick="reverseJournalEntry()" class="bg-amber-600 text-white px-4 py-2 rounded-md hover:bg-amber-700 text-sm">Reverse</button>
                </div>
                <pre id="journalToolsOutput" class="p-3 text-xs bg-gray-50 dark:bg-gray-900/40 rounded border border-gray-200 dark:border-gray-700 overflow-x-auto max-h-72">Enter an Entry ID to view details or reverse.</pre>
            </div>
        </div>
    </div>

    <div class="mb-8">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
            <div>
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white">BI & Planning</h2>
                <p class="text-sm text-gray-500 dark:text-gray-400">Configurable dashboards, export connectors, drill-down reports, and predictive planning.</p>
            </div>
            <div class="flex flex-wrap gap-2">
                <button type="button" onclick="refreshBiConnectors()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 px-3 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 text-sm">Refresh</button>
                <button type="button" onclick="refreshForecast()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 px-3 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 text-sm">Forecast</button>
            </div>
        </div>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden rounded-xl border border-gray-100 dark:border-gray-700 p-5">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">Export Connectors</h3>
                <form id="createConnectorForm" class="grid grid-cols-1 gap-3 mb-4">
                    <input type="text" name="name" placeholder="Connector name (e.g. PowerBI)" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <select name="format" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                        <option value="json">JSON</option>
                        <option value="csv">CSV (metadata only)</option>
                    </select>
                    <button type="submit" class="bg-slate-700 text-white px-4 py-2 rounded-md hover:bg-slate-800 text-sm">Create Connector</button>
                </form>
                <div class="text-sm text-gray-600 dark:text-gray-400 mb-2">Connector data endpoint returns rows for the selected date range.</div>
                <div id="connectorsList" class="text-sm text-gray-600 dark:text-gray-400">Loading connectors...</div>
            </div>

            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden rounded-xl border border-gray-100 dark:border-gray-700 p-5">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">Interactive Drill-down Reports</h3>
                <form id="runReportForm" class="grid grid-cols-1 gap-3 mb-4">
                    <div class="grid grid-cols-2 gap-3">
                        <input type="date" name="start_date" value="<?php echo date('Y-m-01'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                        <input type="date" name="end_date" value="<?php echo date('Y-m-d'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                        <select name="direction" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                            <option value="expense">Expenses</option>
                            <option value="income">Income</option>
                            <option value="both">Both</option>
                        </select>
                        <select name="group_by" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                            <option value="category">Category</option>
                            <option value="month">Month</option>
                            <option value="vendor">Vendor</option>
                            <option value="payment_method">Payment Method</option>
                            <option value="status">Status</option>
                        </select>
                    </div>
                    <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 text-sm">Run Report</button>
                </form>
                <div class="overflow-x-auto border border-gray-200 dark:border-gray-700 rounded-lg">
                    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                        <thead class="bg-gray-50 dark:bg-gray-700/50">
                            <tr>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Bucket</th>
                                <th class="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase">Total</th>
                                <th class="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase">Count</th>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                            </tr>
                        </thead>
                        <tbody id="reportBucketsList" class="divide-y divide-gray-200 dark:divide-gray-700">
                            <tr><td colspan="4" class="px-6 py-6 text-sm text-gray-500 dark:text-gray-400 text-center">Run a report to see results.</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden rounded-xl border border-gray-100 dark:border-gray-700 p-5">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">Predictive Planning</h3>
                <div class="text-sm text-gray-600 dark:text-gray-400 mb-3">Forecast uses historical trends when no manual forecast is set.</div>
                <div class="overflow-x-auto border border-gray-200 dark:border-gray-700 rounded-lg">
                    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                        <thead class="bg-gray-50 dark:bg-gray-700/50">
                            <tr>
                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Period</th>
                                <th class="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase">Revenue</th>
                                <th class="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase">Expenses</th>
                                <th class="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase">Net</th>
                            </tr>
                        </thead>
                        <tbody id="forecastList" class="divide-y divide-gray-200 dark:divide-gray-700">
                            <tr><td colspan="4" class="px-6 py-6 text-sm text-gray-500 dark:text-gray-400 text-center">Loading forecast...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Invoices Section -->
    <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Invoices</h2>
            <button type="button" onclick="openInvoiceModal()" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm transition-colors flex items-center gap-2 text-sm">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                Create Invoice
            </button>
        </div>
        <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Invoice #</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Customer</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Date Due</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Amount</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Action</th>
                    </tr>
                </thead>
                <tbody id="invoicesList" class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                    <?php if (empty($invoices)): ?>
                        <tr><td colspan="6" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">No invoices found.</td></tr>
                    <?php else: ?>
                        <?php foreach ($invoices as $invoice): ?>
                        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($invoice['invoice_number']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($invoice['customer_name']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($invoice['due_date']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">$<?php echo number_format($invoice['amount'], 2); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full <?php echo $invoice['status'] === 'paid' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200'; ?>">
                                    <?php echo htmlspecialchars(ucfirst($invoice['status'])); ?>
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                <a href="#" class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300">Download</a>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>

    <div class="mb-8">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Accounting Platform</h2>
            <div class="flex flex-wrap gap-2">
                <button type="button" onclick="openAccountModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 px-3 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 text-sm">New Account</button>
                <button type="button" onclick="openJournalModal()" class="bg-primary-600 text-white px-3 py-2 rounded-md hover:bg-primary-700 text-sm">Post Journal</button>
                <button type="button" onclick="openReceivableModal()" class="bg-emerald-600 text-white px-3 py-2 rounded-md hover:bg-emerald-700 text-sm">Add Receivable</button>
                <button type="button" onclick="openPayableModal()" class="bg-amber-600 text-white px-3 py-2 rounded-md hover:bg-amber-700 text-sm">Add Payable</button>
                <button type="button" onclick="refreshAdvancedAccountingMetrics()" class="bg-gray-800 text-white px-3 py-2 rounded-md hover:bg-gray-700 text-sm">Refresh Advanced Data</button>
            </div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Trial Balance Debits</p>
                <p class="text-xl font-bold text-gray-900 dark:text-white">$<?php echo number_format($totalDebits, 2); ?></p>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Trial Balance Credits</p>
                <p class="text-xl font-bold text-gray-900 dark:text-white">$<?php echo number_format($totalCredits, 2); ?></p>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Open Receivables</p>
                <p class="text-xl font-bold text-emerald-600">$<?php echo number_format(array_sum(array_map(fn($i) => (float)($i['amount'] ?? 0), $receivables)), 2); ?></p>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Open Payables</p>
                <p class="text-xl font-bold text-amber-600">$<?php echo number_format(array_sum(array_map(fn($i) => (float)($i['amount'] ?? 0), $payables)), 2); ?></p>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Currencies</p>
                <p id="currencyCount" class="text-xl font-bold text-indigo-600">0</p>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Bank Accounts</p>
                <p id="bankAccountCount" class="text-xl font-bold text-sky-600">0</p>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Fixed Assets</p>
                <p id="fixedAssetCount" class="text-xl font-bold text-emerald-600">0</p>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Tax Codes</p>
                <p id="taxCodeCount" class="text-xl font-bold text-yellow-600">0</p>
            </div>
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <p class="text-xs text-gray-500 uppercase">Journal Approvals</p>
                <p id="journalApprovalCount" class="text-xl font-bold text-red-600">0</p>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700">
                <div class="px-6 py-3 border-b border-gray-100 dark:border-gray-700 text-sm font-semibold text-gray-900 dark:text-white">Top Trial Balance Accounts</div>
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/50">
                        <tr>
                            <th class="px-6 py-2 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                            <th class="px-6 py-2 text-left text-xs font-medium text-gray-500 uppercase">Account</th>
                            <th class="px-6 py-2 text-left text-xs font-medium text-gray-500 uppercase">Debit</th>
                            <th class="px-6 py-2 text-left text-xs font-medium text-gray-500 uppercase">Credit</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php $tbRows = array_slice($trialBalance, 0, 8); ?>
                        <?php if (empty($tbRows)): ?>
                            <tr><td colspan="4" class="px-6 py-4 text-sm text-gray-500 text-center">No journal activity yet.</td></tr>
                        <?php else: ?>
                            <?php foreach ($tbRows as $tb): ?>
                                <tr>
                                    <td class="px-6 py-2 text-sm text-gray-700 dark:text-gray-300"><?php echo htmlspecialchars((string)($tb['code'] ?? '')); ?></td>
                                    <td class="px-6 py-2 text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars((string)($tb['name'] ?? '')); ?></td>
                                    <td class="px-6 py-2 text-sm text-gray-700 dark:text-gray-300">$<?php echo number_format((float)($tb['total_debit'] ?? 0), 2); ?></td>
                                    <td class="px-6 py-2 text-sm text-gray-700 dark:text-gray-300">$<?php echo number_format((float)($tb['total_credit'] ?? 0), 2); ?></td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>

            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700 p-4">
                <h3 class="text-sm font-semibold text-gray-900 dark:text-white mb-3">Aging Snapshot</h3>
                <div class="grid grid-cols-2 gap-3 text-sm">
                    <div class="rounded-lg border border-gray-200 dark:border-gray-700 p-3">
                        <p class="text-xs text-gray-500 uppercase">Receivables 1-30</p>
                        <p class="font-semibold text-emerald-600">$<?php echo number_format((float)($receivableAging['1_30'] ?? 0), 2); ?></p>
                    </div>
                    <div class="rounded-lg border border-gray-200 dark:border-gray-700 p-3">
                        <p class="text-xs text-gray-500 uppercase">Receivables 90+</p>
                        <p class="font-semibold text-red-600">$<?php echo number_format((float)($receivableAging['90_plus'] ?? 0), 2); ?></p>
                    </div>
                    <div class="rounded-lg border border-gray-200 dark:border-gray-700 p-3">
                        <p class="text-xs text-gray-500 uppercase">Payables 1-30</p>
                        <p class="font-semibold text-amber-600">$<?php echo number_format((float)($payableAging['1_30'] ?? 0), 2); ?></p>
                    </div>
                    <div class="rounded-lg border border-gray-200 dark:border-gray-700 p-3">
                        <p class="text-xs text-gray-500 uppercase">Payables 90+</p>
                        <p class="font-semibold text-red-600">$<?php echo number_format((float)($payableAging['90_plus'] ?? 0), 2); ?></p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

<!-- Accounting Account Modal -->
<div id="accountModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Create Account</h3>
        <form id="addAccountForm">
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Code</label>
                <input type="text" name="code" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
                <input type="text" name="name" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Type</label>
                <select name="type" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
                    <option value="asset">Asset</option>
                    <option value="liability">Liability</option>
                    <option value="equity">Equity</option>
                    <option value="income">Income</option>
                    <option value="expense">Expense</option>
                </select>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Subtype (optional)</label>
                <input type="text" name="subtype" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeAccountModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 text-sm">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 text-sm">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Journal Entry Modal -->
<div id="journalModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-2xl w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Post Journal Entry</h3>
        <form id="journalEntryForm">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date</label>
                    <input type="date" name="journal_date" value="<?php echo date('Y-m-d'); ?>" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Reference</label>
                    <input type="text" name="reference_no" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Memo</label>
                    <input type="text" name="memo" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mb-4">
                <?php for ($line = 1; $line <= 2; $line++): ?>
                <div class="rounded-lg border border-gray-200 dark:border-gray-700 p-3">
                    <p class="text-xs font-semibold text-gray-500 mb-2">Line <?php echo $line; ?></p>
                    <div class="mb-2">
                        <label class="block text-xs text-gray-600 dark:text-gray-400 mb-1">Account</label>
                        <select name="line<?php echo $line; ?>_account_id" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white text-sm">
                            <option value="">Select account</option>
                            <?php foreach ($accounts as $acc): ?>
                                <option value="<?php echo (int) ($acc['id'] ?? 0); ?>"><?php echo htmlspecialchars((string) ($acc['code'] ?? '')); ?> - <?php echo htmlspecialchars((string) ($acc['name'] ?? '')); ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="grid grid-cols-2 gap-2 mb-2">
                        <div>
                            <label class="block text-xs text-gray-600 dark:text-gray-400 mb-1">Debit</label>
                            <input type="number" step="0.01" min="0" name="line<?php echo $line; ?>_debit" value="0" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white text-sm">
                        </div>
                        <div>
                            <label class="block text-xs text-gray-600 dark:text-gray-400 mb-1">Credit</label>
                            <input type="number" step="0.01" min="0" name="line<?php echo $line; ?>_credit" value="0" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white text-sm">
                        </div>
                    </div>
                    <div>
                        <label class="block text-xs text-gray-600 dark:text-gray-400 mb-1">Description</label>
                        <input type="text" name="line<?php echo $line; ?>_description" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white text-sm">
                    </div>
                </div>
                <?php endfor; ?>
            </div>

            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeJournalModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 text-sm">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 text-sm">Post Entry</button>
            </div>
        </form>
    </div>
</div>

<!-- Receivable Modal -->
<div id="receivableModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add Receivable</h3>
        <form id="addReceivableForm">
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Customer Name</label>
                <input type="text" name="party_name" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Reference</label>
                <input type="text" name="reference_no" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="grid grid-cols-2 gap-3 mb-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Amount</label>
                    <input type="number" step="0.01" min="0.01" name="amount" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Due Date</label>
                    <input type="date" name="due_date" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeReceivableModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 text-sm">Cancel</button>
                <button type="submit" class="bg-emerald-600 text-white px-4 py-2 rounded-md hover:bg-emerald-700 text-sm">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Payable Modal -->
<div id="payableModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add Payable</h3>
        <form id="addPayableForm">
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Vendor Name</label>
                <input type="text" name="party_name" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Reference</label>
                <input type="text" name="reference_no" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="grid grid-cols-2 gap-3 mb-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Amount</label>
                    <input type="number" step="0.01" min="0.01" name="amount" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Due Date</label>
                    <input type="date" name="due_date" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closePayableModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 text-sm">Cancel</button>
                <button type="submit" class="bg-amber-600 text-white px-4 py-2 rounded-md hover:bg-amber-700 text-sm">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Add Transaction Modal -->
<div id="transactionModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add Transaction</h3>
        <form id="addTransactionForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Type</label>
                <select name="type" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <option value="income">Income</option>
                    <option value="expense">Expense</option>
                </select>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Category</label>
                <input type="text" name="category" placeholder="Optional (auto-classified if blank)" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Vendor / Payee</label>
                <input type="text" name="vendor" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Description</label>
                <input type="text" name="description" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Tags</label>
                <input type="text" name="tags" placeholder="comma,separated,tags" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Amount</label>
                <input type="number" step="0.01" name="amount" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date</label>
                <input type="date" name="date" required value="<?php echo date('Y-m-d'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeTransactionModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Add Budget Modal -->
<div id="budgetModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Set Budget</h3>
        <form id="addBudgetForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Category</label>
                <input type="text" name="category" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Limit Amount</label>
                <input type="number" step="0.01" name="limit" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Period</label>
                <select name="period" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <option value="monthly">Monthly</option>
                    <option value="yearly">Yearly</option>
                </select>
            </div>
            <input type="hidden" name="year" value="<?php echo date('Y'); ?>">
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeBudgetModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Category Mapping Modal -->
<div id="categoryMappingModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add Category Mapping Rule</h3>
        <form id="categoryMappingForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Keyword</label>
                <input type="text" name="keyword" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Category</label>
                <input type="text" name="category" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="grid grid-cols-2 gap-3 mb-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Match Field</label>
                    <select name="match_field" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                        <option value="combined">Combined</option>
                        <option value="description">Description</option>
                        <option value="reference_number">Reference</option>
                        <option value="vendor">Vendor</option>
                        <option value="payment_method">Payment method</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Match Type</label>
                    <select name="match_type" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                        <option value="contains">Contains</option>
                        <option value="starts_with">Starts with</option>
                        <option value="equals">Equals</option>
                        <option value="regex">Regex</option>
                    </select>
                </div>
            </div>
            <div class="grid grid-cols-2 gap-3 mb-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Priority</label>
                    <input type="number" name="priority" value="0" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Tags</label>
                    <input type="text" name="tags" placeholder="comma,separated" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
            </div>
            <div class="mb-4 flex items-center gap-3">
                <input type="checkbox" id="mappingActive" name="active" value="1" checked class="h-4 w-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500">
                <label for="mappingActive" class="text-sm text-gray-700 dark:text-gray-300">Active</label>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeCategoryMappingModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 text-sm">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 text-sm">Save Rule</button>
            </div>
        </form>
    </div>
</div>

<!-- Period Close Modal -->
<div id="periodCloseModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Close Financial Period</h3>
        <form id="closePeriodForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Period Type</label>
                <select name="period_type" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <option value="monthly">Monthly</option>
                    <option value="yearly">Yearly</option>
                </select>
            </div>
            <div class="grid grid-cols-2 gap-3 mb-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Year</label>
                    <input type="number" name="year" min="1900" max="2100" value="<?php echo date('Y'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Month</label>
                    <input type="number" name="month" min="1" max="12" value="<?php echo date('n'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
            </div>
            <div class="mb-4 flex items-center gap-3">
                <input type="checkbox" id="forceClosePeriod" name="force" value="1" class="h-4 w-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500">
                <label for="forceClosePeriod" class="text-sm text-gray-700 dark:text-gray-300">Force close (bypass failed checks)</label>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closePeriodCloseModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 text-sm">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 text-sm">Close Period</button>
            </div>
        </form>
    </div>
</div>

<!-- Budget Drilldown Modal -->
<div id="budgetDrilldownModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-4xl w-full p-6 border border-gray-100 dark:border-gray-700 m-4">
        <div class="flex items-center justify-between gap-3 mb-4">
            <h3 id="budgetDrilldownTitle" class="text-lg font-bold text-gray-900 dark:text-white">Budget Drilldown</h3>
            <button type="button" onclick="closeBudgetDrilldown()" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        <div class="overflow-x-auto border border-gray-200 dark:border-gray-700 rounded-lg">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/50">
                    <tr>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Vendor</th>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                        <th class="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase">Amount</th>
                    </tr>
                </thead>
                <tbody id="budgetDrilldownList" class="divide-y divide-gray-200 dark:divide-gray-700">
                    <tr><td colspan="4" class="px-6 py-8 text-sm text-gray-500 dark:text-gray-400 text-center">Loading...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Create Invoice Modal -->
<div id="invoiceModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Create Invoice</h3>
        <form id="addInvoiceForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Customer Name</label>
                <input type="text" name="customer_name" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Items (Description)</label>
                <textarea name="items" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm"></textarea>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Total Amount</label>
                <input type="number" step="0.01" name="amount" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Due Date</label>
                <input type="date" name="due_date" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeInvoiceModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Create</button>
            </div>
        </form>
    </div>
</div>

<script>
const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
const FARM_ID = <?php echo json_encode((int) ($_SESSION['farm_id'] ?? 1)); ?>;
const API_BASE_URL = window.AppApi.baseUrl;
const headers = window.AppApi.jsonHeaders();

function openTransactionModal() { document.getElementById('transactionModal').classList.remove('hidden'); }
function closeTransactionModal() { document.getElementById('transactionModal').classList.add('hidden'); }

function openBudgetModal() { document.getElementById('budgetModal').classList.remove('hidden'); }
function closeBudgetModal() { document.getElementById('budgetModal').classList.add('hidden'); }

function openInvoiceModal() { document.getElementById('invoiceModal').classList.remove('hidden'); }
function closeInvoiceModal() { document.getElementById('invoiceModal').classList.add('hidden'); }

function openAccountModal() { document.getElementById('accountModal').classList.remove('hidden'); }
function closeAccountModal() { document.getElementById('accountModal').classList.add('hidden'); }

function openJournalModal() { document.getElementById('journalModal').classList.remove('hidden'); }
function closeJournalModal() { document.getElementById('journalModal').classList.add('hidden'); }

function openReceivableModal() { document.getElementById('receivableModal').classList.remove('hidden'); }
function closeReceivableModal() { document.getElementById('receivableModal').classList.add('hidden'); }

function openPayableModal() { document.getElementById('payableModal').classList.remove('hidden'); }
function closePayableModal() { document.getElementById('payableModal').classList.add('hidden'); }

function showFinancialNotice(message, kind = 'success') {
    const el = document.getElementById('financialNotice');
    if (!el) return;
    const styles = {
        success: 'border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300',
        error: 'border-red-200 bg-red-50 text-red-700 dark:border-red-700 dark:bg-red-900/30 dark:text-red-300',
        info: 'border-blue-200 bg-blue-50 text-blue-700 dark:border-blue-700 dark:bg-blue-900/30 dark:text-blue-300'
    };
    el.className = `mb-4 rounded-lg border px-4 py-3 text-sm ${styles[kind] || styles.info}`;
    el.textContent = message;
    el.classList.remove('hidden');
}

function clearAccountingOutput() {
    const out = document.getElementById('accountingOutput');
    if (out) out.textContent = '';
    const j = document.getElementById('journalToolsOutput');
    if (j) j.textContent = '';
}

async function seedChartOfAccounts(force) {
    try {
        const res = await fetch(`${API_BASE_URL}/api/accounting/seed-coa`, {
            method: 'POST',
            headers,
            body: JSON.stringify({ farm_id: FARM_ID, force: force ? 1 : 0 })
        });
        if (res.ok) {
            showFinancialNotice('Chart of accounts seeded.', 'success');
            return;
        }
        const err = await res.json().catch(() => ({}));
        showFinancialNotice(err?.error?.message || err?.message || 'Failed to seed COA.', 'error');
    } catch (e) {
        showFinancialNotice('Failed to seed COA.', 'error');
    }
}

document.getElementById('accountingReportForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const raw = Object.fromEntries(new FormData(e.target));
    const type = String(raw.report_type || 'pl');
    const start = String(raw.start_date || '');
    const end = String(raw.end_date || '');
    const asOf = String(raw.as_of || '');

    const out = document.getElementById('accountingOutput');
    if (out) out.textContent = 'Loading...';

    try {
        let url = '';
        if (type === 'pl') {
            url = `${API_BASE_URL}/api/accounting/profit-loss?farm_id=${encodeURIComponent(String(FARM_ID))}&start_date=${encodeURIComponent(start)}&end_date=${encodeURIComponent(end)}`;
        } else if (type === 'bs') {
            url = `${API_BASE_URL}/api/accounting/balance-sheet?farm_id=${encodeURIComponent(String(FARM_ID))}&as_of=${encodeURIComponent(asOf)}`;
        } else {
            url = `${API_BASE_URL}/api/accounting/cash-flow?farm_id=${encodeURIComponent(String(FARM_ID))}&start_date=${encodeURIComponent(start)}&end_date=${encodeURIComponent(end)}`;
        }

        const res = await fetch(url, { headers });
        const payload = await res.json().catch(() => ({}));
        if (!res.ok) {
            if (out) out.textContent = payload?.error?.message || payload?.message || `Request failed (${res.status})`;
            return;
        }
        if (out) out.textContent = JSON.stringify(payload, null, 2);
    } catch (err) {
        if (out) out.textContent = err?.message || 'Failed to run statement';
    }
});

async function loadJournalDetails() {
    const id = Number(document.getElementById('journalEntryId')?.value || 0);
    const out = document.getElementById('journalToolsOutput');
    if (!id || id <= 0) {
        if (out) out.textContent = 'Entry ID is required.';
        return;
    }
    if (out) out.textContent = 'Loading...';
    try {
        const res = await fetch(`${API_BASE_URL}/api/accounting/journal-entries/${id}?farm_id=${encodeURIComponent(String(FARM_ID))}`, { headers });
        const payload = await res.json().catch(() => ({}));
        if (!res.ok) {
            if (out) out.textContent = payload?.error?.message || payload?.message || `Request failed (${res.status})`;
            return;
        }
        if (out) out.textContent = JSON.stringify(payload, null, 2);
    } catch (err) {
        if (out) out.textContent = err?.message || 'Failed to load journal entry';
    }
}

async function reverseJournalEntry() {
    const id = Number(document.getElementById('journalEntryId')?.value || 0);
    const reverseDate = String(document.getElementById('journalReverseDate')?.value || '');
    const out = document.getElementById('journalToolsOutput');
    if (!id || id <= 0) {
        if (out) out.textContent = 'Entry ID is required.';
        return;
    }
    if (out) out.textContent = 'Reversing...';
    try {
        const res = await fetch(`${API_BASE_URL}/api/accounting/journal-entries/${id}/reverse`, {
            method: 'POST',
            headers,
            body: JSON.stringify({ farm_id: FARM_ID, reverse_date: reverseDate })
        });
        const payload = await res.json().catch(() => ({}));
        if (!res.ok) {
            if (out) out.textContent = payload?.error?.message || payload?.message || `Request failed (${res.status})`;
            return;
        }
        if (out) out.textContent = JSON.stringify(payload, null, 2);
        showFinancialNotice('Journal entry reversed.', 'success');
    } catch (err) {
        if (out) out.textContent = err?.message || 'Failed to reverse entry';
    }
}

document.getElementById('addTransactionForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.farm_id = FARM_ID;
    if (typeof data.tags === 'string' && data.tags.trim() !== '') {
        data.tags = data.tags.split(',').map(t => t.trim()).filter(Boolean);
    } else {
        delete data.tags;
    }
    if (navigator.onLine) {
        const res = await fetch(`${API_BASE_URL}/api/financial/records`, { method: 'POST', headers, body: JSON.stringify(data) });
        if (res.ok) {
            window.location.reload();
            return;
        }
        showFinancialNotice('Failed to save transaction.', 'error');
    } else {
        await window.OfflineService.queueForSync({
            endpoint: '/financial/transactions',
            method: 'POST',
            data
        });
        closeTransactionModal();
        showFinancialNotice('Transaction queued for sync.', 'info');
    }
});

document.getElementById('addBudgetForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.farm_id = FARM_ID;
    const res = await fetch(`${API_BASE_URL}/api/financial/budgets`, { method: 'POST', headers, body: JSON.stringify(data) });
    if (res.ok) {
        window.location.reload();
        return;
    }
    showFinancialNotice('Failed to save budget.', 'error');
});

document.getElementById('addInvoiceForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.farm_id = FARM_ID;
    const res = await fetch(`${API_BASE_URL}/api/financial/invoices`, { method: 'POST', headers, body: JSON.stringify(data) });
    if (res.ok) {
        window.location.reload();
        return;
    }
    showFinancialNotice('Failed to create invoice.', 'error');
});

document.getElementById('addAccountForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    const res = await fetch(`${API_BASE_URL}/api/accounting/accounts`, { method: 'POST', headers, body: JSON.stringify(data) });
    if (res.ok) {
        window.location.reload();
        return;
    }
    showFinancialNotice('Failed to create account.', 'error');
});

document.getElementById('journalEntryForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    const lines = [1, 2].map((idx) => ({
        account_id: Number(data[`line${idx}_account_id`] || 0),
        debit: Number(data[`line${idx}_debit`] || 0),
        credit: Number(data[`line${idx}_credit`] || 0),
        description: data[`line${idx}_description`] || ''
    }));

    const payload = {
        journal_date: data.journal_date,
        reference_no: data.reference_no,
        memo: data.memo,
        lines
    };

    const res = await fetch(`${API_BASE_URL}/api/accounting/journal-entries`, { method: 'POST', headers, body: JSON.stringify(payload) });
    if (res.ok) {
        window.location.reload();
        return;
    }

    let msg = 'Failed to post journal entry.';
    try {
        const err = await res.json();
        if (err && err.errors && err.errors.lines) msg = err.errors.lines;
    } catch (error) {}
    showFinancialNotice(msg, 'error');
});

document.getElementById('addReceivableForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    const res = await fetch(`${API_BASE_URL}/api/accounting/receivables`, { method: 'POST', headers, body: JSON.stringify(data) });
    if (res.ok) {
        window.location.reload();
        return;
    }
    showFinancialNotice('Failed to add receivable.', 'error');
});

document.getElementById('addPayableForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    const res = await fetch(`${API_BASE_URL}/api/accounting/payables`, { method: 'POST', headers, body: JSON.stringify(data) });
    if (res.ok) {
        window.location.reload();
        return;
    }
    showFinancialNotice('Failed to add payable.', 'error');
});

document.getElementById('categoryMappingForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.farm_id = FARM_ID;
    if (typeof data.tags === 'string' && data.tags.trim() !== '') {
        data.tags = data.tags.split(',').map(t => t.trim()).filter(Boolean);
    } else {
        delete data.tags;
    }
    const res = await fetch(`${API_BASE_URL}/api/financial/category-mappings`, { method: 'POST', headers, body: JSON.stringify(data) });
    if (res.ok) {
        closeCategoryMappingModal();
        refreshCategoryMappings();
        return;
    }
    showFinancialNotice('Failed to save category mapping.', 'error');
});

document.getElementById('closePeriodForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.farm_id = FARM_ID;
    const res = await fetch(`${API_BASE_URL}/api/financial/periods/close`, { method: 'POST', headers, body: JSON.stringify(data) });
    if (res.ok) {
        closePeriodCloseModal();
        refreshPeriodList();
        showFinancialNotice('Financial period closed successfully.', 'success');
        return;
    }
    try {
        const err = await res.json();
        if (err && err.errors && err.errors.close) {
            const checklist = err && err.errors ? err.errors.checklist || {} : {};
            const parts = [];
            if (typeof checklist.pending_transactions === 'number' && checklist.pending_transactions > 0) {
                parts.push(`pending=${checklist.pending_transactions}`);
            }
            if (typeof checklist.uncategorized_transactions === 'number' && checklist.uncategorized_transactions > 0) {
                parts.push(`uncategorized=${checklist.uncategorized_transactions}`);
            }
            const suffix = parts.length ? ` (${parts.join(', ')})` : '';
            showFinancialNotice(`${err.errors.close}${suffix}`, 'error');
            return;
        }
    } catch (e) {}
    showFinancialNotice('Failed to close financial period.', 'error');
});

function renderTransactions(items) {
    const tbody = document.getElementById('transactionsList');
    if (!tbody) return;
    if (!items || items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">No transactions found.</td></tr>';
        return;
    }
    tbody.innerHTML = items.map(transaction => `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${transaction.date}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">${transaction.description}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${transaction.category}</td>
            <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${transaction.type === 'income' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'}">
                    ${transaction.type ? transaction.type.charAt(0).toUpperCase() + transaction.type.slice(1) : ''}
                </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium ${transaction.type === 'income' ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'}">
                $${Number(transaction.amount).toFixed(2)}
            </td>
        </tr>
    `).join('');
}

function renderBudgets(items) {
    const grid = document.getElementById('budgetsGrid');
    if (!grid) return;
    const cards = (items || []).map(budget => {
        const percent = (budget.limit > 0) ? (budget.spent / budget.limit) * 100 : 0;
        const color = percent > 90 ? 'bg-red-600' : (percent > 75 ? 'bg-yellow-500' : 'bg-green-500');
        return `
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-5 hover:shadow-md transition-shadow">
            <div class="flex justify-between items-center mb-2">
                <h3 class="text-lg font-medium text-gray-900 dark:text-white">${budget.category}</h3>
                <span class="text-sm text-gray-500 dark:text-gray-400">${budget.period ? budget.period.charAt(0).toUpperCase() + budget.period.slice(1) : ''}</span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2.5 mb-2">
                <div class="${color} h-2.5 rounded-full" style="width: ${Math.min(percent, 100)}%"></div>
            </div>
            <div class="flex justify-between text-sm">
                <span class="text-gray-600 dark:text-gray-400">$${Number(budget.spent || 0).toFixed(2)} spent</span>
                <span class="font-medium text-gray-900 dark:text-white">of $${Number(budget.limit || 0).toFixed(2)}</span>
            </div>
        </div>`;
    }).join('');
    const container = document.createElement('div');
    container.className = 'grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3';
    container.innerHTML = cards || '<div class="col-span-full text-center text-gray-500 dark:text-gray-400">No budgets found.</div>';
    const existingGrid = grid.querySelector('.grid');
    if (existingGrid) existingGrid.replaceWith(container);
    else grid.appendChild(container);
}

function renderInvoices(items) {
    const tbody = document.getElementById('invoicesList');
    if (!tbody) return;
    if (!items || items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">No invoices found.</td></tr>';
        return;
    }
    tbody.innerHTML = items.map(invoice => `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">${invoice.invoice_number}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${invoice.customer_name}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${invoice.due_date}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">$${Number(invoice.amount || 0).toFixed(2)}</td>
            <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${invoice.status === 'paid' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200'}">
                    ${invoice.status ? invoice.status.charAt(0).toUpperCase() + invoice.status.slice(1) : ''}
                </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <a href="#" class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300">Download</a>
            </td>
        </tr>
    `).join('');
}

function openCategoryMappingModal() { document.getElementById('categoryMappingModal').classList.remove('hidden'); }
function closeCategoryMappingModal() { document.getElementById('categoryMappingModal').classList.add('hidden'); }

function openPeriodCloseModal() { document.getElementById('periodCloseModal').classList.remove('hidden'); }
function closePeriodCloseModal() { document.getElementById('periodCloseModal').classList.add('hidden'); }

function openBudgetDrilldown(url, title) {
    document.getElementById('budgetDrilldownModal').classList.remove('hidden');
    const t = document.getElementById('budgetDrilldownTitle');
    if (t) t.textContent = title || 'Budget Drilldown';
    const tbody = document.getElementById('budgetDrilldownList');
    if (tbody) tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-8 text-sm text-gray-500 dark:text-gray-400 text-center">Loading...</td></tr>';
    fetch(`${API_BASE_URL}${url}`, { headers })
        .then(r => r.json())
        .then(payload => {
            const rows = payload && payload.data && payload.data.records ? payload.data.records : payload.records || [];
            if (!tbody) return;
            if (!Array.isArray(rows) || rows.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-8 text-sm text-gray-500 dark:text-gray-400 text-center">No records.</td></tr>';
                return;
            }
            tbody.innerHTML = rows.slice(0, 200).map(r => `
                <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-400">${r.date || ''}</td>
                    <td class="px-4 py-2 text-sm text-gray-900 dark:text-white">${r.vendor || ''}</td>
                    <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-400">${r.description || ''}</td>
                    <td class="px-4 py-2 text-sm text-right font-medium text-red-600 dark:text-red-400">$${Number(r.amount || 0).toFixed(2)}</td>
                </tr>
            `).join('');
        })
        .catch(() => {
            if (tbody) tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-8 text-sm text-red-600 dark:text-red-400 text-center">Failed to load.</td></tr>';
        });
}

function closeBudgetDrilldown() { document.getElementById('budgetDrilldownModal').classList.add('hidden'); }

function renderBudgetVariance(items) {
    const tbody = document.getElementById('budgetVarianceList');
    if (!tbody) return;
    if (!items || items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">No budget performance available.</td></tr>';
        return;
    }
    tbody.innerHTML = items.map((budget) => {
        const statusClass = budget.status === 'over_budget'
            ? 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'
            : 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
        const drill = '';
        return `
            <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">${budget.category}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">$${Number(budget.limit || 0).toFixed(2)}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">$${Number(budget.spent || 0).toFixed(2)}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium ${budget.variance < 0 ? 'text-red-600 dark:text-red-400' : 'text-emerald-600 dark:text-emerald-400'}">$${Number(budget.variance || 0).toFixed(2)}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm">
                    <span class="px-2 inline-flex rounded-full ${statusClass}">${budget.status === 'over_budget' ? 'Over budget' : 'On track'}</span>${drill}
                </td>
            </tr>
        `;
    }).join('');
}

function renderCategoryMappings(items) {
    const tbody = document.getElementById('categoryMappingsList');
    if (!tbody) return;
    if (!items || items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">No category mappings found.</td></tr>';
        return;
    }
    tbody.innerHTML = items.map((mapping) => `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">${mapping.keyword}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">${mapping.category}<div class="text-xs text-gray-500 dark:text-gray-400">${mapping.match_field || 'combined'} • ${mapping.match_type || 'contains'} • p${mapping.priority != null ? mapping.priority : 0}</div></td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${mapping.active ? 'Yes' : 'No'}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button type="button" onclick="deleteCategoryMapping(${mapping.id})" class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-200">Delete</button>
            </td>
        </tr>
    `).join('');
}

function renderPeriodList(items) {
    const container = document.getElementById('periodListContainer');
    if (!container) return;
    if (!items || items.length === 0) {
        container.textContent = 'No financial close history available yet.';
        return;
    }
    container.innerHTML = items.slice(0, 6).map((period) => `
        <div class="mb-2 rounded-lg border border-gray-200 dark:border-gray-700 px-4 py-3 bg-gray-50 dark:bg-gray-900">
            <div class="flex items-center justify-between gap-2">
                <span class="text-sm font-semibold text-gray-900 dark:text-white">${period.name}</span>
                <span class="text-xs uppercase tracking-wider text-gray-500 dark:text-gray-400">${period.status}</span>
            </div>
            <div class="mt-1 text-sm text-gray-600 dark:text-gray-400">${period.period_type.charAt(0).toUpperCase() + period.period_type.slice(1)}: ${period.start_date} to ${period.end_date}</div>
            <div class="mt-1 text-sm text-gray-600 dark:text-gray-400">Closed: ${period.closed_at != null ? period.closed_at : 'N/A'}</div>
            ${period.status === 'closed' ? `<div class="mt-2"><button type="button" class="text-sm font-medium text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300" onclick="reopenFinancialPeriod(${period.id})">Reopen</button></div>` : ''}
        </div>
    `).join('');
}

async function reopenFinancialPeriod(periodId) {
    const res = await fetch(`${API_BASE_URL}/api/financial/periods/reopen`, { method: 'POST', headers, body: JSON.stringify({ farm_id: FARM_ID, period_id: periodId }) });
    if (res.ok) {
        await refreshPeriodList();
        showFinancialNotice('Period reopened.', 'success');
        return;
    }
    showFinancialNotice('Failed to reopen period.', 'error');
}

function renderConnectors(items) {
    const el = document.getElementById('connectorsList');
    if (!el) return;
    if (!items || items.length === 0) {
        el.innerHTML = '<div class="text-sm text-gray-500 dark:text-gray-400">No connectors yet.</div>';
        return;
    }
    el.innerHTML = items.map(c => `
        <div class="flex items-center justify-between gap-2 py-2 border-b border-gray-100 dark:border-gray-700">
            <div>
                <div class="font-medium text-gray-900 dark:text-white">${c.name}</div>
                <div class="text-xs text-gray-500 dark:text-gray-400">format=${c.format} • last_used=${c.last_used_at != null ? c.last_used_at : 'never'}</div>
            </div>
            <button type="button" class="text-sm font-medium text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300" onclick="rotateConnectorToken(${c.id})">Rotate</button>
        </div>
    `).join('');
}

async function refreshBiConnectors() {
    try {
        const res = await fetch(`${API_BASE_URL}/api/bi/connectors`, { headers });
        if (!res.ok) {
            return;
        }
        const payload = await res.json();
        renderConnectors(payload.connectors || (payload.data && payload.data.connectors) || []);
    } catch (e) {}
}

const createConnectorForm = document.getElementById('createConnectorForm');
if (createConnectorForm) createConnectorForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    const payload = {
        name: data.name,
        format: data.format,
        scope: { resources: ['financial_records'] }
    };
    const res = await fetch(`${API_BASE_URL}/api/bi/connectors`, { method: 'POST', headers, body: JSON.stringify(payload) });
    if (!res.ok) {
        showFinancialNotice('Failed to create connector.', 'error');
        return;
    }
    const created = await res.json();
    const url = created && created.url ? `${API_BASE_URL}${created.url}&resource=financial_records&start_date=<?php echo date('Y-m-01'); ?>&end_date=<?php echo date('Y-m-d'); ?>` : '';
    if (url) {
        showFinancialNotice(`Connector created. Use: ${url}`, 'success');
    } else {
        showFinancialNotice('Connector created.', 'success');
    }
    e.target.reset();
    refreshBiConnectors();
});

async function rotateConnectorToken(id) {
    const res = await fetch(`${API_BASE_URL}/api/bi/connectors/${id}/rotate`, { method: 'POST', headers });
    if (!res.ok) {
        showFinancialNotice('Failed to rotate token.', 'error');
        return;
    }
    const data = await res.json();
    const url = data && data.url ? `${API_BASE_URL}${data.url}&resource=financial_records&start_date=<?php echo date('Y-m-01'); ?>&end_date=<?php echo date('Y-m-d'); ?>` : '';
    if (url) {
        showFinancialNotice(`New connector URL: ${url}`, 'success');
    } else {
        showFinancialNotice('Token rotated.', 'success');
    }
    refreshBiConnectors();
}

function renderReportBuckets(state, items) {
    const tbody = document.getElementById('reportBucketsList');
    if (!tbody) return;
    if (!items || items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-6 text-sm text-gray-500 dark:text-gray-400 text-center">No data.</td></tr>';
        return;
    }
    tbody.innerHTML = items.slice(0, 40).map(r => `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-4 py-2 text-sm text-gray-900 dark:text-white">${r.bucket || ''}</td>
            <td class="px-4 py-2 text-sm text-right text-gray-900 dark:text-white">$${Number(r.total || 0).toFixed(2)}</td>
            <td class="px-4 py-2 text-sm text-right text-gray-500 dark:text-gray-400">${r.count || 0}</td>
            <td class="px-4 py-2 text-sm">
                <button type="button" class="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 font-medium" onclick="openBudgetDrilldown('/api/bi/reports/drilldown?start_date=${encodeURIComponent(state.start_date)}&end_date=${encodeURIComponent(state.end_date)}&group_by=${encodeURIComponent(state.group_by)}&bucket=${encodeURIComponent(r.bucket || '')}&direction=${encodeURIComponent(state.direction)}', 'Report drilldown')">Drill</button>
            </td>
        </tr>
    `).join('');
}

const runReportForm = document.getElementById('runReportForm');
if (runReportForm) runReportForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    const payload = {
        report_type: 'financial',
        start_date: data.start_date,
        end_date: data.end_date,
        group_by: data.group_by,
        direction: data.direction
    };
    const tbody = document.getElementById('reportBucketsList');
    if (tbody) tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-6 text-sm text-gray-500 dark:text-gray-400 text-center">Loading...</td></tr>';
    const res = await fetch(`${API_BASE_URL}/api/bi/reports/run`, { method: 'POST', headers, body: JSON.stringify(payload) });
    if (!res.ok) {
        if (tbody) tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-6 text-sm text-gray-500 dark:text-gray-400 text-center">Failed to load.</td></tr>';
        return;
    }
    const out = await res.json();
    renderReportBuckets(payload, out.buckets || (out.data && out.data.buckets) || []);
});

function renderForecast(rows) {
    const tbody = document.getElementById('forecastList');
    if (!tbody) return;
    if (!rows || rows.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-6 text-sm text-gray-500 dark:text-gray-400 text-center">No forecast available.</td></tr>';
        return;
    }
    tbody.innerHTML = rows.slice(0, 12).map(r => `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-4 py-2 text-sm text-gray-900 dark:text-white">${r.period}</td>
            <td class="px-4 py-2 text-sm text-right text-gray-900 dark:text-white">$${Number(r.projected_revenue || 0).toFixed(2)}</td>
            <td class="px-4 py-2 text-sm text-right text-gray-900 dark:text-white">$${Number(r.projected_expenses || 0).toFixed(2)}</td>
            <td class="px-4 py-2 text-sm text-right font-medium ${Number(r.net_cash_flow || 0) < 0 ? 'text-red-600 dark:text-red-400' : 'text-emerald-600 dark:text-emerald-400'}">$${Number(r.net_cash_flow || 0).toFixed(2)}</td>
        </tr>
    `).join('');
}

async function refreshForecast() {
    try {
        const res = await fetch(`${API_BASE_URL}/api/financial-analytics/forecast?farm_id=${FARM_ID}&horizon_months=12`, { headers });
        if (!res.ok) {
            return;
        }
        const payload = await res.json();
        const scenarios = payload && payload.forecast_scenarios ? payload.forecast_scenarios : (payload && payload.data ? payload.data.forecast_scenarios || {} : {});
        renderForecast(scenarios.Baseline || scenarios.Realistic || []);
    } catch (e) {}
}

async function refreshBudgetVariance() {
    const tbody = document.getElementById('budgetVarianceList');
    if (!tbody) return;
    try {
        const response = await fetch(`${API_BASE_URL}/api/financial/budget-vs-actual?farm_id=${FARM_ID}&year=${new Date().getFullYear()}&month=${new Date().getMonth() + 1}`, { headers });
        if (!response.ok) {
            tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">Unable to load budget performance.</td></tr>';
            return;
        }
        const data = await response.json();
        renderBudgetVariance(data.budgets || []);
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">Unable to load budget performance.</td></tr>';
    }
}

async function refreshCategoryMappings() {
    const tbody = document.getElementById('categoryMappingsList');
    if (!tbody) return;
    try {
        const response = await fetch(`${API_BASE_URL}/api/financial/category-mappings?farm_id=${FARM_ID}`, { headers });
        if (!response.ok) {
            tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">Unable to load category mappings.</td></tr>';
            return;
        }
        const data = await response.json();
        renderCategoryMappings(data.mappings || []);
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">Unable to load category mappings.</td></tr>';
    }
}

async function refreshPeriodList() {
    const container = document.getElementById('periodListContainer');
    if (!container) return;
    try {
        const response = await fetch(`${API_BASE_URL}/api/financial/periods?farm_id=${FARM_ID}`, { headers });
        if (!response.ok) {
            container.textContent = 'Unable to load financial close history.';
            return;
        }
        const data = await response.json();
        renderPeriodList(data.periods || []);
    } catch (error) {
        container.textContent = 'Unable to load financial close history.';
    }
}

async function deleteCategoryMapping(id) {
    if (!confirm('Delete this category mapping rule?')) {
        return;
    }
    try {
        const response = await fetch(`${API_BASE_URL}/api/financial/category-mappings/${id}?farm_id=${FARM_ID}`, { method: 'DELETE', headers });
        if (response.ok) {
            refreshCategoryMappings();
            showFinancialNotice('Category mapping deleted', 'success');
            return;
        }
        showFinancialNotice('Failed to delete category mapping.', 'error');
    } catch (error) {
        showFinancialNotice('Failed to delete category mapping.', 'error');
    }
}

async function loadFinancialTools() {
    await Promise.all([
        refreshBudgetVariance(),
        refreshCategoryMappings(),
        refreshPeriodList(),
        refreshBiConnectors(),
        refreshForecast(),
    ]);
}

document.addEventListener('DOMContentLoaded', async () => {
    try {
        const res = await window.OfflineService.getCachedData('/financial/transactions', 'transactions');
        if (res && res.data) renderTransactions(res.data);
        if (navigator.onLine) {
            const resp = await fetch(`${API_BASE_URL}/api/financial/records`, { headers });
            if (resp.ok) {
                const data = await resp.json();
                const records = Array.isArray(data.records) ? data.records : [];
                renderTransactions(records);
                for (const it of records) {
                    await window.OfflineService.storeData('transactions', it);
                }
            }

            const budgetResp = await fetch(`${API_BASE_URL}/api/financial/budgets`, { headers });
            if (budgetResp.ok) {
                const budgetData = await budgetResp.json();
                const list = Array.isArray(budgetData) ? budgetData : (Array.isArray(budgetData.budgets) ? budgetData.budgets : []);
                renderBudgets(list);
            }

            const invoiceResp = await fetch(`${API_BASE_URL}/api/financial/invoices`, { headers });
            if (invoiceResp.ok) {
                const invoiceData = await invoiceResp.json();
                const list = Array.isArray(invoiceData) ? invoiceData : (Array.isArray(invoiceData.invoices) ? invoiceData.invoices : []);
                renderInvoices(list);
            }

            await loadFinancialTools();
            await refreshAdvancedAccountingMetrics();
        }
    } catch (e) {}
});

async function refreshAdvancedAccountingMetrics() {
    const endpoints = [
        { id: 'currencyCount', path: '/api/accounting/currencies' },
        { id: 'bankAccountCount', path: '/api/accounting/bank-accounts' },
        { id: 'fixedAssetCount', path: '/api/accounting/fixed-assets' },
        { id: 'taxCodeCount', path: '/api/accounting/tax-codes' },
        { id: 'journalApprovalCount', path: '/api/accounting/journal-approvals' },
    ];

    await Promise.all(endpoints.map(async (endpoint) => {
        const el = document.getElementById(endpoint.id);
        if (!el) return;

        try {
            const response = await fetch(`${API_BASE_URL}${endpoint.path}`, { headers });
            if (!response.ok) {
                el.textContent = '—';
                return;
            }
            const data = await response.json();
            const list = Array.isArray(data)
                ? data
                : Array.isArray(data.items)
                    ? data.items
                    : Array.isArray(data.data)
                        ? data.data
                        : [];
            el.textContent = String(list.length);
        } catch (error) {
            el.textContent = '—';
        }
    }));
}
</script>
