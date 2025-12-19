<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Settings - emPower</title>

<style>
body {
  font-family: Arial, sans-serif;
  background:#f4f6f9;
  margin:0;
  display:flex;
}

/* SIDEBAR */
.sidebar {
  width:220px;
  background:#343a40;
  color:white;
  min-height:100vh;
}
.sidebar a {
  display:block;
  padding:15px;
  color:#ccc;
  text-decoration:none;
}
.sidebar a.active, .sidebar a:hover {
  background:#495057;
  color:#fff;
}

/* MAIN */
.main {
  flex:1;
}
.header {
  background:white;
  padding:15px 25px;
  display:flex;
  justify-content:space-between;
  border-bottom:1px solid #ddd;
}
.content {
  padding:25px;
}

.card {
  background:white;
  padding:20px;
  margin-bottom:20px;
  border-radius:6px;
  width:420px;
}

.profile {
  width:120px;
  height:120px;
  border-radius:50%;
  border:3px solid #ddd;
  object-fit:cover;
}

input {
  padding:8px;
  width:250px;
}

button {
  margin-top:10px;
  padding:10px 15px;
  border:none;
  background:#28a745;
  color:white;
  cursor:pointer;
}

.logout {
  background:#dc3545;
  width:100%;
  margin-top:30px;
}
</style>

<!-- Firebase -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<!-- SIDEBAR -->
<div class="sidebar">
  <a href="mark_attendance.jsp">📍 Attendance</a>
  <a href="settings.jsp" class="active">⚙️ Settings</a>
  <a href="#" onclick="logout()">🚪 Logout</a>
</div>

<!-- MAIN -->
<div class="main">
  <div class="header">
    <b>Settings</b>
    <span id="emailText">Loading...</span>
  </div>

  <div class="content">

    <!-- CHANGE EMAIL -->
    <div class="card">
      <h3>Change Email</h3>
      <input id="newEmail" placeholder="New email">
      <br>
      <button onclick="changeEmail()">Update Email</button>
    </div>

    <!-- PROFILE IMAGE -->
    <div class="card">
      <h3>Profile Picture</h3>
      <img id="img" class="profile" src="https://via.placeholder.com/120">
      <br><br>
      <input type="file" id="file" accept="image/*">
      <br>
      <button onclick="uploadPic()">Upload Picture</button>
    </div>

    <button class="logout" onclick="logout()">Logout</button>

  </div>
</div>

<script>
/* 🔥 FIREBASE INIT */
const firebaseConfig = {
  apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
  authDomain: "attendencewebapp-4215b.firebaseapp.com",
  projectId: "attendencewebapp-4215b"
};

if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

const auth = firebase.auth();
const db = firebase.firestore();

/* 🔐 AUTH CHECK */
auth.onAuthStateChanged(user => {
  if (!user) {
    window.location.href = "login.jsp";
    return;
  }

  emailText.innerText = user.email;

  db.collection("users").doc(user.uid).get().then(doc => {
    if (doc.exists && doc.data().profileImage) {
      img.src = doc.data().profileImage;
    }
  });
});

/* ✉️ CHANGE EMAIL */
function changeEmail() {
  const user = auth.currentUser;
  const newEmail = document.getElementById("newEmail").value;

  if (!newEmail) {
    alert("Enter new email");
    return;
  }

  user.updateEmail(newEmail)
    .then(() => {
      return db.collection("users").doc(user.uid).update({
        email: newEmail
      });
    })
    .then(() => {
      alert("Email updated. Please login again.");
      logout();
    })
    .catch(err => alert(err.message));
}

/* 🖼️ UPLOAD & RESIZE IMAGE (SAFE FOR FIRESTORE) */
function uploadPic() {
  const user = auth.currentUser;
  const file = document.getElementById("file").files[0];

  if (!file) {
    alert("Select an image");
    return;
  }

  const imgObj = new Image();
  const reader = new FileReader();

  reader.onload = e => imgObj.src = e.target.result;

  imgObj.onload = () => {
    const canvas = document.createElement("canvas");
    const SIZE = 300;

    canvas.width = SIZE;
    canvas.height = SIZE;

    const ctx = canvas.getContext("2d");
    ctx.drawImage(imgObj, 0, 0, SIZE, SIZE);

    const compressedBase64 = canvas.toDataURL("image/jpeg", 0.7);

    console.log("Base64 size:", compressedBase64.length);

    db.collection("users").doc(user.uid).set({
      profileImage: compressedBase64
    }, { merge: true })
    .then(() => {
      document.getElementById("img").src = compressedBase64;
      alert("Profile picture updated!");
    })
    .catch(err => alert(err.message));
  };

  reader.readAsDataURL(file);
}

/* 🚪 LOGOUT */
function logout() {
  auth.signOut().then(() => {
    window.location.href = "login.jsp";
  });
}
</script>

</body>
</html>


