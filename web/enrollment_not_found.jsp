<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Enrollment Not Found | TIP-SC</title>

<jsp:include page="auth_header.jspf" />
</head>

<body class="auth-body">

<div class="card sc">

    <div class="sico red">
        <i class="fa-solid fa-xmark"></i>
    </div>

    <div class="stitle">RECORD NOT FOUND</div>

    <div class="sbody">
        We could not find your enrollment record in the system.
        Please ensure your details match your school records.
    </div>

    <a href="register.jsp" class="btn btn-y">TRY AGAIN</a>

</div>

</body>
</html>