<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Integer roleId = (Integer) session.getAttribute("role_id");
if (roleId == null || roleId != 1) {
    response.sendRedirect("login.jsp");
    return;
}

String fullName = (String) session.getAttribute("fullName");
String refNo    = request.getParameter("ref");

// Concern details set by GetConcernServlet
Map<String, Object> concern  = (Map<String, Object>)  request.getAttribute("concern");
List<Map<String,Object>> msgs = (List<Map<String,Object>>) request.getAttribute("messages");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>TIP-SC | Updates — <%= refNo %></title>
<jsp:include page="auth_header.jspf" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
.thread-page-wrap {
  max-width: 900px; margin: 0 auto;
  padding: 20px 20px 40px;
}
.thread-back {
  display: inline-flex; align-items: center; gap: 7px;
  color: #555; font-size: .8rem; font-weight: 600;
  text-decoration: none; margin-bottom: 14px;
  transition: color .15s;
}
.thread-back:hover { color: #111; }
.thread-card {
  background: #252525; border-radius: 16px;
  overflow: hidden; box-shadow: 0 8px 40px rgba(0,0,0,.35);
}
.thread-header {
  background: #1E1E1E; padding: 18px 22px;
  border-bottom: 1px solid var(--border-dark);
  display: flex; align-items: flex-start; justify-content: space-between;
}
.thread-header-left {}
.thread-header-title { font-weight: 800; font-size: .92rem; letter-spacing: .06em; color: #fff; margin-bottom: 3px; }
.thread-header-ref   { font-size: .7rem; color: var(--text-dw); }

.thread-layout { display: grid; grid-template-columns: 1fr 260px; min-height: 480px; }

.thread-left  { padding: 20px; display: flex; flex-direction: column; }
.thread-msgs  { flex: 1; overflow-y: auto; margin-bottom: 16px; max-height: 380px; }

.thread-reply-area { border-top: 1px solid var(--border-dark); padding-top: 16px; }
.thread-input {
  width: 100%; background: #2E2E2E; border: 1px solid var(--border-dark);
  border-radius: 8px; padding: 11px 14px;
  font-family: var(--fb); font-size: .8rem; color: #fff;
  outline: none; resize: none; height: 75px; transition: border-color .15s;
}
.thread-input:focus { border-color: rgba(200,168,0,.5); }
.thread-input::placeholder { color: rgba(255,255,255,.25); }
.thread-footer {
  display: flex; align-items: center; justify-content: space-between; margin-top: 10px;
}
.thread-note {
  font-size: .68rem; color: rgba(255,255,255,.3);
  display: flex; align-items: center; gap: 5px;
}

.thread-right {
  background: #1E1E1E; border-left: 1px solid var(--border-dark);
  padding: 20px; overflow-y: auto;
}
.tr-section-lbl {
  font-size: .65rem; font-weight: 700; letter-spacing: .06em;
  color: var(--text-dw); margin-bottom: 12px; text-transform: uppercase;
}
</style>
</head>

<body class="dash-body">

<nav class="navbar">
  <div class="nav-logo">
    <div class="nav-logo-dot"></div>
    <span class="nav-logo-name">TIP-SC</span>
  </div>
  <div class="nav-center">
    <a href="StudentDashboardServlet" class="nav-btn outline" style="text-decoration:none;">View Concerns</a>
    <a href="StudentDashboardServlet?page=submit" class="nav-btn dark" style="text-decoration:none;">Submit Concern</a>
  </div>
  <div class="nav-user" onclick="toggleDropdown()">
    <div class="nav-avatar"><i class="fa-solid fa-user"></i></div>
    <span class="nav-uname"><%= fullName %></span>
  </div>
</nav>

<div class="user-dropdown" id="user-dropdown">
  <div class="ud-header">
    <div class="ud-name"><%= fullName %></div>
    <div class="ud-prog"><%= session.getAttribute("program") %></div>
  </div>
  <div class="ud-items">
    <button class="ud-item" onclick="window.location.href='StudentDashboardServlet'">
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

    <a href="StudentDashboardServlet" class="thread-back">
      <i class="fa-solid fa-chevron-left"></i> Back to My Concerns
    </a>

    <div class="thread-card">
      <div class="thread-header">
        <div class="thread-header-left">
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
            <%
            if (msgs != null && !msgs.isEmpty()) {
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
            <div style="text-align:center;padding:40px 0;font-size:.78rem;color:rgba(255,255,255,.25);">
              No messages yet. Your concern is being reviewed.
            </div>
            <% } %>
          </div>

          <div class="thread-reply-area">
            <textarea class="thread-input" id="reply-input"
              placeholder="Write a follow-up message or provide additional information..."></textarea>
            <div class="thread-footer">
              <span class="thread-note">
                <i class="fa-regular fa-envelope"></i>
                You'll receive an email when staff responds
              </span>
              <button class="send-btn" onclick="sendReply()">Send Reply</button>
            </div>
          </div>
        </div>

        <!-- Details sidebar -->
        <div class="thread-right">
          <div class="tr-section-lbl">Reference</div>
          <% if (concern != null) { %>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Ref No.</span>     <span class="msg-detail-val"><%= concern.get("ID") %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Category</span>   <span class="msg-detail-val"><%= concern.get("CATEGORY") %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Type</span>        <span class="msg-detail-val"><%= concern.get("TYPE") %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Assigned to</span><span class="msg-detail-val"><%= concern.get("ASSIGNED_TO") != null ? concern.get("ASSIGNED_TO") : "Pending" %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Status</span>
            <span class="msg-detail-val">
              <span class="badge badge-<%= String.valueOf(concern.get("STATUS")).toLowerCase().replace(" ","") %>"><%= concern.get("STATUS") %></span>
            </span>
          </div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Department</span> <span class="msg-detail-val"><%= concern.get("DEPARTMENT") %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Submitted</span>  <span class="msg-detail-val"><%= concern.get("SUBMITTED_AT") %></span></div>
          <div class="msg-detail-row"><span class="msg-detail-lbl">Priority</span>
            <span class="msg-detail-val">
              <span class="badge badge-<%= String.valueOf(concern.get("PRIORITY")).toLowerCase() %>"><%= concern.get("PRIORITY") %></span>
            </span>
          </div>
          <% } %>
        </div>
      </div><!-- /thread-layout -->
    </div><!-- /thread-card -->

  </div><!-- /thread-page-wrap -->
</div><!-- /page-wrap -->

<script>
function toggleDropdown() {
  document.getElementById('user-dropdown').classList.toggle('show');
}
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
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'ref=<%= refNo %>&message=' + encodeURIComponent(msg)
  })
  .then(r => r.json())
  .then(() => {
    input.value = '';
    window.location.reload();   // Reload to show new message from DB
  })
  .catch(() => alert('Failed to send. Please try again.'));
}

// Scroll to bottom of thread
(function() {
  const t = document.getElementById('thread-msgs');
  if (t) t.scrollTop = t.scrollHeight;
})();
</script>
</body>
</html>