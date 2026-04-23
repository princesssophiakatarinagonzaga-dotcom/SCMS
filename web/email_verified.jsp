<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Email Verified | TIP-SC</title>
<jsp:include page="auth_header.jspf" />
</head>
<body class="auth-body">

<div class="card sc">

    <div class="logo" style="justify-content:center;">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <div class="sico green">
        <i class="fa-solid fa-check"></i>
    </div>

    <div class="stitle">Email verified!</div>

    <div class="sbody">
        Your account has been created. You can<br>
        now request your temporary password<br>
        to sign in for the first time.
    </div>

    <div class="vrow" style="justify-content:space-between; margin-bottom:18px;">
        <span style="font-size:0.78rem; color:var(--text-mid);">
            <i class="fa-solid fa-id-card" style="margin-right:5px;"></i>
            <%= session.getAttribute("otpSchoolId") %>
        </span>
        <span style="font-size:0.78rem; color:var(--text-mid);">
            <i class="fa-solid fa-envelope" style="margin-right:5px;"></i>
            <%= session.getAttribute("otpEmail") %>
        </span>
    </div>

    <form action="SendTemporaryPasswordServlet" method="post">
        <button class="btn btn-y" type="submit">GET TEMPORARY PASSWORD</button>
    </form>

</div>

</body>
</html>