<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Integer roleId = (Integer) session.getAttribute("role_id");
if (roleId == null || roleId != 1) {
    response.sendRedirect("login.jsp");
    return;
}

// These attributes set by SubmitConcernServlet after successful insert
String refNo    = (String) request.getAttribute("refNo");
String category = (String) request.getAttribute("category");
String type     = (String) request.getAttribute("type");
String dept     = (String) request.getAttribute("department");
String title    = (String) request.getAttribute("title");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>TIP-SC | Concern Submitted</title>
<jsp:include page="auth_header.jspf" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
  <div class="nav-user">
    <div class="nav-avatar"><i class="fa-solid fa-user"></i></div>
    <span class="nav-uname"><%= session.getAttribute("fullName") %></span>
  </div>
</nav>

<div class="page-wrap" style="display:flex;align-items:center;justify-content:center;min-height:100vh;">

  <!-- Blurred dashboard behind -->
  <div class="sub-modal" style="max-width:500px;">
    <div class="sub-modal-close-row">
      <a href="StudentDashboardServlet" style="background:none;border:none;color:rgba(255,255,255,.4);font-size:1rem;text-decoration:none;">
        <i class="fa-solid fa-xmark"></i>
      </a>
    </div>

    <div class="sub-modal-icon">
      <i class="fa-solid fa-check"></i>
    </div>

    <div class="sub-modal-title">Concern submitted successfully!</div>

    <div class="sub-modal-sub">
      Your concern has been received and is currently under review.
      You will be notified via your student email once a response is available.
    </div>

    <div class="sub-detail-card">
      <div class="sub-dr">
        <span class="sub-dl">Reference No.</span>
        <span class="sub-dv"><%= refNo != null ? refNo : "SCM-" + System.currentTimeMillis() %></span>
      </div>
      <div class="sub-dr">
        <span class="sub-dl">Category</span>
        <span class="sub-dv"><%= category != null ? category : "—" %></span>
      </div>
      <div class="sub-dr">
        <span class="sub-dl">Type</span>
        <span class="sub-dv"><%= type != null ? type : "—" %></span>
      </div>
      <div class="sub-dr">
        <span class="sub-dl">Assigned to</span>
        <span class="sub-dv"><%= dept != null ? dept : "—" %></span>
      </div>
      <div class="sub-dr">
        <span class="sub-dl">Status</span>
        <span class="sub-dv">
          <span class="badge badge-pending">Pending</span>
        </span>
      </div>
    </div>

    <div class="sub-modal-note">
      A confirmation has been sent to your TIP student email.<br>
      Keep your reference number for follow-ups.
    </div>

    <a href="StudentDashboardServlet" class="sub-modal-btn" style="text-decoration:none;display:block;text-align:center;">
      View My Concerns
    </a>
  </div>

</div>
</body>
</html>