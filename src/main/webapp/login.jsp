<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>AKA Attendance - Login</title>

<style>
body {
    font-family: 'Segoe UI', sans-serif;
    background-color: #e9ecef;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
}
.login-box {
    background: white;
    padding: 40px;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    width: 320px;
    text-align: center;
}
input {
    width: 100%;
    padding: 12px;
    margin: 10px 0;
    border: 1px solid #ddd;
    border-radius: 4px;
}
button {
    width: 100%;
    padding: 12px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
}
button:hover {
    background-color: #0056b3;
}
.error {
    color: red;
    margin-top: 10px;
    font-size: 14px;
    display: none;
}
</style>

<!-- Firebase SDKs -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<div class="login-box">
    <h2>System Login</h2>
    <input type="email" id="email" placeholder="Email">
    <input type="password" id="password" placeholder="Password">
    <button type="button" onclick="handleLogin()">Sign In</button>
    <div id="error-msg" class="error"></div>
</div>

<script>
/* 🔥 FIREBASE CONFIG (NO STORAGE) */
const firebaseConfig = {
    apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
    authDomain: "attendencewebapp-4215b.firebaseapp.com",
    projectId: "attendencewebapp-4215b"
};

firebase.initializeApp(firebaseConfig);

const auth = firebase.auth();
const db = firebase.firestore();

/* LOGIN */
function handleLogin() {
    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value.trim();
    const errorDiv = document.getElementById("error-msg");

    errorDiv.style.display = "none";

    if (!email || !password) {
        errorDiv.innerText = "Please enter email and password.";
        errorDiv.style.display = "block";
        return;
    }

    auth.signInWithEmailAndPassword(email, password)
        .then((cred) => {
            const user = cred.user;
            loadUserProfile(user);
        })
        .catch((error) => {
            errorDiv.innerText = error.message;
            errorDiv.style.display = "block";
        });
}

/* LOAD OR AUTO-CREATE USER PROFILE */
function loadUserProfile(user) {
    const uid = user.uid;

    db.collection("users").doc(uid).get()
        .then((doc) => {

            // ✅ PROFILE EXISTS
            if (doc.exists) {
                const data = doc.data();

                if (data.isActive === false) {
                    alert("Your account is disabled.");
                    auth.signOut();
                    return;
                }

                if (data.role === "admin") {
                    window.location.href = "admin_dashboard.jsp";
                } else {
                    window.location.href = "mark_attendance.jsp";
                }
            }

            // 🔥 PROFILE DOES NOT EXIST → AUTO CREATE
            else {
                db.collection("users").doc(uid).set({
                    email: user.email,
                    role: "employee",     // default role
                    isActive: true,
                    createdAt: firebase.firestore.FieldValue.serverTimestamp()
                }).then(() => {
                    window.location.href = "mark_attendance.jsp";
                });
            }

        })
        .catch((error) => {
            console.error(error);
            alert("Error loading user profile.");
        });
}
</script>

</body>
</html>

