<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

String refNo  = request.getParameter("ref");

Map<String, Object> concern   = (Map<String, Object>)  request.getAttribute("concern");
List<Map<String,Object>> msgs = (List<Map<String,Object>>) request.getAttribute("messages");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>TIP-SC | Manage — <%= refNo %></title>
<jsp:include page="auth_header.jspf" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
.thread-page-wrap { max-width:1000px; margin:0 auto; padding:20px 20px 40px; }
.thread-back { display:inline-flex;align-items:center;gap:7px;color:#555;font-size:.8rem;font-weight:600;text-decoration:none;margin-bottom:14px;transition:color .15s; }
.thread-back:hover { color:#111; }
.thread-card { background:#252525;border-radius:16px;overflow:hidden;box-shadow:0 8px 40px rgba(0,0,0,.35); }
.thread-header { background:#1E1E1E;padding:18px 22px;border-bottom:1px solid var(--border-dark);display:flex;align-items:flex-start;justify-content:space-between; }
.thread-header-title { font-weight:800;font-size:.92rem;letter-spacing:.06em;color:#fff;margin-bottom:3px; }
.thread-header-ref   { font-size:.7rem;color:var(--text-dw); }
/* 3-column: thread | right panel with details + edit */
.thread-layout { display:grid;grid-template-columns:1fr 300px;min-height:520px; }
.thread-left  { padding:20px;display:flex;flex-direction:column; }
.thread-msgs  { flex:1;overflow-y:auto;margin-bottom:16px;max-height:400px; }
.thread-reply-area { border-top:1px solid var(--border-dark);padding-top:16px; }
.thread-input { width:100%;background:#2E2E2E;border:1px solid var(--border-dark);border-radius:8px;padding:11px 14px;font-family:var(--fb);font-size:.8rem;color:#fff;outline:none;resize:none;height:80px;transition:border-color .15s; }
.thread-input:focus { border-color:rgba(200,168,0,.5); }
.thread-input::placeholder { color:rgba(255,255,255,.25); }
.thread-footer { display:flex;align-items:center;justify-content:space-between;margin-top:10px; }
.thread-note   { font-size:.68rem;color:rgba(255,255,255,.3);display:flex;align-items:center;gap:5px; }
.thread-right  { background:#1E1E1E;border-left:1px solid var(--border-dark);padding:20px;overflow-y:auto; }
.tr-section-lbl { font-size:.65rem;font-weight:700;letter-spacing:.06em;color:var(--text-dw);margin-bottom:12px;text-transform:uppercase; }
</style>
</head>

<body class="dash-body">

<nav class="navbar">
  <div class="nav-logo">
    <div class="nav-logo-dot"></div>
    <span class="nav-logo-name">TIP-SC</span>
  </div>
  <div class="nav-center">
    <a href="ManagerDashboardServlet" class="nav-btn dark" style="text-decoration:none;">
      <i class="fa-solid fa-list-check" style="margin-right:5px;"></i>Concerns
    </a>
  </div>
  <div style="display:flex;align-items:center;gap:10px;">
    <span class="nav-role-badge"><%= roleLabel.toUpperCase() %></span>
    <div class="nav-user" onclick="toggleDropdown()">
      <div class="nav-avatar"><i class="fa-solid fa-user"></i></div>
      <span class="nav-uname"><%= fullName %></span>
    </div>
  </div>
</nav>

<div class="user-dropdown" id="user-dropdown">
  <div class="ud-header">
    <div class="ud-name"><%= fullName %></div>
    <div class="ud-prog"><%= department %> — <%= roleLabel %></div>
  </div>
  <div class="ud-items">
    <button class="ud-item" onclick="window.location.href='ManagerDashboardServlet'">
      <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
    </button>
    <div class="ud-sep"></div>
    <button class="ud-item" onclick="window.location.href='SignOutServlet'" style="color:#C62828;">
      <i class="fa-solid fa-right-from-bracket"></i> Sign Out
    </button>
  </div>
</div>

<div class="page-wrap">
  <div class="thread-page-wrap">

    <a href="ManagerDashboardServlet" class="thread-back">
      <i class="fa-solid fa-chevron-left"></i> Back to Concerns
    </a>

    <div class="thread-card">
      <div class="thread-header">
        <div>
          <div class="thread-header-title">UPDATES AND STAFF FEEDBACK</div>
          <div class="thread-header-ref">Reference No. <%= refNo %></div>
        </div>
        <% if (concern != null) { %>
          <span class="badge badge-<%= String.valueOf(concern.get("STATUS")).toLowerCase().replace(" ","") %>">
            <%= concern.get("STATUS") %>
          </span>
        <% } %>
      </div>

      <div class="thread-layout">
        <!-- Messages -->
        <div class="thread-left">
          <div class="thread-msgs" id="thread-msgs">
            <% if (msgs != null && !msgs.isEmpty()) {
                for (Map<String,Object> m : msgs) {
                    String role       = String.valueOf(m.get("ROLE"));
                    String senderName = String.valueOf(m.get("SENDER_NAME"));
                    String sentAt     = String.valueOf(m.get("SENT_AT"));
                    String message    = String.valueOf(m.get("MESSAGE"));
                    boolean isStaff   = "staff".equalsIgnoreCase(role);
            %>
            <div class="msg-bubble">
              <div class="msg-sender">
                <div class="msg-av <%= isStaff ? "staff" : "student" %>">
                  <i class="fa-solid fa-user"></i>
                </div>
                <div>
                  <div class="msg-sender-name"><%= senderName %><%= isStaff ? " — Staff" : "" %></div>
                  <div class="msg-sender-time"><%= sentAt %></div>
                </div>
              </div>
              <div class="msg-text <%= isStaff ? "from-staff" : "" %>"><%= message %></div>
            </div>
            <% } } else { %>
            <div style="text-align:center;padding:48px 0;font-size:.78rem;color:rgba(255,255,255,.25);">
              No messages yet. Start the conversation below.
            </div>
            <% } %>
          </div>

          <div class="thread-reply-area">
            <textarea class="thread-input" id="reply-input"
              placeholder="Write a message to the student..."></textarea>
            <div class="thread-footer">
              <label style="display:flex;align-items:center;gap:6px;font-size:.68rem;color:rgba(255,255,255,.35);cursor:pointer;">
                <input type="checkbox" id="notify-email" checked style="accent-color:var(--yellow-nav);"/>
                Student will receive email notification
              </label>
              <button class="send-btn" onclick="sendReply()">Send Reply</button>
            </div>
          </div>
        </div>

        <!-- Right: details + edit -->
        <div class="thread-right">
          <div class="tr-section-lbl">Reference</div>
          <% if (concern != null) { %>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Ref No.</span>    <span class="msg-detail-val"><%= concern.get("ID") %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Student</span>    <span class="msg-detail-val"><%= concern.get("STUDENT_NAME") %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Assigned to</span><span class="msg-detail-val"><%= concern.get("ASSIGNED_TO") != null ? concern.get("ASSIGNED_TO") : "Pending" %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Submitted</span>  <span class="msg-detail-val"><%= concern.get("SUBMITTED_AT") %></span></div>
          <% } %>

          <!-- Edit section -->
          <div class="edit-section">
            <div class="edit-section-lbl">Edit Concern</div>

            <label class="fl" style="margin-bottom:4px;">CATEGORY</label>
            <select id="edit-cat" class="fi fi-sel" style="margin-bottom:10px;">
              <option <%= "Academic".equals(concern != null ? concern.get("CATEGORY") : "") ? "selected" : "" %>>Academic</option>
              <option <%= "Financial".equals(concern != null ? concern.get("CATEGORY") : "") ? "selected" : "" %>>Financial</option>
              <option <%= "Student Life".equals(concern != null ? concern.get("CATEGORY") : "") ? "selected" : "" %>>Student Life</option>
              <option <%= "Administrative".equals(concern != null ? concern.get("CATEGORY") : "") ? "selected" : "" %>>Administrative</option>
              <option <%= "Others".equals(concern != null ? concern.get("CATEGORY") : "") ? "selected" : "" %>>Others</option>
            </select>

            <label class="fl" style="margin-bottom:4px;">TYPE</label>
            <select id="edit-type" class="fi fi-sel" style="margin-bottom:10px;">
              <option><%= concern != null && concern.get("TYPE") != null ? concern.get("TYPE") : "Select Type" %></option>
              <option>Grade Correction Request</option>
              <option>Grade Consultation</option>
              <option>Academic Records Request</option>
              <option>Subject Enrollment Issue</option>
              <option>Scholarship Concern</option>
              <option>Tuition Concern</option>
              <option>Complaint</option>
              <option>Facilities</option>
              <option>Others</option>
            </select>

            <label class="fl" style="margin-bottom:4px;">DEPARTMENT</label>
            <select id="edit-dept" class="fi fi-sel" style="margin-bottom:10px;">
              <option <%= "Registrar Office".equals(concern != null ? concern.get("DEPARTMENT") : "") ? "selected" : "" %>>Registrar Office</option>
              <option <%= "Finance Office".equals(concern != null ? concern.get("DEPARTMENT") : "") ? "selected" : "" %>>Finance Office</option>
              <option <%= "OSA Office".equals(concern != null ? concern.get("DEPARTMENT") : "") ? "selected" : "" %>>OSA Office</option>
              <option <%= "OSAS Office".equals(concern != null ? concern.get("DEPARTMENT") : "") ? "selected" : "" %>>OSAS Office</option>
              <option <%= "Facilities Office".equals(concern != null ? concern.get("DEPARTMENT") : "") ? "selected" : "" %>>Facilities Office</option>
            </select>

            <label class="fl" style="margin-bottom:4px;">PRIORITY</label>
            <select id="edit-priority" class="fi fi-sel" style="margin-bottom:12px;">
              <option <%= "Low".equals(concern != null ? concern.get("PRIORITY") : "") ? "selected" : "" %>>Low</option>
              <option <%= "Medium".equals(concern != null ? concern.get("PRIORITY") : "") ? "selected" : "" %>>Medium</option>
              <option <%= "High".equals(concern != null ? concern.get("PRIORITY") : "") ? "selected" : "" %>>High</option>
              <option <%= "Critical".equals(concern != null ? concern.get("PRIORITY") : "") ? "selected" : "" %>>Critical</option>
            </select>

            <label class="fl" style="margin-bottom:6px;">STATUS</label>
            <div class="status-btns">
              <button class="sts-btn <%= "Pending".equals(concern != null ? concern.get("STATUS") : "") ? "on" : "" %>"
                data-val="Pending" onclick="setStatus('Pending',this)">Pending</button>
              <button class="sts-btn <%= "In Progress".equals(concern != null ? concern.get("STATUS") : "") ? "on" : "" %>"
                data-val="In Progress" onclick="setStatus('In Progress',this)">In Progress</button>
              <button class="sts-btn <%= "Closed".equals(concern != null ? concern.get("STATUS") : "") ? "on" : "" %>"
                data-val="Closed" onclick="setStatus('Closed',this)">Closed</button>
            </div>
            <input type="hidden" id="status-val" value="<%= concern != null ? concern.get("STATUS") : "Pending" %>"/>

            <button class="mark-closed-btn" style="margin-top:8px;"
              onclick="document.querySelectorAll('.sts-btn').forEach(b=>b.classList.remove('on'));document.getElementById('status-val').value='Closed';">
              → Mark as Closed
            </button>

            <button class="save-changes-btn" onclick="saveChanges()">
              <i class="fa-solid fa-floppy-disk" style="margin-right:5px;"></i>Save Changes
            </button>
          </div>
        </div><!-- /thread-right -->
      </div><!-- /thread-layout -->
    </div><!-- /thread-card -->

  </div><!-- /thread-page-wrap -->
</div><!-- /page-wrap -->

<script>
function toggleDropdown() { document.getElementById('user-dropdown').classList.toggle('show'); }
document.addEventListener('click', e => {
  if (!e.target.closest('.nav-user') && !e.target.closest('#user-dropdown'))
    document.getElementById('user-dropdown').classList.remove('show');
});

function sendReply() {
  const input = document.getElementById('reply-input');
  const msg   = input.value.trim();
  if (!msg) return;
  fetch('SendMessageServlet', {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: 'ref=<%= refNo %>&message=' + encodeURIComponent(msg)
  })
  .then(r => r.json())
  .then(() => { input.value = ''; window.location.reload(); })
  .catch(() => alert('Failed to send.'));
}

function setStatus(val, btn) {
  document.querySelectorAll('.sts-btn').forEach(b => b.classList.remove('on'));
  btn.classList.add('on');
  document.getElementById('status-val').value = val;
}

function saveChanges() {
  fetch('UpdateConcernServlet', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify({
      ref:      '<%= refNo %>',
      category: document.getElementById('edit-cat').value,
      type:     document.getElementById('edit-type').value,
      dept:     document.getElementById('edit-dept').value,
      priority: document.getElementById('edit-priority').value,
      status:   document.getElementById('status-val').value
    })
  })
  .then(() => {
    window.location.href = 'ManagerDashboardServlet';
  })
  .catch(() => alert('Failed to save changes.'));
}

(function() {
  const t = document.getElementById('thread-msgs');
  if (t) t.scrollTop = t.scrollHeight;
})();
</script>
</body>
</html>