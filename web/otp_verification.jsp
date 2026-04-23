<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>OTP Verification | TIP-SC</title>
<jsp:include page="auth_header.jspf" />
</head>
<body class="auth-body">

<div class="card sc">

    <div class="logo" style="justify-content:center;">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <div class="sico yellow" style="margin-bottom:12px;">
        <i class="fa-solid fa-envelope"></i>
    </div>

    <div class="stitle">Verify your school email.</div>

    <div class="sbody">
        A 6-digit verification code was sent to<br>
        <strong style="color:var(--text-black); font-size:0.88rem;">
            <%= session.getAttribute("otpEmail") %>
        </strong>
    </div>

    <%
        String err = (String) request.getAttribute("otpError");
        String resent = request.getParameter("resent");
        String cooldown = request.getParameter("cooldown");
    %>

    <div class="warn" style="text-align:left;">
        <i class="fa-solid fa-triangle-exclamation"></i>
        <span id="warnMsg">
            <% if (err != null) { %>
                Invalid or expired code. Request a<br>new one and try again.
            <% } else { %>
                This code expires in 10 minutes. Do not<br>share it with anyone.
            <% } %>
        </span>
    </div>

    <% if ("true".equals(resent)) { %>
    <div style="text-align:center; font-size:0.75rem; color:var(--text-green); margin-bottom:8px;">
        <i class="fa-solid fa-check"></i> New code sent to your email.
    </div>
    <% } %>

    <% if ("true".equals(cooldown)) { %>
    <div style="text-align:center; font-size:0.75rem; color:var(--text-red); margin-bottom:8px;">
        Please wait 30 seconds before resending.
    </div>
    <% } %>

    <form action="VerifyOTPServlet" method="post" id="otpForm">

        <label class="lbl" style="text-align:center; display:block; margin-bottom:8px;">
            ENTER VERIFICATION CODE:
        </label>

        <div class="otp-row">
            <input class="obox" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="o1" autofocus>
            <input class="obox" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="o2">
            <input class="obox" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="o3">
            <input class="obox" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="o4">
            <input class="obox" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="o5">
            <input class="obox" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="o6">
        </div>

        <!-- Hidden combined OTP field -->
        <input type="hidden" name="otp" id="otpHidden">

        <button class="btn btn-y" type="submit">Verify Code</button>

    </form>

    <div class="rrow">
        <form action="ResendOTPServlet" method="post">
            <button type="submit" class="rlink" style="background:none;border:none;padding:0;">
                Didn't receive it? Resend code
            </button>
        </form>
        <span class="max">Max 3 resend per hour</span>
    </div>

</div>

<script>
const boxes = [
    document.getElementById('o1'),
    document.getElementById('o2'),
    document.getElementById('o3'),
    document.getElementById('o4'),
    document.getElementById('o5'),
    document.getElementById('o6')
];

boxes.forEach((box, i) => {
    box.addEventListener('input', () => {
        // Only allow digits
        box.value = box.value.replace(/[^0-9]/g, '');
        if (box.value && i < 5) boxes[i + 1].focus();
    });

    box.addEventListener('keydown', (e) => {
        if (e.key === 'Backspace' && !box.value && i > 0) {
            boxes[i - 1].focus();
        }
    });

    box.addEventListener('paste', (e) => {
        e.preventDefault();
        const pasted = e.clipboardData.getData('text').replace(/[^0-9]/g, '');
        pasted.split('').forEach((char, idx) => {
            if (boxes[idx]) boxes[idx].value = char;
        });
        const next = Math.min(pasted.length, 5);
        boxes[next].focus();
    });
});

document.getElementById('otpForm').addEventListener('submit', (e) => {
    const combined = boxes.map(b => b.value).join('');
    if (combined.length < 6) {
        e.preventDefault();
        alert('Please enter all 6 digits.');
        return;
    }
    document.getElementById('otpHidden').value = combined;
});
</script>

</body>
</html>