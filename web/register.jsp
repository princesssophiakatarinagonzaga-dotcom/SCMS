<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Register | TIP-SC</title>

<jsp:include page="auth_header.jspf" />

</head>

<body class="auth-body">

<div class="card wide">

    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <a href="login.jsp" class="back">
        <i class="fa-solid fa-arrow-left"></i> Back to Sign In
    </a>

    <h1 class="title md">REGISTER AN ACCOUNT</h1>
    <p class="sub">Fill in the details exactly as they appear on your records.</p>

    <div class="role-lbl">ROLE:</div>

    <div class="role-tabs">
        <button type="button" class="rtab on" id="tab-student" onclick="setRole('student')">
            <i class="fa-solid fa-graduation-cap"></i> STUDENT
        </button>

        <button type="button" class="rtab" id="tab-manager" onclick="setRole('manager')">
            <i class="fa-solid fa-clipboard-list"></i> MANAGER
        </button>

        <button type="button" class="rtab" id="tab-admin" onclick="setRole('admin')">
            <i class="fa-solid fa-desktop"></i> ADMIN
        </button>
    </div>

    <form action="RegisterServlet" method="post">

        <input type="hidden" name="role" id="selectedRole" value="STUDENT">

        <!-- STUDENT -->
        <div id="fields-student">
            <div class="g3">

                <div class="f">
                    <label class="lbl">LAST NAME *</label>
                    <div class="iw no-icon">
                        <input name="last_name" required>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">FIRST NAME *</label>
                    <div class="iw no-icon">
                        <input name="first_name" required>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">CAMPUS *</label>
                    <div class="iw no-icon">
                        <select name="campus" required>
                            <option value="">Select</option>
                            <option value="MNL">Manila</option>
                            <option value="QC">Quezon City</option>
                        </select>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">STUDENT ID *</label>
                    <div class="iw no-icon">
                        <input name="school_id" required>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">SCHOOL EMAIL *</label>
                    <div class="iw no-icon">
                        <input type="email" name="email" required>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">PROGRAM</label>
                    <div class="iw no-icon">
                        <select name="program" required>
                            <option value="">Select Program</option>
                            <option value="BS Information Technology">BSIT</option>
                            <option value="BS Computer Science">BSCS</option>
                            <option value="BS Civil Engineering">BSCE</option>
                        </select>
                    </div>
                </div>

            </div>
        </div>

        <!-- MANAGER -->
        <div id="fields-manager" style="display:none">
            <div class="g3">

                <div class="f">
                    <label class="lbl">LAST NAME *</label>
                    <div class="iw no-icon"><input name="last_name" required></div>
                </div>

                <div class="f">
                    <label class="lbl">FIRST NAME *</label>
                    <div class="iw no-icon"><input name="first_name" required></div>
                </div>

                <div class="f">
                    <label class="lbl">CAMPUS *</label>
                    <div class="iw no-icon">
                        <select name="campus" required>
                            <option value="">Select</option>
                            <option value="MNL">Manila</option>
                            <option value="QC">Quezon City</option>
                        </select>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">EMPLOYEE ID *</label>
                    <div class="iw no-icon"><input name="school_id" required></div>
                </div>

                <div class="f">
                    <label class="lbl">EMAIL *</label>
                    <div class="iw no-icon"><input type="email" name="email" required></div>
                </div>

                <div class="f">
                    <label class="lbl">DEPARTMENT *</label>
                    <div class="iw no-icon">
                        <select name="department" required>
                            <option value="">Select Department</option>
                            <option value="IT Services">IT Services</option>
                            <option value="Administration">Administration</option>
                        </select>
                    </div>
                </div>

            </div>
        </div>

        <!-- ADMIN -->
        <div id="fields-admin" style="display:none">
            <div class="g3">

                <div class="f">
                    <label class="lbl">LAST NAME *</label>
                    <div class="iw no-icon"><input name="last_name" required></div>
                </div>

                <div class="f">
                    <label class="lbl">FIRST NAME *</label>
                    <div class="iw no-icon"><input name="first_name" required></div>
                </div>

                <div class="f">
                    <label class="lbl">CAMPUS *</label>
                    <div class="iw no-icon">
                        <select name="campus" required>
                            <option value="">Select</option>
                            <option value="MNL">Manila</option>
                            <option value="QC">Quezon City</option>
                        </select>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">EMPLOYEE ID *</label>
                    <div class="iw no-icon"><input name="school_id" required></div>
                </div>

                <div class="f s2">
                    <label class="lbl">EMAIL *</label>
                    <div class="iw no-icon"><input type="email" name="email" required></div>
                </div>

            </div>
        </div>

        <button type="submit" class="btn btn-y">VERIFY AND CONTINUE</button>

    </form>
</div>

</body>
</html>

<script>
function setRole(role){
    document.getElementById("selectedRole").value = role.toUpperCase();

    ["student","manager","admin"].forEach(r=>{
        const isActive = (r === role);

        document.getElementById("tab-"+r).classList.toggle("on", isActive);
        document.getElementById("fields-"+r).style.display = isActive ? "" : "none";

        // 🔥 Enable only active section inputs
        document.querySelectorAll("#fields-"+r+" input, #fields-"+r+" select")
            .forEach(el => el.disabled = !isActive);
    });
}

// Initialize correctly on page load
window.onload = function() {
    setRole("student");
};
</script>