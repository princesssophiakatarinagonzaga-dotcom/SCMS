<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Forgot Temporary Password | TIP-SC</title>
<jsp:include page="auth_header.jspf" />
</head>

<body class="auth-body">

<div class="card">

  <div class="logo">
    <div class="logo-dot"></div>
    <span class="logo-name">TIP-SC</span>
  </div>
    
  <a href="login.jsp" class="back">
    <i class="fa-solid fa-arrow-left"></i> Back to Sign In
  </a>

  <div class="title sm">FORGOT TEMPORARY PASSWORD</div>

  <p class="sub">Enter your school email to receive a verification code.</p>

  <% if ("notfound".equals(request.getParameter("error"))) { %>
  <div class="warn">
      <i class="fa-solid fa-triangle-exclamation"></i>
      No account found with that email address.
  </div>
  <% } %>

  <% if ("active".equals(request.getParameter("info"))) { %>
  <div class="warn">
      <i class="fa-solid fa-circle-info"></i>
      Temporary password is not required for this account.
  </div>
  <% } %>
  
  <form action="ResendTempPasswordServlet" method="post">

    <div class="f">
      <label class="lbl">SCHOOL EMAIL</label>
      <div class="iw">
        <i class="fa-solid fa-envelope ico"></i>
        <input type="email" name="email" required>
      </div>
    </div>

    <button class="btn btn-y" type="submit">SEND VERIFICATION CODE</button>

  </form>

</div>

</body>
</html>