<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>병원 호출 관리자 화면</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { display: flex; }
        .left { flex: 1; padding: 10px; }
        .right { flex: 1; padding: 10px; }
        #currentPatient { font-size: 18px; margin-bottom: 20px; }
        #patientInput { width: 100%; padding: 5px; margin-bottom: 10px; }
        #addPatientBtn { padding: 5px 10px; }
        #patientList { margin-top: 20px; }
    </style>
</head>
<body>
    <header>
        <h1>병원 호출 프로그램</h1>
    </header>

    <div class="container">
        <!-- 왼쪽: 현재 호출 중인 환자 -->
        <div class="left">
            <h2>현재 호출 중인 환자</h2>
            <div id="currentPatient">현재 호출 중인 환자 없음</div>
        </div>

        <!-- 중앙: 환자 입력 -->
        <div class="center">
            <h2>환자 입력</h2>
            <input type="text" id="patientInput" placeholder="환자 이름 입력" />
            <button id="addPatientBtn">환자 추가</button>
        </div>

        <!-- 오른쪽: 입력한 환자 목록 -->
        <div class="right">
            <h2>환자 목록</h2>
            <ul id="patientList">
                <!-- 실시간 업데이트 -->
            </ul>
        </div>
    </div>

    <script>
        // 서버로 환자 목록을 주기적으로 요청하는 함수
        function loadPatientList() {
            $.ajax({
                url: '/patients', // 서버에서 환자 목록을 가져오는 엔드포인트
                method: 'GET',
                success: function(patients) {
                    updatePatientList(patients);
                }
            });
        }

        // 일정 시간 간격으로 환자 목록을 갱신 (Polling)
        setInterval(loadPatientList, 3000); // 3초마다 서버에 요청

        // 환자 추가 버튼 클릭 시 서버로 환자 추가 요청
        $('#addPatientBtn').click(function() {
            var patientName = $('#patientInput').val();
            $.ajax({
                url: 'user/patients/add',
                method: 'POST',
                data: {patient:patientName},
            	dataType:'text', 
                success: function() {
                    $('#patientInput').val(''); // 입력칸 초기화
                    loadPatientList(); // 목록 갱신
                }
            });
        });

        // 환자 목록 업데이트 함수
        function updatePatientList(patients) {
            var patientList = $('#patientList');
            patientList.empty(); // 기존 목록 초기화

            patients.forEach(function(patient) {
                var li = $('<li>').text(patient.name + " (" + patient.status + ")");
                patientList.append(li);
            });

            // 현재 호출 중인 환자 표시
            var currentPatient = patients.find(p => p.status === '호출 중');
            $('#currentPatient').text(currentPatient ? currentPatient.name : '현재 호출 중인 환자 없음');
        }
    </script>
</body>
</html>