<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>환자 화면</title>
    <link rel="stylesheet" href="./css/patient.css">
</head>
<body>
    <header>
        <h1>수지정형외과</h1>
    </header>

    <div class="container">
        <!-- 왼쪽: 현재 호출 중인 환자 -->
        <div class="section">
            <h2>현재 호출 중인 환자</h2>
            <div id="currentPatient" class="currentPatient"></div>
        </div>
        
        <!-- 가운데: 대기 중인 환자 목록 1~8순위 -->
        <div class="section">
            <div id="patientCount">대기 환자 수 :<span id="count">0</span>명</div>
            <ul id="patientList" class="patient-list">
                <!-- 환자 목록은 여기에 동적으로 추가됩니다 -->
            </ul>
        </div>
        
        <!-- 오른쪽: 대기 중인 환자 목록 9~16순위 -->
        <div class="section">
                    <div id="patientCount">대기 환자 명단</div>
            <ul id="patientList2" class="patient-list">
                <!-- 9~16 순위 환자 목록은 여기에 동적으로 추가됩니다 -->
            </ul>
        </div>
    </div>
    
    <!-- 딩동 mp3 -->
    <button id="playSoundButton" style="display: none;">Play Sound</button>
    <audio id="DingDong" src="./mp3/DingDong.mp3" preload="auto"></audio>

    <!-- 모달 팝업을 위한 HTML 코드 -->
    <div id="myModal" class="modal">
        <div class="modal-content">
            <span class="close"></span>
            <h2 id="modalTitle"></h2>
            <p></p>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
    $(document).ready(function() {
    	
        $('#playSoundButton').click(function() {
            var dingdongSound = document.getElementById('DingDong');
            dingdongSound.currentTime = 0;
            dingdongSound.play().catch(function(error) {
                console.error('소리 재생 중 오류 발생:', error);
            });
        });
    	
    	
        function checkUserDTO() {
            $.ajax({
                url: 'user/patients/checkUserDTO',
                method: 'POST',
                dataType: 'json',
                success: function(userDTO) {
                    if (userDTO) {
                        $.ajax({
                            url: 'user/naverTTS',
                            method: 'POST',
                            data: { text: userDTO.name },
                            error: function(xhr, status, error) {
                                console.error('TTS 요청 중 오류 발생:', error);
                            }
                        });

                        $('#playSoundButton').trigger('click'); // 버튼 클릭 트리거

                        $('#currentPatient').text(userDTO.name);
                        $('#modalTitle').html(userDTO.name + ' 님<br>진료실로 들어오세요');

                        setTimeout(function() {
                            $('#myModal').show();
                        }, 1000);

                        setTimeout(function() {
                            $('#myModal').hide();
                        }, 7000);

                        $.ajax({
                            url: 'user/patients/clearSession',
                            method: 'POST',
                            error: function(xhr, status, error) {
                                console.error('세션 정리 중 오류 발생:', error);
                            }
                        });
                    }
                },
                error: function(xhr, status, error) {
                    console.error();
                }
            });
        }

        // 주기적으로 checkUserDTO 호출
        setInterval(checkUserDTO, 1000); // 예시로 5초 간격 설정

        // 아래의 코드들을 $(document).ready() 블록 안으로 이동합니다.
        function loadPatientList() {
            $.ajax({
                url: 'user/patients/list',
                method: 'POST',
                dataType: 'json',
                success: function(patients) {
                    updatePatientList(patients);
                },
                error: function(xhr, status, error) {
                    console.error();
                }
            });
        }

        function updatePatientList(patients) {
            var patientList = $('#patientList');
            var patientList2 = $('#patientList2');
            var count = $('#count');
            
            patientList.empty(); // 기존 목록 초기화
            patientList2.empty(); // 기존 목록 초기화

            patients.forEach(function(patient, index) {
                if (index < 8) { // 1~8 순위
                    var li = $('<li class="patient-item">')
                        .text(patient.name) // 시퀀스 대신 이름만 표시
                        .click(function() { callPatient(patient); });
                    patientList.append(li);
                } else if (index < 16) { // 9~16 순위
                    var li2 = $('<li class="patient-item">')
                        .text(patient.name) // 시퀀스 대신 이름만 표시
                        .click(function() { callPatient(patient); });
                    patientList2.append(li2);
                }
            });

            count.text(patients.length); // 대기 중인 환자 수 업데이트
        }

        loadPatientList();
        setInterval(loadPatientList, 3000); // 3초 간격으로 환자 목록 업데이트

        $('.close').click(function() {
            $('#myModal').hide();
        });

        $(window).click(function(event) {
            if (event.target.className === 'modal') {
                $('#myModal').hide();
            }
        });
    });

    function callPatient(patient) {
        $.ajax({
            url: 'user/patients/call',
            method: 'POST',
            data: { seq: patient.seq, name: patient.name },
            success: function() {
                loadPatientList();
            },
            error: function(xhr, status, error) {
                console.error('환자 호출 중 오류 발생:', error);
            }
        });
    }
    </script>
</body>
</html>
