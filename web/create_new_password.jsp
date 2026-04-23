<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Set New Password | TIP-SC</title>

<jsp:include page="auth_header.jspf" />

</head>

<body class="auth-body">

<div class="card">

    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <h1 class="title sm">SET NEW PASSWORD</h1>
    <p class="sub">Your password must be strong and secure.</p>

    <% String err = (String) request.getAttribute("passwordError"); %>
    <% if (err != null) { %>
        <div class="warn">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <%= err %>
        </div>
    <% } %>

    <form action="ChangePasswordServlet" method="post">

        <label class="lbl">NEW PASSWORD</label>
        <div class="iw no-icon">
            <input type="password" name="new_password" required>
        </div>
        
        <div class="sw" id="strengthBox">
            <div class="slbl weak" id="strengthLabel">Weak Password</div>
            <div class="sbar">
                <div class="sfill weak" id="strengthFill"></div>
            </div>
        </div>

        <div class="pwmatch" id="matchText">Passwords do not match</div>

        <label class="lbl">CONFIRM PASSWORD</label>
        <div class="iw no-icon">
            <input type="password" name="confirm_password" required>
        </div>

        <button class="btn btn-y" type="submit">
            SAVE PASSWORD
        </button>

    </form>

</div>

</body>
</html>

<script>
const pw1 = document.querySelector("input[name='new_password']");
const pw2 = document.querySelector("input[name='confirm_password']");
const box = document.getElementById("strengthBox");
const label = document.getElementById("strengthLabel");
const fill = document.getElementById("strengthFill");
const match = document.getElementById("matchText");

function checkStrength(pw){
    let score = 0;

    if (pw.length >= 8) score++;
    if (/[A-Za-z]/.test(pw)) score++;
    if (/\d/.test(pw)) score++;
    if (/[@$!%*?&^#()_+=\-]/.test(pw)) score++;

    return score;
}

pw1.addEventListener("input", () => {
    let score = checkStrength(pw1.value);

    box.style.display = "block";

    if (score <= 2) {
        label.textContent = "Weak Password";
        label.className = "slbl weak";
        fill.className = "sfill weak";
    } else {
        label.textContent = "Strong Password";
        label.className = "slbl strong";
        fill.className = "sfill strong";
    }
});

pw2.addEventListener("input", () => {
    if (pw1.value !== pw2.value) {
        match.style.display = "block";
    } else {
        match.style.display = "none";
    }
});
</script>