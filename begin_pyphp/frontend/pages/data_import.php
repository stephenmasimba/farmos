<?php
require_once __DIR__ . '/../lib/i18n.php';
$page_title = __('data_import_title');
$active_page = 'data_import';
?>
<?php include __DIR__ . '/../components/header.php'; ?>
<div class="container">
  <h1><?php echo __('data_import_title'); ?></h1>
  <p><?php echo __('data_import_desc'); ?></p>
  <script src="https://cdn.sheetjs.com/xlsx-latest/package/dist/xlsx.full.min.js"></script>

  <div style="margin: 12px 0;">
    <label for="import-type"><?php echo __('data_import_type'); ?></label>
    <select id="import-type">
      <option value="livestock"><?php echo __('livestock_batches'); ?></option>
      <option value="inventory"><?php echo __('inventory_items'); ?></option>
    </select>
    <button id="download-template"><?php echo __('download_template'); ?></button>
  </div>

  <form id="import-form">
    <label><?php echo __('upload_csv'); ?></label>
    <input id="file-upload" type="file" accept=".csv" />
    <button type="submit"><?php echo __('import_data'); ?></button>
  </form>

  <div id="result" style="margin-top:16px;"></div>
</div>
<script>
  const apiBase = '/api/import';
  const typeEl = document.getElementById('import-type');
  const tmplBtn = document.getElementById('download-template');
  const formEl = document.getElementById('import-form');
  const fileEl = document.getElementById('file-upload');
  const resultEl = document.getElementById('result');

  tmplBtn.addEventListener('click', async () => {
    const type = typeEl.value;
    const res = await fetch(`${apiBase}/${type}/template`, {
      headers: { 'x-api-key': 'begin-api-key', 'Authorization': 'Bearer ' + localStorage.getItem('token') }
    });
    const text = await res.text();
    const blob = new Blob([text], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${type}_template.csv`;
    document.body.appendChild(a);
    a.click();
    a.remove();
  });

  formEl.addEventListener('submit', async (e) => {
    e.preventDefault();
    const file = fileEl.files[0];
    if (!file) {
      alert('Please select a CSV file');
      return;
    }
    const type = typeEl.value;
    resultEl.textContent = 'Uploading...';
    const ext = (file.name.split('.').pop() || '').toLowerCase();
    try {
      if (ext === 'xlsx' || ext === 'xls') {
        const buf = await file.arrayBuffer();
        const wb = XLSX.read(buf, { type: 'array' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const rows = XLSX.utils.sheet_to_json(ws);
        const res = await fetch(`${apiBase}/${type}`, {
          method: 'POST',
          headers: { 
            'x-api-key': 'begin-api-key', 
            'Authorization': 'Bearer ' + localStorage.getItem('token'),
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ rows })
        });
        const data = await res.json();
        const r = data.data || {};
        resultEl.innerHTML = `
          <div>
            <div><?php echo __('import_success'); ?>: ${r.success || 0}</div>
            <div><?php echo __('import_failed'); ?>: ${r.failed || 0}</div>
            ${Array.isArray(r.errors) && r.errors.length ? `<ul>${r.errors.map(e => `<li>${e}</li>`).join('')}</ul>` : ''}
          </div>
        `;
      } else {
        const fd = new FormData();
        fd.append('file', file);
        const res = await fetch(`${apiBase}/${type}`, {
          method: 'POST',
          headers: { 'x-api-key': 'begin-api-key', 'Authorization': 'Bearer ' + localStorage.getItem('token') },
          body: fd
        });
        const data = await res.json();
        const r = data.data || {};
        resultEl.innerHTML = `
          <div>
            <div><?php echo __('import_success'); ?>: ${r.success || 0}</div>
            <div><?php echo __('import_failed'); ?>: ${r.failed || 0}</div>
            ${Array.isArray(r.errors) && r.errors.length ? `<ul>${r.errors.map(e => `<li>${e}</li>`).join('')}</ul>` : ''}
          </div>
        `;
      }
    } catch (err) {
      console.error(err);
      resultEl.textContent = 'Import failed';
    }
  });
</script>
<?php include __DIR__ . '/../components/footer.php'; ?>
