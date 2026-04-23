<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Sign In | TIP-SC</title>
  <jsp:include page="auth_header.jspf" />
  
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

  
  
</head>
<body class="auth-body">

<%
  // Handle sign-out via ?signout=true
  if ("true".equals(request.getParameter("signout"))) {
      HttpSession so = request.getSession(false);
      if (so != null) so.invalidate();
      response.sendRedirect("login.jsp");
      return;
  }
  
  HttpSession existingSession = request.getSession(false);
  String errorMsg    = null;
  String redirectMsg = null;
  String redirectDest = null;

  if (existingSession != null) {
      errorMsg     = (String) existingSession.getAttribute("loginError");
      redirectMsg  = (String) existingSession.getAttribute("loginRedirectMsg");
      redirectDest = (String) existingSession.getAttribute("loginRedirectDest");

      existingSession.removeAttribute("loginError");
      existingSession.removeAttribute("loginRedirectMsg");
      existingSession.removeAttribute("loginRedirectDest");

      if (existingSession.getAttribute("user_id") == null) {
          existingSession.invalidate();
      }
  }
%>

<div class="screen active">
  <div class="card">
    <div class="logo">
      <div class="logo-dot"></div>
      <span class="logo-name">TIP-SC</span>
    </div>
      
    <h1 class="title">SIGN IN</h1>
    <p class="sub">Sign in with your institutional account.</p>

    <%-- Normal error — stays on page --%>
    <% if (errorMsg != null) { %>
    <div class="warn">
      <i class="fa-solid fa-triangle-exclamation"></i>
      <%= errorMsg %>
    </div>
    
    <% } %>
    <%-- Redirecting message — auto-navigates after 2s --%>
    <% if (redirectMsg != null) { %>
    <div class="warn" style="background:rgba(255,213,0,0.12); border-color:var(--tip-yellow);"
         id="redirectBanner">
      <i class="fa-solid fa-rotate-right fa-spin"></i>
      <%= redirectMsg %>
    </div>
    <script>
      setTimeout(function() {
          window.location.href = "<%= redirectDest %>";
      }, 2000);
    </script>
    <% } %>

    <form action="LoginServlet" method="post">
      <div class="f">
        <label class="lbl">SCHOOL EMAIL <span class="req">*</span></label>
        <div class="iw">
          <i class="fa-solid fa-envelope ico"></i>
          <input type="email" name="email" required>
        </div>
      </div>
      <div class="f">
        <label class="lbl">PASSWORD <span class="req">*</span></label>
        <div class="iw" style="position:relative;">
          <i class="fa-solid fa-lock ico"></i>
          <input type="password" name="password" id="passwordInput" required>
          <button type="button" onclick="togglePassword()"
            style="position:absolute;right:12px;top:50%;transform:translateY(-50%);
                   background:none;border:none;cursor:pointer;
                   color:rgba(255,255,255,0.45);font-size:.85rem;padding:0;">
            <i class="fa-solid fa-eye" id="eyeIcon"></i>
          </button>
        </div>
      </div>
      <button class="btn btn-y" type="submit">SIGN IN</button>
    </form>

    <div class="links">
      <a href="register.jsp">Haven't registered yet?</a>
      <a href="forgot_password.jsp">Forgot Password?</a>
    </div>
    
    <div class="links">
        <a href="forgot_temp_password.jsp">Forgot Temporary Password?</a>
    </div>
    
    <div class="foot-version">
      @2026 TIP-MANILA SCMS v1.0
    </div>
  </div>
</div>

<script>
function togglePassword() {
  const input = document.getElementById('passwordInput');
  const icon  = document.getElementById('eyeIcon');
  if (input.type === 'password') {
    input.type     = 'text';
    icon.className = 'fa-solid fa-eye-slash';
  } else {
    input.type     = 'password';
    icon.className = 'fa-solid fa-eye';
  }
}
</script>
</body>
</html>