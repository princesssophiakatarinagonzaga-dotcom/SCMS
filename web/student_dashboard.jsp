<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="com.google.gson.Gson"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String jsEscape(Object val) {
    if (val == null) return "";
    return val.toString()
        .replace("\\", "\\\\")
        .replace("'",  "\\'")
        .replace("\"", "\\\"")
        .replace("\r", "")
        .replace("\n", "\\n")
        .replace("/",  "\\/");
}
%>

<%
Integer roleId = (Integer) session.getAttribute("role_id");
if (roleId == null || roleId != 1) {
    response.sendRedirect("login.jsp");
    return;
}

String fullName = (String) session.getAttribute("fullName");
String program  = (String) session.getAttribute("program");

Object totalObj = request.getAttribute("total");
Integer total   = (totalObj instanceof Number) ? ((Number) totalObj).intValue() : 0;
Integer open    = (request.getAttribute("open")    != null) ? (Integer) request.getAttribute("open")    : 0;
Integer pending = (request.getAttribute("pending") != null) ? (Integer) request.getAttribute("pending") : 0;
Integer review  = (request.getAttribute("review")  != null) ? (Integer) request.getAttribute("review")  : 0;
Integer closed  = (request.getAttribute("closed")  != null) ? (Integer) request.getAttribute("closed")  : 0;

List<Map<String, Object>> complaints =
    (List<Map<String, Object>>) request.getAttribute("complaints");
if (complaints == null) complaints = new java.util.ArrayList<>();

String firstName = (fullName != null && fullName.contains(","))
    ? fullName.split(",")[1].trim().split(" ")[0]
    : (fullName != null ? fullName.split(" ")[0] : "Student");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>TIP-SC | Student Dashboard</title>
<jsp:include page="auth_header.jspf" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
#donutChart { width: 160px !important; height: 160px !important; }
#barChart   { width: 100%  !important; height: 160px !important; }
</style>
</head>

<body class="dash-body">

<!-- ═══════════ NAVBAR ═══════════ -->
<nav class="navbar">
  <div class="nav-logo">
    <div class="nav-logo-dot"></div>
    <span class="nav-logo-name">TIP-SC</span>
  </div>

  <div class="nav-center">
    <button id="btn-view"   class="nav-btn dark"    onclick="showPage('dashboard')">View Concerns</button>
    <button id="btn-submit" class="nav-btn outline" onclick="showPage('submit')">Submit Concern</button>
  </div>

  <div class="nav-user" onclick="toggleUserDropdown()">
    <div class="nav-avatar"><i class="fa-solid fa-user"></i></div>
    <span class="nav-uname"><%= fullName %></span>
  </div>
</nav>

<!-- User Dropdown -->
<div class="user-dropdown" id="user-dropdown">
  <div class="ud-header">
    <div class="ud-name"><%= fullName %></div>
    <div class="ud-prog"><%= program %></div>
  </div>
  <div class="ud-items">
    <button class="ud-item" onclick="openSettings()">
      <i class="fa-solid fa-gear"></i> Settings
    </button>
    <div class="ud-sep"></div>
    <button class="ud-item" onclick="signOut()" style="color:#C62828;">
      <i class="fa-solid fa-right-from-bracket"></i> Sign Out
    </button>
  </div>
</div>

<!-- ═══════════ PAGE WRAP ═══════════ -->
<div class="page-wrap" id="page-wrap">

<!-- ══════════════ DASHBOARD PAGE ══════════════ -->
<div class="page active" id="page-dashboard">

  <!-- STATS CARD -->
  <div class="stats-card">
    <div class="stats-top">
      <div>
        <div class="greeting-name">Good day, <%= firstName %>!</div>
        <div class="greeting-prog"><%= program %></div>
      </div>
      <div class="stats-nums">
        <div class="stat-item"><div class="stat-lbl">TOTAL</div>    <div class="stat-val"><%= total   %></div></div>
        <div class="stat-item"><div class="stat-lbl">OPEN</div>     <div class="stat-val"><%= open    %></div></div>
        <div class="stat-item"><div class="stat-lbl">PENDING</div>  <div class="stat-val"><%= pending %></div></div>
        <div class="stat-item"><div class="stat-lbl">IN REVIEW</div><div class="stat-val"><%= review  %></div></div>
        <div class="stat-item"><div class="stat-lbl">CLOSED</div>   <div class="stat-val"><%= closed  %></div></div>
      </div>
    </div>

    <div class="chart-toggle" id="chart-toggle" onclick="toggleChart()" title="Show charts">
      <i class="fa-solid fa-bars-staggered"></i>
    </div>

    <div class="chart-panel" id="chart-panel">
      <div class="viewed-by">
        <div class="vb-lbl">Viewed by:</div>
        <button class="vb-btn on" onclick="switchView('status',this)">Status</button>
        <button class="vb-btn"   onclick="switchView('priority',this)">Priority</button>
        <button class="vb-btn"   onclick="switchView('category',this)">Category</button>
        <button class="vb-btn"   onclick="switchView('department',this)">Department</button>
      </div>
      <div class="charts-area">
        <div class="chart-donut-wrap"><canvas id="donutChart" width="160" height="160"></canvas></div>
        <div class="chart-bar-wrap">  <canvas id="barChart"   width="300" height="160"></canvas></div>
      </div>
    </div>
  </div>

  <!-- TABLE CARD -->
  <div class="table-card">
    <div class="search-wrap">
      <div class="search-box">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" id="search-input"
               placeholder="Search by title or reference number..."
               oninput="filterTable()"/>
      </div>
    </div>

    <div class="filters-row">
      <span class="filter-lbl">Filters:</span>
      <button class="filter-btn on"  onclick="applyFilter('all',this)">All</button>
      <button class="filter-btn"     onclick="applyFilter('Pending',this)">Pending</button>
      <button class="filter-btn"     onclick="applyFilter('Open',this)">Open</button>
      <button class="filter-btn"     onclick="applyFilter('In Review',this)">In Review</button>
      <button class="filter-btn"     onclick="applyFilter('Closed',this)">Closed</button>
      <button class="filter-btn"     onclick="applyFilter('Transferred',this)">Transferred</button>
    </div>

    <table class="concern-table">
      <thead>
        <tr>
          <th>Reference No. <span class="si">↕</span></th>
          <th>Title <span class="si">↕</span></th>
          <th>Category <span class="si">↕</span></th>
          <th>Type <span class="si">↕</span></th>
          <th>Department <span class="si">↕</span></th>
          <th>Priority <span class="si">↕</span></th>
          <th>Submitted <span class="si">↕</span></th>
          <th>Last Update <span class="si">↕</span></th>
          <th>Status <span class="si">↕</span></th>
          <th>View</th>
        </tr>
      </thead>
      <tbody id="table-body">
      <%
      if (!complaints.isEmpty()) {
          for (Map<String, Object> c : complaints) {
              String status        = String.valueOf(c.get("STATUS"));
              String priority      = String.valueOf(c.get("PRIORITY"));
              String statusBadge   = "badge-" + status.toLowerCase().replace(" ","");
              String priorityBadge = "badge-" + priority.toLowerCase();
      %>
        <tr data-status="<%= status %>">
          <td><%= c.get("ID") %></td>
          <td><%= c.get("TITLE") %></td>
          <td><%= c.get("CATEGORY") %></td>
          <td><%= c.get("TYPE") %></td>
          <td><%= c.get("DEPARTMENT") %></td>
          <td><span class="badge <%= priorityBadge %>"><%= priority %></span></td>
          <td><%= c.get("SUBMITTED_AT") %></td>
          <td><%= c.get("UPDATED_AT") %></td>
          <td><span class="badge <%= statusBadge %>"><%= status %></span></td>
          <td>
            <button class="dots-btn"
              onclick="openMsg(
                '<%= jsEscape(c.get("ID")) %>',
                '<%= jsEscape(c.get("TITLE")) %>',
                '<%= jsEscape(c.get("CATEGORY")) %>',
                '<%= jsEscape(c.get("TYPE")) %>',
                '<%= jsEscape(c.get("DEPARTMENT")) %>',
                '<%= jsEscape(status) %>',
                '<%= jsEscape(priority) %>',
                '<%= jsEscape(c.get("SUBMITTED_AT")) %>'
              )">
              ···
            </button>
          </td>
        </tr>
      <%
          }
      } else {
      %>
        <tr>
          <td colspan="10" style="text-align:center;padding:24px;color:rgba(255,255,255,.3);font-size:.78rem;">
            No concerns submitted yet.
          </td>
        </tr>
      <%
      }
      %>
      </tbody>
    </table>
  </div>
</div><!-- /page-dashboard -->


<!-- ══════════════ SUBMIT CONCERN PAGE ══════════════ -->
<div class="page" id="page-submit">
  <div class="submit-header">
    <div class="submit-title">Submit a Concern</div>
    <div class="submit-sub">Fill in the form below. You will receive updates via your student email.</div>
  </div>

  <div class="submit-layout">
    <div class="form-card">
      <form action="SubmitConcernServlet" method="post" id="concern-form">

        <div class="form-row">
          <div>
            <label class="fl" for="sel-category">MAIN CATEGORY <span class="req">*</span></label>
            <select name="category" id="sel-category" class="fi fi-sel" required onchange="updateDept()">
              <option value="">-- Select Category --</option>
              <option value="Academic">Academic</option>
              <option value="Financial">Financial</option>
              <option value="Student Life">Student Life</option>
              <option value="Administrative">Administrative</option>
              <option value="Others">Others</option>
            </select>
          </div>
          <div>
            <label class="fl" for="sel-type">TYPE OF CONCERN <span class="req">*</span></label>
            <select name="type" id="sel-type" class="fi fi-sel" required onchange="updateDept()">
              <option value="">-- Select Type --</option>
            </select>
          </div>
        </div>

        <div style="margin-bottom:14px;">
          <label class="fl" for="dept-field">
            DEPARTMENT HANDLING THIS CONCERN
            <span class="auto-tag">AUTO-FILLED</span>
          </label>
          <input type="text" name="department" id="dept-field" class="fi fi-auto"
                 readonly placeholder="Determined by category and type selected above"/>
        </div>

        <div style="margin-bottom:14px;">
          <label class="fl" for="title-input">SUBJECT / TITLE <span class="req">*</span></label>
          <input type="text" name="title" id="title-input" class="fi"
                 maxlength="120" placeholder="Brief description of your concern (max 120 characters)" required/>
        </div>

        <div style="margin-bottom:14px;">
          <label class="fl">PRIORITY <span class="req">*</span></label>
          <div class="priority-btns">
            <button type="button" class="pri-btn on"  onclick="setPriority('Low',this)">Low</button>
            <button type="button" class="pri-btn"     onclick="setPriority('Medium',this)">Medium</button>
            <button type="button" class="pri-btn"     onclick="setPriority('High',this)">High</button>
            <button type="button" class="pri-btn"     onclick="setPriority('Critical',this)">Urgent</button>
          </div>
          <input type="hidden" name="priority" id="priority-val" value="Low"/>
        </div>

        <div style="margin-bottom:14px;">
          <label class="fl" for="details">CONCERN DETAILS <span class="req">*</span></label>
          <textarea name="details" id="details" class="fi" style="min-height:110px;"
            placeholder="Describe your concern in detail. Include relevant dates, names, and any supporting information..."
            required></textarea>
        </div>

        <div style="margin-bottom:14px;">
          <label class="fl">PREFERRED RESOLUTION</label>
          <textarea name="resolution" id="resolution" class="fi" style="min-height:72px;"
            placeholder="Describe what outcome you are hoping for..."></textarea>
        </div>

        <div style="margin-bottom:14px;">
          <label class="fl" for="file-input">
            SUPPORTING ATTACHMENTS
            <span style="font-weight:400;text-transform:none;letter-spacing:0;">optional</span>
          </label>
          <div class="file-drop" onclick="document.getElementById('file-input').click()">
            <div class="file-drop-main">
              <i class="fa-solid fa-cloud-arrow-up" style="margin-right:6px;"></i>
              Drop files here or click to upload
            </div>
            <div class="file-drop-sub">PDF, JPG, PNG · Max 10MB each</div>
          </div>
          <input type="file" id="file-input" name="attachments"
                 multiple accept=".pdf,.jpg,.jpeg,.png" style="display:none;"/>
        </div>

        <div class="submit-btn-row">
          <button type="submit" class="submit-concern-btn">
            Submit Concern <i class="fa-solid fa-circle-arrow-right"></i>
          </button>
        </div>

      </form>
    </div>

    <!-- Sidebar -->
    <div class="sidebar-boxes">
      <div class="info-box">
        <div class="info-box-title">Submission Guidelines</div>
        <ul>
          <li>Be specific and factual</li>
          <li>Avoid offensive language</li>
          <li>One concern per submission</li>
          <li>Review the policy before submitting</li>
          <li>Attach supporting documents if available</li>
        </ul>
      </div>
      <div class="info-box">
        <div class="info-box-title">How department is assigned:</div>
        <p>Select a main category, then a type of concern. The responsible department will be identified automatically based on your selections.</p>
      </div>
      <div class="info-box">
        <div class="info-box-title">Concern tagged as "Others"?</div>
        <p>It will be routed to OSA – Manila or OSA – QC by default, who may transfer it to the appropriate department.</p>
      </div>
    </div>
  </div>
</div><!-- /page-submit -->

</div><!-- /page-wrap -->


<!-- ═══════════════════════════
     MESSAGING MODAL
═══════════════════════════ -->
<div class="overlay" id="overlay-msg">
  <div class="msg-modal">
    <div class="msg-header">
      <div class="msg-header-inner">
        <span class="msg-title">UPDATES AND STAFF FEEDBACK</span>
        <span class="msg-subtitle" id="msg-ref-label">Reference No. —</span>
      </div>
      <button class="msg-close" onclick="closeModal('overlay-msg')">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>

    <div class="msg-body">
      <div class="msg-left">
        <div class="msg-thread" id="msg-thread">
          <div style="text-align:center;padding:32px 0;font-size:.78rem;color:rgba(255,255,255,.25);">
            Loading conversation...
          </div>
        </div>
        <div class="msg-reply-area">
          <textarea class="msg-input" id="msg-reply-input"
            placeholder="Write a follow-up message or provide additional information..."></textarea>
          <div class="msg-footer">
            <span class="msg-footer-note">
              <i class="fa-regular fa-envelope"></i>
              You'll receive an email when staff responds
            </span>
            <button class="send-btn" onclick="sendReply()">Send Reply</button>
          </div>
        </div>
      </div>

      <div class="msg-right">
        <div class="msg-right-title">Reference</div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Ref No.</span>      <span class="msg-detail-val" id="md-ref">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Category</span>    <span class="msg-detail-val" id="md-cat">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Type</span>         <span class="msg-detail-val" id="md-type">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Assigned to</span> <span class="msg-detail-val" id="md-assigned">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Status</span>       <span class="msg-detail-val" id="md-status">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Department</span>  <span class="msg-detail-val" id="md-dept">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Submitted</span>   <span class="msg-detail-val" id="md-submitted">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Priority</span>    <span class="msg-detail-val" id="md-priority">—</span></div>
      </div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════
     SUBMIT CONFIRMATION MODAL
═══════════════════════════ -->
<div class="overlay" id="overlay-confirm">
  <div class="sub-modal">
    <div class="sub-modal-close-row">
      <button class="sub-modal-close" onclick="closeModal('overlay-confirm')">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>
    <div class="sub-modal-icon"><i class="fa-solid fa-check"></i></div>
    <div class="sub-modal-title">Concern submitted successfully!</div>
    <div class="sub-modal-sub">
      Your concern has been received and is currently under review.
      You will be notified via your student email once a response is available.
    </div>
    <div class="sub-detail-card" id="confirm-details">
      <div class="sub-dr"><span class="sub-dl">Reference No.</span><span class="sub-dv" id="conf-ref">—</span></div>
      <div class="sub-dr"><span class="sub-dl">Category</span>     <span class="sub-dv" id="conf-cat">—</span></div>
      <div class="sub-dr"><span class="sub-dl">Type</span>          <span class="sub-dv" id="conf-type">—</span></div>
      <div class="sub-dr"><span class="sub-dl">Assigned to</span>  <span class="sub-dv" id="conf-dept">—</span></div>
      <div class="sub-dr"><span class="sub-dl">Status</span>        <span class="sub-dv">Pending</span></div>
    </div>
    <div class="sub-modal-note">
      A confirmation has been sent to your TIP student email.<br>
      Keep your reference number for follow-ups.
    </div>
    <button class="sub-modal-btn"
            onclick="closeModal('overlay-confirm');showPage('dashboard');">
      View My Concerns
    </button>
  </div>
</div>

<!-- ═══════════════════════════
     SETTINGS MODAL
═══════════════════════════ -->
<div class="overlay" id="overlay-settings">
  <div class="settings-modal">
    <div class="settings-header">
      <span class="settings-title">Account Settings</span>
      <button class="settings-close" onclick="closeModal('overlay-settings')">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>
    <div class="settings-body">
      <div class="settings-section">
        <div class="settings-sec-title">Account Info</div>
        <div class="info-grid">
          <div class="info-field">
            <label>Full Name</label>
            <div class="info-val"><%= fullName %></div>
          </div>
          <div class="info-field">
            <label>Program</label>
            <div class="info-val"><%= program %></div>
          </div>
        </div>
      </div>
      <div class="settings-section">
        <div class="settings-sec-title">Change Password</div>
        <div class="fl-form">
          <div class="fl-field">
            <label for="current-password">Current Password <span>*</span></label>
            <div class="fl-iw">
              <i class="fa-solid fa-lock"></i>
              <input type="password" id="current-password" placeholder="Enter current password"/>
            </div>
          </div>
          <div class="fl-field">
            <label for="new-password">New Password <span>*</span></label>
            <div class="fl-iw">
              <i class="fa-solid fa-lock"></i>
              <input type="password" id="new-password" placeholder="Enter new password"/>
            </div>
          </div>
        </div>
        <button class="btn-yellow-full" style="margin-top:8px;">Save Changes</button>
      </div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════
     CHART DATA + ALL JS
═══════════════════════════ -->
<script>
const rawComplaints = <%= new Gson().toJson(complaints) %>;

const COLORS = {
    status:     ['#E040FB','#FFA533','#6EAAEE','#FFFFFF','#888888'],
    priority:   ['#FF6B6B','#FFA533','#6EAAEE','#33CC66'],
    category:   ['#e4bf05','#6EAAEE','#FF6B6B','#33CC66','#cc88ff'],
    department: ['#e4bf05','#6EAAEE','#FF6B6B','#33CC66','#cc88ff','#FFA533'],
};

function countBy(key) {
    const map = {};
    rawComplaints.forEach(c => { map[c[key]] = (map[c[key]] || 0) + 1; });
    return map;
}

let donutChart, barChart;

function renderCharts(view) {
    const map    = countBy(view);
    const labels = Object.keys(map);
    const data   = Object.values(map);
    const cols   = COLORS[view] || COLORS.status;

    const donutCtx = document.getElementById('donutChart').getContext('2d');
    const barCtx   = document.getElementById('barChart').getContext('2d');

    if (donutChart) donutChart.destroy();
    if (barChart)   barChart.destroy();

    donutChart = new Chart(donutCtx, {
        type: 'doughnut',
        data: { labels, datasets: [{ data, backgroundColor: cols, borderWidth: 0 }] },
        options: {
            responsive: false,
            plugins: {
                legend: { display: false },
                tooltip: { callbacks: { label: ctx => ` ${ctx.label}: ${ctx.raw}` } }
            },
            cutout: '62%'
        }
    });

    barChart = new Chart(barCtx, {
        type: 'bar',
        data: {
            labels,
            datasets: [{
                data,
                backgroundColor: cols,
                borderRadius: 5,
                borderSkipped: false
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: true,
                    position: 'top',
                    labels: {
                        color: 'rgba(255,255,255,.65)',
                        font: { size: 10 },
                        generateLabels: chart => labels.map((lbl, i) => ({
                            text: `${lbl} — ${data[i]}`,
                            fillStyle: cols[i],
                            strokeStyle: 'transparent',
                            index: i
                        }))
                    }
                }
            },
            scales: {
                x: { ticks: { color: 'rgba(255,255,255,.45)', font: { size: 10 } }, grid: { color: 'rgba(255,255,255,.06)' } },
                y: { ticks: { color: 'rgba(255,255,255,.45)', font: { size: 10 }, stepSize: 1 }, grid: { color: 'rgba(255,255,255,.06)' } }
            }
        }
    });
}

// ── Chart toggle ──
let chartOpen = false;
function toggleChart() {
    chartOpen = !chartOpen;
    document.getElementById('chart-panel').classList.toggle('open', chartOpen);
    if (chartOpen) renderCharts('status');
}

function switchView(view, btn) {
    document.querySelectorAll('.vb-btn').forEach(b => b.classList.remove('on'));
    btn.classList.add('on');
    renderCharts(view);
}

// ── Navbar page switch ──
function showPage(p) {
    document.querySelectorAll('.page').forEach(x => x.classList.remove('active'));
    document.getElementById('page-' + p).classList.add('active');
    document.getElementById('btn-view').className   = p === 'dashboard' ? 'nav-btn dark'    : 'nav-btn outline';
    document.getElementById('btn-submit').className = p === 'submit'    ? 'nav-btn dark'    : 'nav-btn outline';
}

// ── User dropdown ──
function toggleUserDropdown() {
    document.getElementById('user-dropdown').classList.toggle('show');
}
document.addEventListener('click', e => {
    if (!e.target.closest('.nav-user') && !e.target.closest('#user-dropdown'))
        document.getElementById('user-dropdown').classList.remove('show');
});

// ── Modals ──
function closeModal(id) {
    document.getElementById(id).classList.remove('show');
    document.getElementById('page-wrap').classList.remove('blurred');
}
function openModal(id) {
    document.getElementById(id).classList.add('show');
    document.getElementById('page-wrap').classList.add('blurred');
}

// ── Escape HTML to prevent XSS in messages ──
function escHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g,'&amp;')
        .replace(/</g,'&lt;')
        .replace(/>/g,'&gt;')
        .replace(/"/g,'&quot;')
        .replace(/'/g,'&#039;');
}

// ── Open messaging modal ──
function openMsg(ref, title, cat, type, dept, status, priority, submitted) {
    document.getElementById('msg-ref-label').textContent  = 'Reference No. ' + ref;
    document.getElementById('md-ref').textContent         = ref;
    document.getElementById('md-cat').textContent         = cat;
    document.getElementById('md-type').textContent        = type;
    document.getElementById('md-dept').textContent        = dept;
    document.getElementById('md-status').textContent      = status;
    document.getElementById('md-priority').textContent    = priority;
    document.getElementById('md-submitted').textContent   = submitted;
    document.getElementById('md-assigned').textContent    = '—';

    document.getElementById('msg-thread').innerHTML =
        '<div style="text-align:center;padding:32px 0;font-size:.78rem;color:rgba(255,255,255,.25);">Loading conversation...</div>';

    fetch('GetMessagesServlet?ref=' + encodeURIComponent(ref))
        .then(r => r.json())
        .then(msgs => renderThread(msgs, ref))
        .catch(() => {
            document.getElementById('msg-thread').innerHTML =
                '<div style="text-align:center;padding:24px;font-size:.78rem;color:rgba(255,255,255,.3);">No messages yet.</div>';
        });

    openModal('overlay-msg');
}

// ── Render message thread ──
// FIXED: was using m.senderName for all three fields (time and text were wrong)
function renderThread(msgs, ref) {
    const thread = document.getElementById('msg-thread');

    if (!msgs || msgs.length === 0) {
        thread.innerHTML =
            '<div style="text-align:center;padding:24px;font-size:.78rem;color:rgba(255,255,255,.3);">No messages yet.</div>';
        return;
    }

    thread.innerHTML = msgs.map(m => {
        const role    = (m.role || 'student').toLowerCase();
        const isStaff = role === 'staff' || role === 'manager' || role === 'admin';

        // Use the correct fields from the server response:
        // m.senderName  → display name
        // m.sentAt      → timestamp string
        // m.messageText → actual message body
        const name    = escHtml(m.senderName  || 'Unknown');
        const time    = escHtml(m.sentAt       || '');
        const body    = escHtml(m.messageText  || '');

        return `
          <div class="msg-bubble">
            <div class="msg-sender">
              <div class="msg-av ${isStaff ? 'staff' : 'student'}">
                <i class="fa-solid fa-user"></i>
              </div>
              <div>
                <div class="msg-sender-name">${name}${isStaff ? ' — Staff' : ''}</div>
                <div class="msg-sender-time">${time}</div>
              </div>
            </div>
            <div class="msg-text ${isStaff ? 'from-staff' : ''}">${body}</div>
          </div>`;
    }).join('');

    thread.scrollTop = thread.scrollHeight;
}

// ── Send reply ──
function sendReply() {
    const input = document.getElementById('msg-reply-input');
    const ref   = document.getElementById('md-ref').textContent;
    const msg   = input.value.trim();
    if (!msg) return;

    fetch('SendMessageServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'ref=' + encodeURIComponent(ref) + '&message=' + encodeURIComponent(msg)
    })
    .then(r => r.json())
    .then(msgs => { input.value = ''; renderThread(msgs, ref); })
    .catch(() => alert('Failed to send. Please try again.'));
}

// ── Table filter + search ──
let activeFilter = 'all';

function applyFilter(status, btn) {
    activeFilter = status;
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('on'));
    btn.classList.add('on');
    filterTable();
}

function filterTable() {
    const q    = document.getElementById('search-input').value.toLowerCase();
    const rows = document.querySelectorAll('#table-body tr');
    rows.forEach(r => {
        const matchSearch = r.innerText.toLowerCase().includes(q);
        const rowStatus   = (r.dataset.status || '').toLowerCase();
        const matchFilter = activeFilter === 'all' || rowStatus === activeFilter.toLowerCase();
        r.style.display   = (matchSearch && matchFilter) ? '' : 'none';
    });
}

// ── Priority selector ──
function setPriority(val, btn) {
    document.querySelectorAll('.pri-btn').forEach(b => b.classList.remove('on'));
    btn.classList.add('on');
    document.getElementById('priority-val').value = val;
}

// ── Category → Type → Dept auto-fill ──
const TYPE_MAP = {
    Academic: {
        types: ['Grade Correction Request','Grade Consultation','Academic Records Request','Subject Enrollment Issue','Grade Re-computation','Others'],
        deptMap: { default: 'Registrar Office' }
    },
    Financial: {
        types: ['Scholarship Concern','Tuition Concern','Payment Issue','Others'],
        deptMap: { default: 'Finance Office' }
    },
    'Student Life': {
        types: ['Complaint','Disciplinary Concern','Student Organization','Facilities','Others'],
        deptMap: { 'Facilities': 'Facilities Office', default: 'OSA Office' }
    },
    Administrative: {
        types: ['Request','ID Concern','Document Request','Others'],
        deptMap: { default: 'OSA Office' }
    },
    Others: {
        types: ['Others'],
        deptMap: { default: 'OSA – Manila / Quezon City' }
    }
};

function updateDept() {
    const cat     = document.getElementById('sel-category').value;
    const type    = document.getElementById('sel-type').value;
    const selType = document.getElementById('sel-type');

    if (TYPE_MAP[cat]) {
        selType.innerHTML = '<option value="">-- Select Type --</option>' +
            TYPE_MAP[cat].types.map(t => `<option value="${t}">${t}</option>`).join('');
    }

    const deptField = document.getElementById('dept-field');
    if (cat && TYPE_MAP[cat]) {
        const dm = TYPE_MAP[cat].deptMap;
        deptField.value = dm[type] || dm['default'] || '';
    } else {
        deptField.value = '';
    }
}

// ── Settings ──
function openSettings() {
    document.getElementById('user-dropdown').classList.remove('show');
    openModal('overlay-settings');
}

// ── Sign out ──
function signOut() {
    window.location.href = 'login.jsp?signout=true';
}
</script>
</body>
</html>