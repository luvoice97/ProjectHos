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
        <div class="section">
            <h2>현재  진료 중인 환자</h2>
            <div id="currentPatient" class="currentPatient"></div>
        </div>
        
        <div class="section">
            <div id="patientCount">대기 환자 수 :<span id="count">0</span>명</div>
            <ul id="patientList" class="patient-list"></ul>
        </div>
        
        <div class="section">
            <div id="patientCount">대기 환자 명단</div>
            <ul id="patientList2" class="patient-list"></ul>
        </div>
    </div>
    
    <audio id="DingDong" src="./mp3/DingDong.mp3" preload="auto"></audio>
    <audio id="tts" src="" preload="auto"></audio>

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
        function checkUserDTO() {
            $.ajax({
                url: 'user/patients/checkUserDTO',
                method: 'POST',
                dataType: 'text',
                success: function(name) {
                	var currentName=$('#currentPatient').val();
                	var newName=name;
                	if(newName ===currentName){
                		return;
                	}
                    if (name !=null) {
                        $.ajax({
                            url: 'user/naverTTS',
                            method: 'POST',
                            data: { text: name },
                            dataType: 'text',
                            success: function(fileUrl) {
                                var ttsSound = document.getElementById('tts');
                                ttsSound.src = fileUrl; 
                                ttsSound.currentTime = 0;
                                ttsSound.play().catch(function(error) {
                                    console.error('TTS 소리 재생 중 오류 발생:', error);
                                });

                                var dingdongSound = document.getElementById('DingDong');
                                dingdongSound.currentTime = 0;
                                dingdongSound.play().catch(function(error) {
                                    console.error('DingDong 소리 재생 중 오류 발생:', error);
                                });

                                $('#currentPatient').text(name);
                                $('#modalTitle').html(name + ' 님<br>진료실로 들어오세요');

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
                            },
                            error: function(xhr, status, error) {
                                console.error('TTS 요청 중 오류 발생:', error);
                            }
                        });
                    }
                },
                error: function(xhr, status, error) {
                    console.error('UserDTO 체크 중 오류 발생:', error);
                }
            });
        }

        setInterval(checkUserDTO, 1000);

        function loadPatientList() {
            $.ajax({
                url: 'user/patients/list',
                method: 'POST',
                dataType: 'json',
                success: function(patients) {
                    updatePatientList(patients);
                },
                error: function(xhr, status, error) {
                    console.error('환자 목록 로드 중 오류 발생:', error);
                }
            });
        }

        function updatePatientList(patients) {
            var patientList = $('#patientList');
            var patientList2 = $('#patientList2');
            var count = $('#count');
            
            patientList.empty();
            patientList2.empty();

            patients.forEach(function(patient, index) {
                if (index < 8) {
                    var li = $('<li class="patient-item">')
                        .text(patient.name)
                        .click(function() { callPatient(patient); });
                    patientList.append(li);
                } else if (index < 16) {
                    var li2 = $('<li class="patient-item">')
                        .text(patient.name)
                        .click(function() { callPatient(patient); });
                    patientList2.append(li2);
                }
            });

            count.text(patients.length);
        }

        loadPatientList();
        setInterval(loadPatientList, 3000);

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
