
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mark Attendance (2025)</title>

<style>
body{margin:0;font-family:Segoe UI;background:#f4f6f9;display:flex;height:100vh}
.sidebar{width:260px;background:#343a40;color:#fff}
.sidebar h2{padding:20px;margin:0;background:#212529;text-align:center}
.sidebar a{display:block;padding:15px 20px;color:#c2c7d0;text-decoration:none}
.sidebar a:hover,.sidebar a.active{background:#495057;color:#fff}
.main{flex:1;display:flex;flex-direction:column}
.header{height:60px;background:#fff;display:flex;justify-content:flex-end;align-items:center;padding:0 20px}
.profile{display:flex;align-items:center;gap:10px}
.profile img{width:35px;height:35px;border-radius:50%}
.content{flex:1;display:flex;justify-content:center;align-items:center}
.card{background:#fff;padding:30px;border-radius:8px;width:420px;text-align:center}
.status{background:#e9ecef;padding:12px;border-radius:5px;margin-bottom:15px}
input{width:100%;padding:10px;margin:10px 0}
button{width:100%;padding:12px;border:none;color:#fff;font-size:15px;cursor:pointer}
.in{background:#28a745}
.out{background:#dc3545;margin-top:10px}
video{width:100%;border-radius:5px;margin-bottom:10px}
.warn{font-size:12px;color:#c0392b}
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<!-- SIDEBAR -->
<div class="sidebar">
  <h2>emPower</h2>
  <a class="active">📍 Mark Attendance</a>
  <a href="employee_tasks.jsp">📝 Assigned Tasks</a>
  <a href="attendance_history.jsp">🕒 Attendance History</a>
  <a href="employee_expenses.jsp">💸 My Expenses</a>
  <a href="salary.jsp">💰 My Salary</a>
  <a href="settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()">🚪 Logout</a>
</div>

<!-- MAIN -->
<div class="main">

<!-- HEADER -->
<div class="header">
  <div class="profile">
    <span id="empName">aka</span>
    <img id="avatar" src="https://via.placeholder.com/35">
  </div>
</div>

<!-- CONTENT -->
<div class="content">
  <div class="card">
    <h2>Mark Attendance (2025)</h2>
    <div class="status" id="statusBox">Checking records...</div>

    <video id="video" autoplay playsinline></video>
    <canvas id="canvas" style="display:none"></canvas>
    <div class="warn" id="camMsg"></div>

    <input id="project" placeholder="Project (optional)">

    <button class="in" onclick="mark('IN')">Clock IN</button>
    <button class="out" onclick="mark('OUT')">Clock OUT</button>
  </div>
</div>

</div>

<script>
/* FIREBASE */
const firebaseConfig = {
  apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
  authDomain: "attendencewebapp-4215b.firebaseapp.com",
  projectId: "attendencewebapp-4215b"
};
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

/* GLOBAL */
let currentUser = null;
let cameraAvailable = false;

/* AUTH */
auth.onAuthStateChanged(u=>{
  if(!u){ location.href="login.jsp"; return; }
  currentUser = u;
  loadProfile();
  loadLast();
  startCamera();
});

/* LOAD PROFILE */
function loadProfile(){
  db.collection("users").doc(currentUser.email).get().then(d=>{
    if(!d.exists) return;
    const data = d.data();
    document.getElementById("empName").innerText = data.fullName || "aka";
    if(data.profileImage){
      document.getElementById("avatar").src = data.profileImage;
    }
  });
}

/* LAST STATUS */
function loadLast(){
  db.collection("attendance_2025")
    .where("email","==",currentUser.email)
    .orderBy("timestamp","desc")
    .limit(1)
    .get().then(s=>{
      if(s.empty){
        statusBox.innerText="No attendance recorded today";
      }else{
        const d=s.docs[0].data();
        statusBox.innerText="Last entry: "+d.type;
      }
    });
}

/* CAMERA */
function startCamera(){
  if(!navigator.mediaDevices) return;
  navigator.mediaDevices.getUserMedia({video:true})
    .then(stream=>{
      video.srcObject=stream;
      cameraAvailable=true;
    })
    .catch(()=>{
      cameraAvailable=false;
      camMsg.innerText="⚠️ Camera not available (attendance allowed)";
    });
}

/* MARK */
function mark(type){
  let photo="NO_CAMERA";

  if(cameraAvailable){
    const c=document.getElementById("canvas");
    c.width=320;c.height=240;
    c.getContext("2d").drawImage(video,0,0,320,240);
    photo=c.toDataURL("image/jpeg",0.6);
  }

  navigator.geolocation.getCurrentPosition(pos=>{
    save(type,photo,pos.coords.latitude,pos.coords.longitude);
  },()=>{
    save(type,photo,0,0);
  });
}

/* SAVE */
function save(type,photo,lat,lng){
  db.collection("attendance_2025").add({
    email:currentUser.email,
    type,
    project:project.value||"",
    photo,
    cameraUsed:photo!=="NO_CAMERA",
    location:{lat,lng},
    timestamp:firebase.firestore.FieldValue.serverTimestamp()
  }).then(()=>{
    alert("Attendance marked");
    location.reload();
  });
}

/* LOGOUT */
function logout(){
  auth.signOut().then(()=>location.href="login.jsp");
}
</script>

</body>
</html>




