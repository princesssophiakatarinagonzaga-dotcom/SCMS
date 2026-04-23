<%@ page contentType="text/html;charset=UTF-8" %>
<%
    HttpSession s = request.getSession(false);
    if (s == null || !Boolean.TRUE.equals(s.getAttribute("forceChange"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Set New Password | TIP-SC</title>
<jsp:include page="auth_header.jspf" />
</head>
<body class="auth-body">

<div class="card sc">

    <div class="sico yellow">
        <i class="fa-solid fa-key"></i>
    </div>

    <div class="stitle">First time signing in?</div>

    <div class="sbody">
        You signed in with a temporary password.<br>
        You must set a permanent password to continue.
    </div>

    <a href="create_new_password.jsp" class="btn btn-y">CONTINUE TO SET NEW PASSWORD</a>

</div>

</body>
</html>