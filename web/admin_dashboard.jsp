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
if (roleId == null || roleId != 3) {
    response.sendRedirect("login.jsp");
    return;
}

String fullName = (String) session.getAttribute("fullName");
String firstName = (fullName != null && fullName.contains(","))
    ? fullName.split(",")[1].trim().split(" ")[0]
    : (fullName != null ? fullName.split(" ")[0] : "Admin");

Integer totalComp   = (Integer) request.getAttribute("totalComplaints");
Integer activeStaff = (Integer) request.getAttribute("activeStaff");
Integer pending     = (Integer) request.getAttribute("pending");
Integer inReview    = (Integer) request.getAttribute("inReview");
Integer closed      = (Integer) request.getAttribute("closed");

List<Map<String, Object>> complaints =
    (List<Map<String, Object>>) request.getAttribute("complaints");
List<Map<String, Object>> staffList =
    (List<Map<String, Object>>) request.getAttribute("staffList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>TIP-SC | Admin Control Panel</title>
<jsp:include page="auth_header.jspf" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
#adm-donutChart { width:160px!important;height:160px!important; }
#adm-barChart   { width:100%!important;height:160px!important; }
/* Account management table */
.acct-table { width:100%; border-collapse:collapse; }
.acct-table th { padding:9px 12px; font-size:.65rem; font-weight:700; letter-spacing:.04em; color:var(--text-mw); text-align:left; background:#1E1E1E; border-bottom:1px solid var(--border-dark); }
.acct-table td { padding:9px 12px; font-size:.72rem; color:rgba(255,255,255,.75); border-bottom:1px solid rgba(255,255,255,.04); }
.acct-table tbody tr:nth-child(odd)  { background:var(--dark-row1); }
.acct-table tbody tr:nth-child(even) { background:var(--dark-row2); }
.acct-table tbody tr:hover           { background:#303030; }
.danger-btn { background:rgba(198,40,40,.15); border:1px solid #C62828; border-radius:20px; padding:3px 12px; font-size:.66rem; font-weight:700; color:#FF6B6B; transition:all .15s; }
.danger-btn:hover { background:rgba(198,40,40,.3); }
/* Create staff form */
.create-staff-form { background:#222; border-radius:14px; padding:24px; max-width:480px; }
.create-staff-form .form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:14px; }
.create-staff-title { font-weight:800; font-size:.88rem; color:#fff; margin-bottom:18px; }
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
    <button class="nav-btn outline" onclick="showPage('accounts')">
      <i class="fa-solid fa-users-gear" style="margin-right:5px;"></i>Account Management
    </button>
    <button class="nav-btn outline" onclick="showPage('reports')">
      <i class="fa-solid fa-chart-bar" style="margin-right:5px;"></i>Reports
    </button>
    <button class="nav-btn outline" onclick="showPage('auditlogs')">
      <i class="fa-solid fa-scroll" style="margin-right:5px;"></i>Audit Logs
    </button>
    <button class="nav-btn outline" onclick="showPage('settings-page')">
      <i class="fa-solid fa-sliders" style="margin-right:5px;"></i>System Settings
    </button>
  </div>

  <div style="display:flex;align-items:center;gap:10px;">
    <span class="nav-role-badge">ADMIN</span>
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
    <div class="ud-prog">System Administrator</div>
  </div>
  <div class="ud-items">
    <button class="ud-item" onclick="openModal('overlay-settings')">
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
        <div class="greeting-prog">System Administration</div>
      </div>
      <div class="stats-nums">
        <div class="stat-item"><div class="stat-lbl">TOTAL COMPLAINTS</div><div class="stat-val"><%= totalComp   != null ? totalComp   : 0 %></div></div>
        <div class="stat-item"><div class="stat-lbl">ACTIVE STAFF</div>   <div class="stat-val"><%= activeStaff != null ? activeStaff : 0 %></div></div>
        <div class="stat-item"><div class="stat-lbl">PENDING</div>         <div class="stat-val"><%= pending     != null ? pending     : 0 %></div></div>
        <div class="stat-item"><div class="stat-lbl">IN REVIEW</div>       <div class="stat-val"><%= inReview    != null ? inReview    : 0 %></div></div>
        <div class="stat-item"><div class="stat-lbl">CLOSED</div>          <div class="stat-val"><%= closed      != null ? closed      : 0 %></div></div>
      </div>
    </div>

    <!-- Hamburger toggle -->
    <div class="chart-toggle" onclick="toggleAdmChart()" title="Show charts">
      <i class="fa-solid fa-bars-staggered"></i>
    </div>

    <div class="chart-panel" id="adm-chart-panel">
      <div class="viewed-by">
        <div class="vb-lbl">Viewed by:</div>
        <button class="vb-btn on"  onclick="switchAdmView('status',this)">Status</button>
        <button class="vb-btn"     onclick="switchAdmView('priority',this)">Priority</button>
        <button class="vb-btn"     onclick="switchAdmView('category',this)">Category</button>
        <button class="vb-btn"     onclick="switchAdmView('department',this)">Department</button>
      </div>
      <div class="charts-area">
        <div class="chart-donut-wrap"><canvas id="adm-donutChart" width="160" height="160"></canvas></div>
        <div class="chart-bar-wrap"><canvas id="adm-barChart"   width="300" height="160"></canvas></div>
      </div>
    </div>
  </div>

  <!-- TABLE -->
  <div class="table-card">
    <div class="search-wrap">
      <div class="search-box">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" id="adm-search" placeholder="Search complaints..." oninput="admFilter()"/>
      </div>
    </div>
    <div class="filters-row">
      <span class="filter-lbl">Filters:</span>
      <button class="filter-btn on" onclick="admApplyFilter('all',this)">All</button>
      <button class="filter-btn"   onclick="admApplyFilter('Pending',this)">Pending</button>
      <button class="filter-btn"   onclick="admApplyFilter('Open',this)">Open</button>
      <button class="filter-btn"   onclick="admApplyFilter('In Review',this)">In Review</button>
      <button class="filter-btn"   onclick="admApplyFilter('Closed',this)">Closed</button>
    </div>

    <table class="concern-table">
      <thead>
        <tr>
          <th>ID</th><th>Student</th><th>Title</th><th>Category</th>
          <th>Status</th><th>Assigned To</th><th>Submitted</th><th>View</th><th>Delete</th>
        </tr>
      </thead>
      <tbody id="adm-table-body">
      <%
      if (complaints != null && !complaints.isEmpty()) {
          for (Map<String,Object> c : complaints) {
              String status = String.valueOf(c.get("STATUS"));
              String statusBadge = "badge-" + status.toLowerCase().replace(" ","");
      %>
        <tr data-status="<%= status %>">
          <td><%= c.get("ID") %></td>
          <td>
            <div class="student-col">
              <span class="s-name"><%= c.get("STUDENT_NAME") %></span>
            </div>
          </td>
          <td><%= c.get("TITLE") %></td>
          <td><%= c.get("CATEGORY") %></td>
          <td><span class="badge <%= statusBadge %>"><%= status %></span></td>
          <td><%= c.get("ASSIGNED_TO") != null ? c.get("ASSIGNED_TO") : "—" %></td>
          <td><%= c.get("SUBMITTED_AT") %></td>
          <td>
            <button class="view-btn"
              onclick="openAdmMsg(
                '<%= jsEscape(c.get("ID")) %>',
                '<%= jsEscape(c.get("TITLE")) %>',
                '<%= jsEscape(c.get("CATEGORY")) %>',
                '<%= jsEscape(c.get("TYPE")) %>',
                '<%= jsEscape(c.get("DEPARTMENT")) %>',
                '<%= jsEscape(status) %>',
                '<%= jsEscape(c.get("PRIORITY")) %>',
                '<%= jsEscape(c.get("SUBMITTED_AT")) %>',
                '<%= jsEscape(c.get("STUDENT_NAME")) %>',
                '<%= jsEscape(c.get("ASSIGNED_TO")) != null ? jsEscape(c.get("ASSIGNED_TO")) : "" %>'
              )">Manage</button>
          </td>
          <td>
            <form action="DeleteComplaintServlet" method="post" style="display:inline;"
              onsubmit="return confirm('Delete this concern?');">
              <input type="hidden" name="complaintId" value="<%= c.get("ID") %>"/>
              <button type="submit" class="danger-btn">Delete</button>
            </form>
          </td>
        </tr>
      <% } } else { %>
        <tr><td colspan="9" style="text-align:center;padding:24px;color:rgba(255,255,255,.3);font-size:.78rem;">No complaints found.</td></tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div><!-- /page-concerns -->


<!-- ══════════════════════════════
     ACCOUNT MANAGEMENT PAGE
══════════════════════════════ -->
<div class="page" id="page-accounts">
  <div style="margin-bottom:20px;">
    <div style="font-weight:800;font-size:1.1rem;color:#111;margin-bottom:4px;">Account Management</div>
    <div style="font-size:.8rem;color:#555;">Create, manage, and deactivate staff accounts.</div>
  </div>

  <div style="display:grid;grid-template-columns:1fr 320px;gap:18px;align-items:start;">

    <!-- Staff list -->
    <div class="table-card">
      <div class="search-wrap">
        <div class="search-box">
          <i class="fa-solid fa-magnifying-glass"></i>
          <input type="text" placeholder="Search staff..." oninput="staffFilter(this.value)"/>
        </div>
      </div>
      <table class="acct-table" id="staff-table">
        <thead>
          <tr>
            <th>Name</th><th>Email</th><th>Department</th><th>Role</th><th>Status</th><th>Actions</th>
          </tr>
        </thead>
        <tbody id="staff-tbody">
        <% if (staffList != null) { for (Map<String,Object> s : staffList) { %>
          <tr>
            <td><%= s.get("FULL_NAME") %></td>
            <td><%= s.get("EMAIL") %></td>
            <td><%= s.get("DEPARTMENT") %></td>
            <td><%= s.get("ROLE_LABEL") %></td>
            <td>
              <span class="badge <%= "Active".equals(String.valueOf(s.get("ACCOUNT_STATUS"))) ? "badge-low" : "badge-closed" %>">
                <%= s.get("ACCOUNT_STATUS") %>
              </span>
            </td>
            <td>
              <form action="DeactivateStaffServlet" method="post" style="display:inline;">
                <input type="hidden" name="staffId" value="<%= s.get("ID") %>"/>
                <button type="submit" class="danger-btn">Deactivate</button>
              </form>
            </td>
          </tr>
        <% } } %>
        </tbody>
      </table>
    </div>

    <!-- Create staff form -->
    <div class="create-staff-form">
      <div class="create-staff-title"><i class="fa-solid fa-user-plus" style="margin-right:6px;color:var(--yellow-nav);"></i>Create Staff Account</div>
      <form action="CreateStaffServlet" method="post">
        <div style="margin-bottom:12px;">
          <label class="fl">FULL NAME <span class="req">*</span></label>
          <input type="text" name="fullName" class="fi" placeholder="Last, First Middle" required/>
        </div>
        <div style="margin-bottom:12px;">
          <label class="fl">EMAIL <span class="req">*</span></label>
          <input type="email" name="email" class="fi" placeholder="name@tip.edu.ph" required/>
        </div>
        <div style="margin-bottom:12px;">
          <label class="fl">DEPARTMENT <span class="req">*</span></label>
          <select name="department" class="fi fi-sel" required>
            <option value="">-- Select Department --</option>
            <option>Registrar Office</option>
            <option>Finance Office</option>
            <option>OSA Office</option>
            <option>OSAS Office</option>
            <option>Facilities Office</option>
          </select>
        </div>
        <div style="margin-bottom:12px;">
          <label class="fl">ROLE <span class="req">*</span></label>
          <select name="roleLabel" class="fi fi-sel" required>
            <option value="">-- Select Role --</option>
            <option>Manager</option>
            <option>Staff</option>
          </select>
        </div>
        <div style="margin-bottom:18px;">
          <label class="fl">TEMPORARY PASSWORD <span class="req">*</span></label>
          <input type="text" name="password" class="fi" placeholder="Temporary password" required/>
        </div>
        <button type="submit" class="save-changes-btn">
          <i class="fa-solid fa-user-plus" style="margin-right:5px;"></i>Create Account
        </button>
      </form>
    </div>
  </div>
</div><!-- /page-accounts -->

<!-- Placeholder pages -->
<div class="page" id="page-reports">
  <div style="padding:40px;text-align:center;color:rgba(255,255,255,.3);font-size:.88rem;">Reports — Coming soon</div>
</div>
<div class="page" id="page-auditlogs">
  <div style="padding:40px;text-align:center;color:rgba(255,255,255,.3);font-size:.88rem;">Audit Logs — Coming soon</div>
</div>
<div class="page" id="page-settings-page">
  <div style="padding:40px;text-align:center;color:rgba(255,255,255,.3);font-size:.88rem;">System Settings — Coming soon</div>
</div>

</div><!-- /page-wrap -->


<!-- ══════════════════════════════
     ADMIN MANAGE MODAL (same structure as manager)
══════════════════════════════ -->
<div class="overlay" id="overlay-adm-msg">
  <div class="msg-modal" style="max-width:860px;">
    <div class="msg-header">
      <div class="msg-header-inner">
        <span class="msg-title">MANAGE CONCERN</span>
        <span class="msg-subtitle" id="adm-msg-ref-label">Reference No. —</span>
      </div>
      <button class="msg-close" onclick="closeModal('overlay-adm-msg')">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>

    <div class="msg-body">
      <div class="msg-left">
        <div class="msg-thread" id="adm-msg-thread">
          <div style="text-align:center;padding:32px;font-size:.78rem;color:rgba(255,255,255,.25);">Loading...</div>
        </div>
        <div class="msg-reply-area">
          <textarea class="msg-input" id="adm-reply-input"
            placeholder="Write a message to the student..."></textarea>
          <div class="msg-footer">
            <span class="msg-footer-note">
              <i class="fa-regular fa-envelope"></i>
              Student will receive email notification
            </span>
            <button class="send-btn" onclick="admSendReply()">Send Reply</button>
          </div>
        </div>
      </div>

      <div class="msg-right">
        <div class="msg-right-title">Reference</div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Ref No.</span>   <span class="msg-detail-val" id="adm-md-ref">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Student</span>   <span class="msg-detail-val" id="adm-md-student">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Assigned to</span><span class="msg-detail-val" id="adm-md-assigned">—</span></div>
        <div class="msg-detail-row"><span class="msg-detail-lbl">Submitted</span> <span class="msg-detail-val" id="adm-md-submitted">—</span></div>

        <div class="edit-section">
          <div class="edit-section-lbl">Edit Concern</div>

          <label class="fl" style="margin-bottom:4px;">CATEGORY</label>
          <select id="adm-edit-cat" class="fi fi-sel" style="margin-bottom:10px;">
            <option>Academic</option><option>Financial</option>
            <option>Student Life</option><option>Administrative</option><option>Others</option>
          </select>

          <label class="fl" style="margin-bottom:4px;">DEPARTMENT</label>
          <select id="adm-edit-dept" class="fi fi-sel" style="margin-bottom:10px;">
            <option>Registrar Office</option><option>Finance Office</option>
            <option>OSA Office</option><option>OSAS Office</option>
            <option>Facilities Office</option>
          </select>

          <label class="fl" style="margin-bottom:4px;">ASSIGN TO</label>
          <input type="text" id="adm-edit-assigned" class="fi" placeholder="Staff name" style="margin-bottom:10px;"/>

          <label class="fl" style="margin-bottom:4px;">PRIORITY</label>
          <select id="adm-edit-priority" class="fi fi-sel" style="margin-bottom:12px;">
            <option>Low</option><option>Medium</option><option>High</option><option>Critical</option>
          </select>

          <label class="fl" style="margin-bottom:6px;">STATUS</label>
          <div class="status-btns">
            <button class="sts-btn on" data-val="Pending"    onclick="setAdmStatus('Pending',this)">Pending</button>
            <button class="sts-btn"    data-val="In Review"  onclick="setAdmStatus('In Review',this)">In Review</button>
            <button class="sts-btn"    data-val="Closed"     onclick="setAdmStatus('Closed',this)">Closed</button>
          </div>
          <input type="hidden" id="adm-status-val" value="Pending"/>

          <button class="mark-closed-btn" style="margin-top:8px;" onclick="setAdmStatus('Closed', this)">
  → Mark as Closed
</button>

          <button class="save-changes-btn" onclick="admSaveChanges()">
            <i class="fa-solid fa-floppy-disk" style="margin-right:5px;"></i>Save Changes
          </button>
        </div>
      </div>
    </div>
  </div>
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
          <div class="info-field"><label>Role</label><div class="info-val">System Administrator</div></div>
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

<script>
const admRaw = [
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
const ADM_COLORS = {
  status:    ['#E040FB','#FFA533','#6EAAEE','#888888'],
  priority:  ['#FF6B6B','#FFA533','#6EAAEE','#33CC66'],
  category:  ['#e4bf05','#6EAAEE','#FF6B6B','#33CC66','#cc88ff'],
  department:['#e4bf05','#6EAAEE','#FF6B6B','#33CC66','#cc88ff','#FFA533'],
};
function admCountBy(key) { const m={}; admRaw.forEach(c=>{m[c[key]]=(m[c[key]]||0)+1;}); return m; }

let admDonut, admBar;
function renderAdmCharts(view) {
  const map=admCountBy(view), labels=Object.keys(map), data=Object.values(map), cols=ADM_COLORS[view]||ADM_COLORS.status;
  if(admDonut) admDonut.destroy(); if(admBar) admBar.destroy();
  admDonut = new Chart(document.getElementById('adm-donutChart').getContext('2d'),{
    type:'doughnut',data:{labels,datasets:[{data,backgroundColor:cols,borderWidth:0}]},
    options:{responsive:false,plugins:{legend:{display:false}},cutout:'62%'}
  });
  admBar = new Chart(document.getElementById('adm-barChart').getContext('2d'),{
    type:'bar',data:{labels,datasets:[{data,backgroundColor:cols,borderRadius:5,borderSkipped:false}]},
    options:{responsive:true,plugins:{legend:{display:true,position:'top',labels:{color:'rgba(255,255,255,.65)',font:{size:10},
      generateLabels:chart=>labels.map((l,i)=>({text:`${l} — ${data[i]}`,fillStyle:cols[i],strokeStyle:'transparent',index:i}))
    }}},scales:{
      x:{ticks:{color:'rgba(255,255,255,.45)',font:{size:10}},grid:{color:'rgba(255,255,255,.06)'}},
      y:{ticks:{color:'rgba(255,255,255,.45)',font:{size:10},stepSize:1},grid:{color:'rgba(255,255,255,.06)'}}
    }}
  });
}

let admChartOpen=false;
function toggleAdmChart(){
  admChartOpen=!admChartOpen;
  document.getElementById('adm-chart-panel').classList.toggle('open',admChartOpen);
  if(admChartOpen) renderAdmCharts('status');
}
function switchAdmView(v,btn){
  document.querySelectorAll('#adm-chart-panel .vb-btn').forEach(b=>b.classList.remove('on'));
  btn.classList.add('on'); renderAdmCharts(v);
}

// Pages
function showPage(p){
  document.querySelectorAll('.page').forEach(x=>x.classList.remove('active'));
  document.getElementById('page-'+p).classList.add('active');
  document.querySelectorAll('.nav-btn').forEach(b=>b.className='nav-btn outline');
  event.target.className='nav-btn dark';
}

// Dropdown
function toggleUserDropdown(){document.getElementById('user-dropdown').classList.toggle('show');}
document.addEventListener('click',e=>{
  if(!e.target.closest('.nav-user')&&!e.target.closest('#user-dropdown'))
    document.getElementById('user-dropdown').classList.remove('show');
});

// Modals
function closeModal(id){document.getElementById(id).classList.remove('show');document.getElementById('page-wrap').classList.remove('blurred');}
function openModal(id){document.getElementById(id).classList.add('show');document.getElementById('page-wrap').classList.add('blurred');}

// Filters
let admActiveFilter='all';
function admApplyFilter(v,btn){
  admActiveFilter=v;
  document.querySelectorAll('#page-concerns .filters-row .filter-btn').forEach(b=>b.classList.remove('on'));
  btn.classList.add('on'); admFilter();
}
function admFilter(){
  const q=document.getElementById('adm-search').value.toLowerCase();
  document.querySelectorAll('#adm-table-body tr').forEach(r=>{
    const match=r.innerText.toLowerCase().includes(q);
    const rowStatus=(r.dataset.status||'').toLowerCase();
    const filterMatch=admActiveFilter==='all'||rowStatus===admActiveFilter.toLowerCase();
    r.style.display=(match&&filterMatch)?'':'none';
  });
}
function staffFilter(q){
  document.querySelectorAll('#staff-tbody tr').forEach(r=>{
    r.style.display=r.innerText.toLowerCase().includes(q.toLowerCase())?'':'none';
  });
}

// Admin messaging
let admCurrentRef='';
function openAdmMsg(ref,title,cat,type,dept,status,priority,submitted,student,assigned){
  admCurrentRef=ref;
  document.getElementById('adm-msg-ref-label').textContent='Reference No. '+ref;
  document.getElementById('adm-md-ref').textContent=ref;
  document.getElementById('adm-md-student').textContent=student;
  document.getElementById('adm-md-assigned').textContent=assigned||'—';
  document.getElementById('adm-md-submitted').textContent=submitted;
  document.getElementById('adm-edit-assigned').value=assigned||'';
  setAdmSelectVal('adm-edit-cat',cat);
  setAdmSelectVal('adm-edit-dept',dept);
  setAdmSelectVal('adm-edit-priority',priority);
  document.querySelectorAll('#overlay-adm-msg .sts-btn').forEach(b=>b.classList.toggle('on',b.dataset.val===status));
  document.getElementById('adm-status-val').value=status;

  fetch('GetMessagesServlet?ref='+encodeURIComponent(ref))
    .then(r=>r.json())
    .then(msgs=>renderAdmThread(msgs))
    .catch(()=>{document.getElementById('adm-msg-thread').innerHTML=
      '<div style="text-align:center;padding:24px;font-size:.78rem;color:rgba(255,255,255,.3);">No messages yet.</div>';});
  openModal('overlay-adm-msg');
}
function setAdmSelectVal(id,val){
  const sel=document.getElementById(id);
  for(let i=0;i<sel.options.length;i++){
    if(sel.options[i].value===val||sel.options[i].text===val){sel.selectedIndex=i;break;}
  }
}
function renderAdmThread(msgs) {
  const thread = document.getElementById('adm-msg-thread');

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
function admSendReply(){
  const input=document.getElementById('adm-reply-input');
  const msg=input.value.trim(); if(!msg) return;
  fetch('SendMessageServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'ref='+encodeURIComponent(admCurrentRef)+'&message='+encodeURIComponent(msg)})
    .then(r=>r.json()).then(msgs=>{input.value='';renderAdmThread(msgs);})
    .catch(()=>alert('Failed to send.'));
}
function setAdmStatus(val,btn){
  document.querySelectorAll('#overlay-adm-msg .sts-btn').forEach(b=>b.classList.remove('on'));
  if(btn&&btn.classList&&btn.classList.contains('sts-btn')) btn.classList.add('on');
  document.getElementById('adm-status-val').value=val;
}
function admSaveChanges(){
  fetch('UpdateConcernServlet',{method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({
      ref:admCurrentRef,
      category:document.getElementById('adm-edit-cat').value,
      dept:document.getElementById('adm-edit-dept').value,
      assigned:document.getElementById('adm-edit-assigned').value,
      priority:document.getElementById('adm-edit-priority').value,
      status:document.getElementById('adm-status-val').value
    })
  }).then(()=>{closeModal('overlay-adm-msg');window.location.reload();})
    .catch(()=>alert('Failed to save changes.'));
}
function signOut() {
    window.location.href = 'login.jsp?signout=true';
}
</script>

</body>
</html>
