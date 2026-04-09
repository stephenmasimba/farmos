<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
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
                <input type="text" name="category" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Description</label>
                <input type="text" name="description" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
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

document.getElementById('addTransactionForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
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
        if (err?.errors?.lines) msg = err.errors.lines;
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
        }
    } catch (e) {}
});
</script>
