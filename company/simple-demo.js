const taskForm = document.getElementById("taskForm");
const taskInput = document.getElementById("taskInput");
const taskList = document.getElementById("taskList");
const taskCount = document.getElementById("taskCount");
const totalCount = document.getElementById("totalCount");
const activeCount = document.getElementById("activeCount");
const completedCount = document.getElementById("completedCount");
const clearDone = document.getElementById("clearDone");
const filterAll = document.getElementById("filterAll");
const filterActive = document.getElementById("filterActive");
const filterCompleted = document.getElementById("filterCompleted");
const themeToggle = document.getElementById("themeToggle");

let tasks = [];
let filter = "all";

function renderTasks() {
  const visibleTasks = tasks.filter((task) => {
    if (filter === "active") return !task.completed;
    if (filter === "completed") return task.completed;
    return true;
  });

  taskList.innerHTML = visibleTasks
    .map(
      (task) => `
      <li class="${task.completed ? "completed" : ""}">
        <label class="task-label">
          <input type="checkbox" data-id="${task.id}" ${task.completed ? "checked" : ""} />
          ${task.title}
        </label>
        <button class="btn btn-ghost" data-action="delete" data-id="${task.id}">Delete</button>
      </li>
    `,
    )
    .join("");

  taskCount.textContent = `${visibleTasks.length} ${visibleTasks.length === 1 ? "task" : "tasks"}`;
  totalCount.textContent = tasks.length;
  activeCount.textContent = tasks.filter((task) => !task.completed).length;
  completedCount.textContent = tasks.filter((task) => task.completed).length;
}

function addTask(title) {
  tasks.push({ id: Date.now(), title, completed: false });
  renderTasks();
}

function removeTask(id) {
  tasks = tasks.filter((task) => task.id !== id);
  renderTasks();
}

function toggleTask(id) {
  tasks = tasks.map((task) => (task.id === id ? { ...task, completed: !task.completed } : task));
  renderTasks();
}

function setFilter(newFilter) {
  filter = newFilter;
  document.querySelectorAll(".task-actions .btn").forEach((button) => {
    button.classList.toggle("active", button.id === `filter${newFilter.charAt(0).toUpperCase() + newFilter.slice(1)}`);
  });
  renderTasks();
}

function clearCompleted() {
  tasks = tasks.filter((task) => !task.completed);
  renderTasks();
}

function toggleTheme() {
  document.body.classList.toggle("dark");
  themeToggle.textContent = document.body.classList.contains("dark") ? "Light theme" : "Dark theme";
}

if (taskForm) {
  taskForm.addEventListener("submit", (event) => {
    event.preventDefault();
    const title = taskInput.value.trim();
    if (!title) return;
    addTask(title);
    taskInput.value = "";
    taskInput.focus();
  });
}

if (taskList) {
  taskList.addEventListener("click", (event) => {
    const target = event.target;
    if (target.matches("button[data-action='delete']")) {
      const id = Number(target.dataset.id);
      removeTask(id);
    }
    if (target.matches("input[type='checkbox']")) {
      const id = Number(target.dataset.id);
      toggleTask(id);
    }
  });
}

if (clearDone) {
  clearDone.addEventListener("click", clearCompleted);
}

if (filterAll) {
  filterAll.addEventListener("click", () => setFilter("all"));
}
if (filterActive) {
  filterActive.addEventListener("click", () => setFilter("active"));
}
if (filterCompleted) {
  filterCompleted.addEventListener("click", () => setFilter("completed"));
}

if (themeToggle) {
  themeToggle.addEventListener("click", toggleTheme);
}

setFilter("all");
renderTasks();

function escapeHtml(text) {
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function renderInline(text) {
  let safeText = escapeHtml(text);
  safeText = safeText.replace(/`([^`]+)`/g, "<code>$1</code>");
  safeText = safeText.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  safeText = safeText.replace(/__([^_]+)__/g, "<strong>$1</strong>");
  safeText = safeText.replace(/\*([^*]+)\*/g, "<em>$1</em>");
  safeText = safeText.replace(/_([^_]+)_/g, "<em>$1</em>");
  return safeText;
}

function parseTableRow(line) {
  return line
    .trim()
    .replace(/^\||\|$/g, "")
    .split("|")
    .map((cell) => cell.trim());
}

function flushList(html, listType, listItems) {
  if (!listType || listItems.length === 0) return;
  const tag = listType === "ol" ? "ol" : "ul";
  html.push(`<${tag}>${listItems.map((item) => `<li>${item}</li>`).join("")}</${tag}>`);
}

function flushTable(html, tableRows) {
  if (tableRows.length < 2) {
    tableRows.forEach((row) => html.push(`<p>${renderInline(row)}</p>`));
    return;
  }

  const headerLine = tableRows[0];
  const separatorLine = tableRows[1];
  if (!/^\s*\|?\s*:?[-]+:?(\s*\|\s*:?[-]+:?)+\s*\|?\s*$/.test(separatorLine)) {
    tableRows.forEach((row) => html.push(`<p>${renderInline(row)}</p>`));
    return;
  }

  const headers = parseTableRow(headerLine);
  const bodyRows = tableRows.slice(2).map(parseTableRow);
  html.push(
    `<table><thead><tr>${headers.map((cell) => `<th>${renderInline(cell)}</th>`).join("")}</tr></thead><tbody>${bodyRows
      .map((row) => `<tr>${row.map((cell) => `<td>${renderInline(cell)}</td>`).join("")}</tr>`)
      .join("")}</tbody></table>`,
  );
}

function parseMarkdown(text) {
  const lines = text.split(/\r?\n/);
  const html = [];
  let inCode = false;
  let codeLines = [];
  let listType = null;
  let listItems = [];
  let tableRows = [];

  const flushPending = () => {
    if (inCode) {
      html.push(`<pre><code>${escapeHtml(codeLines.join("\n"))}</code></pre>`);
      inCode = false;
      codeLines = [];
    }
    if (listType) {
      flushList(html, listType, listItems);
      listType = null;
      listItems = [];
    }
    if (tableRows.length > 0) {
      flushTable(html, tableRows);
      tableRows = [];
    }
  };

  lines.forEach((line) => {
    if (/^```/.test(line)) {
      if (inCode) {
        flushPending();
      } else {
        flushPending();
        inCode = true;
      }
      return;
    }

    if (inCode) {
      codeLines.push(line);
      return;
    }

    const trimmed = line.trim();
    if (trimmed === "") {
      flushPending();
      return;
    }

    const headingMatch = trimmed.match(/^(#{1,6})\s+(.*)$/);
    if (headingMatch) {
      flushPending();
      const level = headingMatch[1].length;
      html.push(`<h${level}>${renderInline(headingMatch[2])}</h${level}>`);
      return;
    }

    if (/^---+$/.test(trimmed)) {
      flushPending();
      html.push("<hr />");
      return;
    }

    const listMatch = trimmed.match(/^([-*+])\s+(.*)$/);
    if (listMatch) {
      const newType = "ul";
      if (tableRows.length > 0) {
        flushTable(html, tableRows);
        tableRows = [];
      }
      if (listType !== newType) {
        flushList(html, listType, listItems);
        listType = newType;
        listItems = [];
      }
      listItems.push(renderInline(listMatch[2]));
      return;
    }

    const orderedMatch = trimmed.match(/^(\d+)\.\s+(.*)$/);
    if (orderedMatch) {
      const newType = "ol";
      if (tableRows.length > 0) {
        flushTable(html, tableRows);
        tableRows = [];
      }
      if (listType !== newType) {
        flushList(html, listType, listItems);
        listType = newType;
        listItems = [];
      }
      listItems.push(renderInline(orderedMatch[2]));
      return;
    }

    if (trimmed.includes("|") && !/^[A-Za-z0-9].*`.*`/.test(trimmed)) {
      if (listType) {
        flushList(html, listType, listItems);
        listType = null;
        listItems = [];
      }
      tableRows.push(line);
      return;
    }

    if (tableRows.length > 0) {
      flushTable(html, tableRows);
      tableRows = [];
    }

    flushPending();
    html.push(`<p>${renderInline(trimmed)}</p>`);
  });

  flushPending();
  return html.join("");
}

async function loadMarkdownDocument() {
  const markdownPre = document.getElementById("markdownPre");
  if (!markdownPre) return;

  try {
    const response = await fetch("simple-front.md");
    if (!response.ok) throw new Error(`Unable to load document: ${response.status}`);
    const text = await response.text();
    markdownPre.innerHTML = parseMarkdown(text);
  } catch (error) {
    markdownPre.textContent = `Unable to load simple-front.md. Please ensure the file is available next to this page.`;
  }
}

loadMarkdownDocument();
