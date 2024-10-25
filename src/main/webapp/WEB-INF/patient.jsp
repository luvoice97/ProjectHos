<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>환자 화면</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { padding: 20px; }
        h2 { color: #333; }
        #patientList { list-style-type: none; padding: 0; }
        .patient-item { margin: 10px 0; cursor: pointer; }
        .modal {
            display: none; 
            position: fixed; 
            z-index: 1; 
            left: 0;
            top: 0;
            width: 100%; 
            height: 100%; 
            overflow: auto; 
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
        .currentPatient {
            margin-bottom: 20px;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>환자 대기 화면</h1>
        
        <!-- 왼쪽: 현재 호출 중인 환자 -->
        <div class="left">
            <h2>현재 호출 중인 환자</h2>
            <div id="currentPatient" class="currentPatient">
            </div>
        </div>
        
        <h2>대기 중인 환자 목록</h2>
        <ul id="patientList">
            <!-- 환자 목록은 여기에 동적으로 추가됩니다 -->
        </ul>
    </div>

    <!-- 모달 팝업을 위한 HTML 코드 -->
    <div id="myModal" class="modal">
        <div class="modal-content">
            <span class="close">&times;</span>
            <h2 id="modalTitle"></h2>
            <p>환자가 호출되었습니다!</p>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            // 주기적으로 userDTO를 확인하는 함수
            function checkUserDTO() {
                $.ajax({
                    url: 'user/patients/checkUserDTO', // userDTO를 확인하는 엔드포인트
                    method: 'POST',
                    dataType: 'json',
                    success: function(userDTO) {
                        if (userDTO) {
                        	$('#currentPatient').text(userDTO.name);
                            $('#modalTitle').text(userDTO.name + ' 호출 중');
                            $('#myModal').show(); // 팝업 표시
                            $('#myModal').hide(3000);
                            
                            // 세션에서 환자 정보 삭제
                            $.ajax({
                                url: 'user/patients/clearSession', // 세션에서 환자 정보 삭제
                                method: 'POST'
                            });
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('userDTO 확인 중 오류 발생:', error);
                    }
                });
            }

            // 환자 목록을 주기적으로 로드하는 함수
            function loadPatientList() {
                $.ajax({
                    url: 'user/patients/list', // 환자 목록을 가져오는 엔드포인트
                    method: 'POST',
                    dataType: 'json',
                    success: function(patients) {
                        updatePatientList(patients);
                    },
                    error: function(xhr, status, error) {
                        console.error('환자 목록을 불러오는 중 오류 발생:', error);
                    }
                });
            }

            // 환자 목록 업데이트 함수
            function updatePatientList(patients) {
                var patientList = $('#patientList');
                patientList.empty(); // 기존 목록 초기화

                patients.forEach(function(patient) {
                    var li = $('<li class="patient-item">')
                        .text(patient.name + " (Seq: " + patient.seq + ")")
                        .click(function() { callPatient(patient); }); // 클릭 시 환자 호출
                    patientList.append(li);
                });
            }

            // 페이지 로드 시 환자 목록을 주기적으로 가져오기
            loadPatientList(); // 초기 로드
            setInterval(loadPatientList, 3000); // 3초마다 목록 갱신

            // 주기적으로 userDTO를 확인
            setInterval(checkUserDTO, 1000); // 1초마다 userDTO 확인

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
        });
        


        
        // 환자 호출 함수
        function callPatient(patient) {
            // 환자 호출을 위한 AJAX 요청
            $.ajax({
                url: 'user/patients/call', // 호출 API 엔드포인트
                method: 'POST',
                data: { seq: patient.seq, name: patient.name },
                success: function() {
                    loadPatientList(); // 목록 갱신
                },
                error: function(xhr, status, error) {
                    console.error('환자 호출 중 오류 발생:', error);
                }
            });
        }
    </script>
</body>
</html>
