<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
/* ===========================
   SESSION VALIDATION BLOCK
   =========================== */

// Get existing session (do NOT create new one)
HttpSession s = request.getSession(false);

// If no session → force login
if (s == null) {
    response.sendRedirect("login.jsp");
    return;
}

/* Debug logs (server-side only) */
System.out.println("SUCCESS PAGE LOADED");
System.out.println("ROLE ID: " + s.getAttribute("role_id"));
System.out.println("SUCCESS FLAG: " + s.getAttribute("passwordChangeSuccess"));

/* Check if password update was successful */
Boolean success = (Boolean) s.getAttribute("passwordChangeSuccess");

/* ===========================
   AUTO REDIRECT LOGIC AFTER SUCCESS
   =========================== */
if (Boolean.TRUE.equals(success)) {

    // Remove flag so refresh won’t re-trigger redirect
    s.removeAttribute("passwordChangeSuccess");

    Integer roleId = (Integer) s.getAttribute("role_id");

    // If role missing → force login
    if (roleId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Role-based redirect after password change
    if (roleId == 1) {
        response.sendRedirect("student_dashboard.jsp");
    } else if (roleId == 2) {
        response.sendRedirect("manager_dashboard.jsp");
    } else if (roleId == 3) {
        response.sendRedirect("admin_dashboard.jsp");
    } else {
        response.sendRedirect("login.jsp");
    }

    return;
}
%>

<!-- ===========================
     SUCCESS UI DISPLAY
     =========================== -->
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Password Updated | TIP-SC</title>

<jsp:include page="auth_header.jspf" />

<!-- Auto redirect fallback (client-side) -->
<meta http-equiv="refresh" content="3; url=login.jsp">

</head>

<body class="auth-body">

<!-- SUCCESS CARD UI -->
<div class="card sc">

    <div class="sico green">
        <i class="fa-solid fa-lock"></i>
    </div>

    <div class="stitle">PASSWORD UPDATED</div>

    <div class="sbody">
        Your password has been successfully updated.
        You can now log in using your new credentials.

        <div class="sbody">
            Redirecting to login in 3 seconds...
        </div>
    </div>

    <a href="login.jsp" class="btn btn-y">SIGN IN NOW</a>

</div>

</body>
</html>