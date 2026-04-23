<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Temporary Password Sent | TIP-SC</title>
<jsp:include page="auth_header.jspf" />
</head>
<body class="auth-body">

<div class="card sc">

    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <div class="sico green">
        <i class="fa-solid fa-envelope-circle-check"></i>
    </div>

    <div class="stitle">Temporary password sent!</div>

    <div class="sbody">
        Check your inbox at<br>
        <strong style="color:var(--text-black);">
            <%= request.getAttribute("sentEmail") != null
                ? request.getAttribute("sentEmail")
                : "" %>
        </strong>
    </div>

    <ul class="blist">
        <li>Didn't receive it? Check your Spam or Junk folder.</li>
        <li>Your temp password expires in 10 minutes and is valid for one sign-in only.</li>
        <li>You'll be prompted to set a permanent password on first login.</li>
    </ul>

    <a href="login.jsp" class="btn btn-y">BACK TO SIGN IN</a>

</div>

</body>
</html>