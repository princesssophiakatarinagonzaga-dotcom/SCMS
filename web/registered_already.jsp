<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Already Registered | TIP-SC</title>

<jsp:include page="auth_header.jspf" />
</head>

<body class="auth-body">

<div class="card sc">

    <div class="sico yellow">
        <i class="fa-solid fa-circle-info"></i>
    </div>

    <div class="stitle">ALREADY REGISTERED</div>

    <div class="sbody">
        This email is already associated with an existing account.
        Please proceed to sign in instead.
    </div>

    <a href="login.jsp" class="btn btn-y">GO TO SIGN IN</a>

</div>

</body>
</html>