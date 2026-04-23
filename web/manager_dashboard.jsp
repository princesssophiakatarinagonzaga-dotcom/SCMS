<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%!
// Escape a value for safe embedding inside a JavaScript single-quoted string
private String jsEscape(Object val) {
    if (val == null) return "";
    return val.toString()
        .replace("\\", "\\\\")   // backslash first
        .replace("'",  "\\'")    // single quote
        .replace("\"", "\\\"")   // double quote
        .replace("\r", "")
        .replace("\n", "\\n")
        .replace("/",  "\\/");   // forward slash (closes </script> tags)
}
%>

<%
Integer roleId = (Integer) session.getAttribute("role_id");
if (roleId == null || roleId != 2) {
    response.sendRedirect("login.jsp");
    return;
}

String fullName   = (String) session.getAttribute("fullName");
String department = (String) session.getAttribute("department");
String roleLabel  = (String) session.getAttribute("roleLabel");
if (roleLabel == null) roleLabel = "Manager";

String firstName = (fullName != null && fullName.contains(","))
    ? fullName.split(",")[1].trim().split(" ")[0]
    : (fullName != null ? fullName.split(" ")[0] : "Manager");

Integer assigned   = (Integer) request.getAttribute("assigned");
Integer pending    = (Integer) request.getAttribute("pending");
Integer inProgress = (Integer) request.getAttribute("inProgress");
Integer closed     = (Integer) request.getAttribute("closed");
Integer critical   = (Integer) request.getAttribute("critical");

List<Map<String, Object>> complaints =
    (List<Map<String, Object>>) request.getAttribute("complaints");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>TIP-SC | Manager Dashboard</title>
<jsp:include page="auth_header.jspf" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
#mgr-donutChart { width:160px!important;height:160px!important; }
#mgr-barChart   { width:100%!important;height:160px!important; }
</style>
</head>

<body class="dash-body">

<!-- ══════════ NAVBAR ══════════ -->
<nav class="navbar">
  <div class="nav-logo">
    <div class="nav-logo-dot"></div>
    <span class="nav-logo-name">TIP-SC</span>
  </div>

  <div class="nav-center">
    <button class="nav-btn dark"    onclick="showPage('concerns')">
      <i class="fa-solid fa-list-check" style="margin-right:5px;"></i>Concerns
    </button>
    <button class="nav-btn outline" onclick="showPage('schedule')">
      <i class="fa-regular fa-calendar" style="margin-right:5px;"></i>My Schedule
    </button>
    <button class="nav-btn outline" onclick="showPage('reports')">
      <i class="fa-solid fa-chart-bar" style="margin-right:5px;"></i>Reports
    </button>
    <button class="nav-btn outline" onclick="showPage('announcements')">
      <i class="fa-solid fa-bullhorn" style="margin-right:5px;"></i>Announcements
    </button>
    <button class="nav-btn outline" onclick="showPage('deptview')">
      <i class="fa-solid fa-building" style="margin-right:5px;"></i>Dept. View
    </button>
  </div>

  <div style="display:flex;align-items:center;gap:10px;">
    <span class="nav-role-badge"><%= roleLabel.toUpperCase() %></span>
    <div class="nav-user" onclick="toggleUserDropdown()">
      <div class="nav-avatar"><i class="fa-solid fa-user"></i></div>
      <span class="nav-uname"><%= fullName %></span>
    </div>
  </div>
</nav>

<!-- User Dropdown -->
<div class="user-dropdown" id="user-dropdown">
  <div class="ud-header">
    <div class="ud-name"><%= fullName %></div>
    <div class="ud-prog"><%= department %> — <%= roleLabel %></div>
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

<!-- ══════════ PAGE WRAP ══════════ -->
<div class="page-wrap" id="page-wrap">

<!-- ══════════════════════════════
     CONCERNS PAGE
══════════════════════════════ -->
<div class="page active" id="page-concerns">

  <!-- STATS HERO -->
  <div class="stats-card">
    <div class="stats-top">
      <div>
        <div class="greeting-name">Good day, <%= firstName %>!</div>
        <div class="greeting-prog"><%= department %> — <%= roleLabel %></div>
      </div>
      <div class="stats-nums">
        <div class="stat-item"><div class="stat-lbl">ASSIGNED</div>   <div class="stat-val"><%= assigned    != null ? assigned    : 0 %></div></div>
        <div class="stat-item"><div class="stat-lbl">PENDING</div>    <div class="stat-val"><%= pending     != null ? pending     : 0 %></div></div>
        <div class="stat-item"><div class="stat-lbl">IN PROGRESS</div><div class="stat-val"><%= inProgress  != null ? inProgress  : 0 %></div></div>
        <div class="stat-item"><div class="stat-lbl">CLOSED</div>     <div class="stat-val"><%= closed      != null ? closed      : 0 %></div></div>
        <div class="stat-item"><div class="stat-lbl">CRITICAL</div>   <div class="stat-val" style="color:#FF6B6B;"><%= critical   != null ? critical    : 0 %></div></div>
      </div>
    </div>

    <!-- Hamburger / chart toggle -->
    <div class="chart-toggle" id="mgr-chart-toggle" onclick="toggleMgrChart()" title="Show charts">
      <i class="fa-solid fa-bars-staggered"></i>
    </div>

    <div class="chart-panel" id="mgr-chart-panel">
      <div class="viewed-by">
        <div class="vb-lbl">Viewed by:</div>
        <button class="vb-btn on"  onclick="switchMgrView('status',this)">Status</button>
        <button class="vb-btn"     onclick="switchMgrView('priority',this)">Priority</button>
        <button class="vb-btn"     onclick="switchMgrView('category',this)">Category</button>
        <button class="vb-btn"     onclick="switchMgrView('department',this)">Department</button>
      </div>
      <div class="charts-area">
        <div class="chart-donut-wrap"><canvas id="mgr-donutChart" width="160" height="160"></canvas></div>
        <div class="chart-bar-wrap"><canvas id="mgr-barChart"   width="300" height="160"></canvas></div>
      </div>
    </div>
  </div>

  <!-- TABLE CARD -->
  <div class="table-card">
    <div class="search-wrap">
      <div class="search-box">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" id="mgr-search" placeholder="Search by title, reference, or student name..." oninput="mgrFilter()"/>
      </div>
    </div>

    <div class="filters-row">
      <span class="filter-lbl">Filters:</span>
      <button class="filter-btn on" onclick="mgrApplyFilter('all',this)">All</button>
      <button class="filter-btn"   onclick="mgrApplyFilter('Pending',this)">Pending</button>
      <button class="filter-btn"   onclick="mgrApplyFilter('In Progress',this)">In Progress</button>
      <button class="filter-btn"   onclick="mgrApplyFilter('Closed',this)">Closed</button>
      <button class="filter-btn"   onclick="mgrApplyFilter('Critical',this)">Critical</button>
      <button class="filter-btn"   onclick="mgrApplyFilter('High',this)">High</button>
    </div>

    <table class="concern-table">
      <thead>
        <tr>
          <th>Ref No. <span class="si">↕</span></th>
          <th>Student <span class="si">↕</span></th>
          <th>Title <span class="si">↕</span></th>
          <th>Category <span class="si">↕</span></th>
          <th>Type <span class="si">↕</span></th>
          <th>Priority <span class="si">↕</span></th>
          <th>Submitted <span class="si">↕</span></th>
          <th>Last Update <span class="si">↕</span></th>
          <th>Status <span class="si">↕</span></th>
          <th>View</th>
        </tr>
      </thead>
      <tbody id="mgr-table-body">
      <%
      if (complaints != null && !complaints.isEmpty()) {
          for (Map<String, Object> c : complaints) {
              String status   = String.valueOf(c.get("STATUS"));
              String priority = String.valueOf(c.get("PRIORITY"));
              String statusBadge   = "badge-" + status.toLowerCase().replace(" ","");
              String priorityBadge = "badge-" + priority.toLowerCase();
              String studentName = String.valueOf(c.get("STUDENT_NAME"));
      %>
        <tr data-status="<%= status %>" data-priority="<%= priority %>">
          <td><%= c.get("ID") %></td>
          <td>
            <div class="student-col">
              <span class="s-name"><%= studentName %></span>
              <span class="s-id"><%= c.get("STUDENT_ID") != null ? c.get("STUDENT_ID") : "" %></span>
            </div>
          </td>
          <td><%= c.get("TITLE") %></td>
          <td><%= c.get("CATEGORY") %></td>
          <td><%= c.get("TYPE") %></td>
          <td><span class="badge <%= priorityBadge %>"><%= priority %></span></td>
          <td><%= c.get("SUBMITTED_AT") %></td>
          <td><%= c.get("UPDATED_AT") %></td>
          <td><span class="badge <%= statusBadge %>"><%= status %></span></td>
          <td>
            <button class="view-btn"
              onclick="openMgrMsg(
                '<%= jsEscape(c.get("ID")) %>',
                '<%= jsEscape(c.get("TITLE")) %>',
                '<%= jsEscape(c.get("CATEGORY")) %>',
                '<%= jsEscape(c.get("TYPE")) %>',
                '<%= jsEscape(c.get("DEPARTMENT")) %>',
                '<%= jsEscape(status) %>',
                '<%= jsEscape(priority) %>',
                '<%= jsEscape(c.get("SUBMITTED_AT")) %>',
                '<%= jsEscape(studentName) %>',
                '<%= jsEscape(c.get("ASSIGNED_TO")) != null ? jsEscape(c.get("ASSIGNED_TO")) : "" %>'
              )">View</button>
          </td>
        </tr>
      <%
          }
      } else { %>
        <tr><td colspan="10" style="text-align:center;padding:24px;color:rgba(255,255,255,.3);font-size:.78rem;">No concerns assigned yet.</td></tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div><!-- /page-concerns -->

<!-- Placeholder pages -->
<div class="page" id="page-schedule">
  <div style="padding:40px;text-align:center;color:rgba(255,255,255,.3);font-size:.88rem;">My Schedule — Coming soon</div>
</div>
<div class="page" id="page-reports">
  <div style="padding:40px;text-align:center;color:rgba(255,255,255,.3);font-size:.88rem;">Reports — Coming soon</div>
</div>
<div class="page" id="page-announcements">
  <div style="padding:40px;text-align:center;color:rgba(255,255,255,.3);font-size:.88rem;">Announcements — Coming soon</div>
</div>
<div class="page" id="page-deptview">
  <div style="padding:40px;text-align:center;color:rgba(255,255,255,.3);font-size:.88rem;">Department View — Coming soon</div>
</div>

</div><!-- /page-wrap -->

<!-- ══════════════════════════════
     MANAGER MESSAGING MODAL
══════════════════════════════ -->
<div class="overlay" id="overlay-mgr-msg">
  <div class="msg-modal" style="max-width:860px;">
    <div class="msg-header">
      <div class="msg-header-inner">
        <span class="msg-title">UPDATES AND STAFF FEEDBACK</span>
        <span class="msg-subtitle" id="mgr-msg-ref-label">Reference No. —</span>
      </div>
      <button class="msg-close" onclick="closeModal('overlay-mgr-msg')">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>

    <div class="msg-body">
      <!-- Thread -->
      <div class="msg-left">
        <div class="msg-thread" id="mgr-msg-thread">
          <div style="text-align:center;padding:32px;font-size:.78rem;color:rgba(255,255,255,.25);">Loading...</div>
        </div>
        <div class="msg-reply-area">
          <textarea class="msg-input" id="mgr-reply-input"
            placeholder="Write a message to the student..."></textarea>
          <div class="msg-footer">
            <span class="msg-footer-note">
              <i class="fa-regular fa-envelope"></i>
              Student will receive email notification
            </span>
            <button class="send-btn" onclick="mgrSendReply()">Send Reply</button>
          </div>
        </div>
      </div>

      <!-- Reference + Edit -->
      <div class="msg-right">
        <div class="msg-right-title">Reference</div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Ref No.</span>   <span class="msg-detail-val" id="mgr-md-ref">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Student</span>   <span class="msg-detail-val" id="mgr-md-student">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Assigned to</span><span class="msg-detail-val" id="mgr-md-assigned">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Submitted</span> <span class="msg-detail-val" id="mgr-md-submitted">—</span></div>

        <!-- Edit concern section -->
        <div class="edit-section">
          <div class="edit-section-lbl">Edit Concern</div>

          <label class="fl" style="margin-bottom:4px;">CATEGORY</label>
          <select id="mgr-edit-cat" class="fi fi-sel" style="margin-bottom:10px;">
            <option>Academic</option><option>Financial</option>
            <option>Student Life</option><option>Administrative</option><option>Others</option>
          </select>

          <label class="fl" style="margin-bottom:4px;">TYPE</label>
          <select id="mgr-edit-type" class="fi fi-sel" style="margin-bottom:10px;">
            <option>Grade Correction Request</option><option>Grade Consultation</option>
            <option>Academic Records Request</option><option>Subject Enrollment Issue</option>
            <option>Others</option>
          </select>

          <label class="fl" style="margin-bottom:4px;">DEPARTMENT</label>
          <select id="mgr-edit-dept" class="fi fi-sel" style="margin-bottom:10px;">
            <option>Registrar Office</option><option>Finance Office</option>
            <option>OSA Office</option><option>OSAS Office</option>
            <option>Facilities Office</option>
          </select>

          <label class="fl" style="margin-bottom:4px;">PRIORITY</label>
          <select id="mgr-edit-priority" class="fi fi-sel" style="margin-bottom:12px;">
            <option>Low</option><option>Medium</option><option>High</option><option>Critical</option>
          </select>

          <label class="fl" style="margin-bottom:6px;">STATUS</label>
          <div class="status-btns">
            <button class="sts-btn on" data-val="Pending"     onclick="setMgrStatus('Pending',this)">Pending</button>
            <button class="sts-btn"    data-val="In Progress" onclick="setMgrStatus('In Progress',this)">In Progress</button>
            <button class="sts-btn"    data-val="Closed"      onclick="setMgrStatus('Closed',this)">Closed</button>
          </div>
          <input type="hidden" id="mgr-status-val" value="Pending"/>

          <button class="mark-closed-btn" style="margin-top:8px;" onclick="setMgrStatus('Closed', this)">
            → Mark as Closed
          </button>

          <button class="save-changes-btn" onclick="mgrSaveChanges()">
            <i class="fa-solid fa-floppy-disk" style="margin-right:5px;"></i>Save Changes
          </button>
        </div>
      </div><!-- /msg-right -->
    </div><!-- /msg-body -->
  </div><!-- /msg-modal -->
</div>

<!-- Settings Modal -->
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
          <div class="info-field"><label>Full Name</label><div class="info-val"><%= fullName %></div></div>
          <div class="info-field"><label>Department</label><div class="info-val"><%= department %></div></div>
          <div class="info-field"><label>Role</label><div class="info-val"><%= roleLabel %></div></div>
        </div>
      </div>
      <div class="settings-section">
        <div class="settings-sec-title">Change Password</div>
        <div class="fl-form">
          <div class="fl-field">
            <label>Current Password <span>*</span></label>
            <div class="fl-iw"><i class="fa-solid fa-lock"></i><input type="password" placeholder="Enter current password"/></div>
          </div>
          <div class="fl-field">
            <label>New Password <span>*</span></label>
            <div class="fl-iw"><i class="fa-solid fa-lock"></i><input type="password" placeholder="Enter new password"/></div>
          </div>
        </div>
        <button class="btn-yellow-full" style="margin-top:8px;">Save Changes</button>
      </div>
    </div>
  </div>
</div>

<!-- ══════════ DATA + SCRIPTS ══════════ -->
<script>
const mgrRaw = [
  <% if (complaints != null) {
       for (int i = 0; i < complaints.size(); i++) {
         Map<String,Object> c = complaints.get(i); %>
  {
    status:     '<%= jsEscape(c.get("STATUS"))     %>',
    priority:   '<%= jsEscape(c.get("PRIORITY"))   %>',
    category:   '<%= jsEscape(c.get("CATEGORY"))   %>',
    department: '<%= jsEscape(c.get("DEPARTMENT")) %>'
  }<%= i < complaints.size()-1 ? "," : "" %>
  <% } } %>
];

const MGR_COLORS = {
  status:    ['#E040FB','#FFA533','#6EAAEE','#888888','#FF6B6B'],
  priority:  ['#FF6B6B','#FFA533','#6EAAEE','#33CC66'],
  category:  ['#e4bf05','#6EAAEE','#FF6B6B','#33CC66','#cc88ff'],
  department:['#e4bf05','#6EAAEE','#FF6B6B','#33CC66','#cc88ff','#FFA533']
};

function mgrCountBy(key) {
  const m = {};
  mgrRaw.forEach(c => { m[c[key]] = (m[c[key]] || 0) + 1; });
  return m;
}

let mgrDonut, mgrBar;
function renderMgrCharts(view) {
  const map    = mgrCountBy(view);
  const labels = Object.keys(map);
  const data   = Object.values(map);
  const cols   = MGR_COLORS[view] || MGR_COLORS.status;

  if (mgrDonut) mgrDonut.destroy();
  if (mgrBar)   mgrBar.destroy();

  mgrDonut = new Chart(document.getElementById('mgr-donutChart').getContext('2d'), {
    type:'doughnut', data:{labels,datasets:[{data,backgroundColor:cols,borderWidth:0}]},
    options:{responsive:false,plugins:{legend:{display:false}},cutout:'62%'}
  });
  mgrBar = new Chart(document.getElementById('mgr-barChart').getContext('2d'), {
    type:'bar',
    data:{labels,datasets:[{data,backgroundColor:cols,borderRadius:5,borderSkipped:false}]},
    options:{
      responsive:true,
      plugins:{legend:{display:true,position:'top',labels:{color:'rgba(255,255,255,.65)',font:{size:10},
        generateLabels:chart=>labels.map((l,i)=>({text:`${l} — ${data[i]}`,fillStyle:cols[i],strokeStyle:'transparent',index:i}))
      }}},
      scales:{
        x:{ticks:{color:'rgba(255,255,255,.45)',font:{size:10}},grid:{color:'rgba(255,255,255,.06)'}},
        y:{ticks:{color:'rgba(255,255,255,.45)',font:{size:10},stepSize:1},grid:{color:'rgba(255,255,255,.06)'}}
      }
    }
  });
}

let mgrChartOpen = false;
function toggleMgrChart() {
  mgrChartOpen = !mgrChartOpen;
  document.getElementById('mgr-chart-panel').classList.toggle('open', mgrChartOpen);
  if (mgrChartOpen) renderMgrCharts('status');
}
function switchMgrView(view, btn) {
  document.querySelectorAll('#mgr-chart-panel .vb-btn').forEach(b => b.classList.remove('on'));
  btn.classList.add('on');
  renderMgrCharts(view);
}

// Pages
function showPage(p) {
  document.querySelectorAll('.page').forEach(x => x.classList.remove('active'));
  document.getElementById('page-' + p).classList.add('active');
  document.querySelectorAll('.nav-btn').forEach(b => b.className = 'nav-btn outline');
  event.target.className = 'nav-btn dark';
}

// Dropdown
function toggleUserDropdown() { document.getElementById('user-dropdown').classList.toggle('show'); }
document.addEventListener('click', e => {
  if (!e.target.closest('.nav-user') && !e.target.closest('#user-dropdown'))
    document.getElementById('user-dropdown').classList.remove('show');
});

// Modals
function closeModal(id) {
  document.getElementById(id).classList.remove('show');
  document.getElementById('page-wrap').classList.remove('blurred');
}
function openModal(id) {
  document.getElementById(id).classList.add('show');
  document.getElementById('page-wrap').classList.add('blurred');
}

// Manager messaging
let currentRef = '';
function openMgrMsg(ref, title, cat, type, dept, status, priority, submitted, student, assigned) {
  currentRef = ref;
  document.getElementById('mgr-msg-ref-label').textContent = 'Reference No. ' + ref;
  document.getElementById('mgr-md-ref').textContent       = ref;
  document.getElementById('mgr-md-student').textContent   = student;
  document.getElementById('mgr-md-assigned').textContent  = assigned || '—';
  document.getElementById('mgr-md-submitted').textContent = submitted;

  // Pre-fill edit fields
  setSelectVal('mgr-edit-cat',      cat);
  setSelectVal('mgr-edit-type',     type);
  setSelectVal('mgr-edit-dept',     dept);
  setSelectVal('mgr-edit-priority', priority);

  // Status buttons
  document.querySelectorAll('.sts-btn').forEach(b => {
    b.classList.toggle('on', b.dataset.val === status);
  });
  document.getElementById('mgr-status-val').value = status;

  // Load thread
  fetch('GetMessagesServlet?ref=' + encodeURIComponent(ref))
    .then(r => r.json())
    .then(msgs => renderMgrThread(msgs))
    .catch(() => { document.getElementById('mgr-msg-thread').innerHTML =
      '<div style="text-align:center;padding:24px;font-size:.78rem;color:rgba(255,255,255,.3);">No messages yet.</div>'; });

  openModal('overlay-mgr-msg');
}

function setSelectVal(id, val) {
  const sel = document.getElementById(id);
  for (let i = 0; i < sel.options.length; i++) {
    if (sel.options[i].value === val || sel.options[i].text === val) { sel.selectedIndex = i; break; }
  }
}

function renderMgrThread(msgs) {
  const thread = document.getElementById('mgr-msg-thread');

  if (!msgs || msgs.length === 0) {
    thread.innerHTML =
      '<div style="text-align:center;padding:24px;font-size:.78rem;color:rgba(255,255,255,.3);">No messages yet.</div>';
    return;
  }

  const escapeHtml = (str) => {
    if (!str) return '';
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  };

  thread.innerHTML = msgs.map(m => {
    const role = (m.role || '').toLowerCase();
    const isStaff = role === 'staff' || role === 'manager' || role === 'admin';

    return `
      <div class="msg-bubble">
        <div class="msg-sender">
          <div class="msg-av ${isStaff ? 'staff' : 'student'}">
            <i class="fa-solid fa-user"></i>
          </div>

          <div>
            <div class="msg-sender-name">
              ${escapeHtml(m.senderName || 'Unknown')}
              ${isStaff ? ' — Staff' : ''}
            </div>
            <div class="msg-sender-time">
              ${escapeHtml(m.sentAt || '')}
            </div>
          </div>
        </div>

        <div class="msg-text ${isStaff ? 'from-staff' : ''}">
          ${escapeHtml(m.messageText || '')}
        </div>
      </div>
    `;
  }).join('');

  thread.scrollTop = thread.scrollHeight;
}

function mgrSendReply() {
  const input = document.getElementById('mgr-reply-input');
  const msg   = input.value.trim();
  if (!msg) return;

  fetch('SendMessageServlet', {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: 'ref=' + encodeURIComponent(currentRef) + '&message=' + encodeURIComponent(msg)
  })
  .then(r => r.json())
  .then(msgs => { input.value = ''; renderMgrThread(msgs); })
  .catch(() => alert('Failed to send.'));
}

function setMgrStatus(val, btn) {
  document.querySelectorAll('.sts-btn').forEach(b => b.classList.remove('on'));
  if (btn.classList.contains('sts-btn')) btn.classList.add('on');
  document.getElementById('mgr-status-val').value = val;
}

function mgrSaveChanges() {
  const data = {
    ref:      currentRef,
    category: document.getElementById('mgr-edit-cat').value,
    type:     document.getElementById('mgr-edit-type').value,
    dept:     document.getElementById('mgr-edit-dept').value,
    priority: document.getElementById('mgr-edit-priority').value,
    status:   document.getElementById('mgr-status-val').value
  };
  fetch('UpdateConcernServlet', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify(data)
  })
  .then(r => r.json())
  .then(() => { closeModal('overlay-mgr-msg'); window.location.reload(); })
  .catch(() => alert('Failed to save changes.'));
}

// Table filter
let mgrActiveFilter = 'all';
function mgrApplyFilter(val, btn) {
  mgrActiveFilter = val;
  document.querySelectorAll('.filters-row .filter-btn').forEach(b => b.classList.remove('on'));
  btn.classList.add('on');
  mgrFilter();
}
function mgrFilter() {
  const q    = document.getElementById('mgr-search').value.toLowerCase();
  const rows = document.querySelectorAll('#mgr-table-body tr');
  rows.forEach(r => {
    const matchSearch = r.innerText.toLowerCase().includes(q);
    const rowStatus   = (r.dataset.status || '').toLowerCase();
    const rowPriority = (r.dataset.priority || '').toLowerCase();
    const filterVal   = mgrActiveFilter.toLowerCase();
    const matchFilter = filterVal === 'all' || rowStatus === filterVal || rowPriority === filterVal;
    r.style.display   = (matchSearch && matchFilter) ? '' : 'none';
  });
}

function openSettings() {
  document.getElementById('user-dropdown').classList.remove('show');
  openModal('overlay-settings');
}
function signOut() {
    window.location.href = 'login.jsp?signout=true';
}
</script>

</body>
</html>
