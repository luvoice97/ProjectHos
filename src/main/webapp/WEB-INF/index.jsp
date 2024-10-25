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
        .center { flex: 1; padding: 10px; }
        .right { flex: 1; padding: 10px; }
        #currentPatient { font-size: 18px; margin-bottom: 20px; }
        #patientInput { width: 100%; padding: 5px; margin-bottom: 10px; }
        #addPatientBtn { padding: 5px 10px; }
        #patientList { margin-top: 20px; }
        .patient-item { display: flex; justify-content: space-between; }
        /* Popup styles */
        .modal {
            display: none; 
            position: fixed; 
            z-index: 1; 
            left: 0;
            top: 0;
            width: 100%; 
            height: 100%; 
            overflow: auto; 
            background-color: rgb(0,0,0); 
            background-color: rgba(0,0,0,0.4); 
            padding-top: 60px; 
        }
        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%; 
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }
        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
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

    <!-- Popup Modal -->
    <div id="myModal" class="modal">
        <div class="modal-content">
            <span class="close">&times;</span>
            <h2 id="modalTitle"></h2>
            <p>환자가 호출되었습니다!</p>
        </div>
    </div>

    <script>
        // 서버로 환자 목록을 주기적으로 요청하는 함수
        function loadPatientList() {
            $.ajax({
                url: 'user/patients/list', // 서버에서 환자 목록을 가져오는 엔드포인트
                method: 'POST',
                dataType: 'json',
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
                data: { patient: patientName },
                dataType: 'text',
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
                var li = $('<li class="patient-item">')
                    .text(patient.name + " (Seq: " + patient.seq + ")")
                    .append(
                        $('<button>').text('호출').click(function() {
                            callPatient(patient); // 호출 버튼 클릭 시 호출 함수 실행
                        }),
                        $('<button>').text('삭제').click(function() {
                            deletePatient(patient.seq); // 삭제 버튼 클릭 시 삭제 함수 실행
                        })
                    );
                patientList.append(li);
            });
        }

        // 환자 호출 함수
        function callPatient(patient) {
            // Update the current patient display
            $('#currentPatient').text(patient.name); // Show called patient name
            // Show the modal
            $('#modalTitle').text(patient.name + " 호출 중");
            $('#myModal').show();

            // Optionally, you can send a request to the server to handle the call
            $.ajax({
                url: 'user/patients/call', // 호출 API 엔드포인트
                method: 'POST',
                data: { seq: patient.seq,
                		 name:patient.name
                		 },
                success: function() {
                    loadPatientList(); // 목록 갱신
                }
            });

            // Close the modal after 3 seconds
            setTimeout(function() {
                $('#myModal').hide();
            }, 3000);
        }

        // 환자 삭제 함수
        function deletePatient(seq) {
            $.ajax({
                url: 'user/patients/delete', 
                method: 'POST',
                data: { seq: seq },
                success: function() {
                    loadPatientList(); // 목록 갱신
                }
            });
        }

        // Close the modal when the user clicks on <span> (x)
        $('.close').click(function() {
            $('#myModal').hide();
        });

        // Close the modal when the user clicks anywhere outside of the modal
        $(window).click(function(event) {
            if (event.target.className === 'modal') {
                $('#myModal').hide();
            }
        });
    </script>
</body>
</html>
