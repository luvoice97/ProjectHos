<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, inital-scale=1.0">
    <title>관리자 화면</title>
	   <link rel="stylesheet" href="./css/index.css">

</head>
<body>
    <header>
        <h1>관리자 화면</h1>
    </header>

    <div class="container">
        <!-- 왼쪽: 현재 호출 중인 환자 -->
        <div class="left">
            <h2>현재 진료 중인 환자</h2>
            <div id="currentPatient"></div>
        </div>

        <!-- 중앙: 환자 입력 -->
        <div class="center">
            <h2>환자 입력</h2>
            <input type="text" id="patientInput" placeholder="환자 이름 입력" />
            <button id="addPatientBtn">환자 추가</button>
            <button id="openCallPageButton" >호출 페이지 </button>
            <div id="idDiv"></div>
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
            <p></p>
        </div>
    </div>


        
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
   <script>
        $(document).ready(function() {
            // 환자 호출 페이지 열기
            $('#openCallPageButton').click(function() {
                var callPageUrl = '/ProjectHos/patient';
                window.open(callPageUrl, '_blank');
            });
            
            
            function CheckCurrentPatient() {
                $.ajax({
                    url: 'user/patients/CheckCurrent',
                    method: 'POST',
                    dataType: 'text',
                    success: function(name) {
                        $('#currentPatient').text(name); // 호출된 환자 이름 표시
                    },
                    error: function(xhr, status, error) {
                        console.error('환자 목록 로드 중 오류 발생:', error);
                    }
                });
            }
            
            setInterval(CheckCurrentPatient, 1000);

            // 서버로 환자 목록을 주기적으로 요청하는 함수
            function loadPatientList() {
                $.ajax({
                    url: 'user/patients/list',
                    method: 'POST',
                    dataType: 'json',
                    success: function(patients) {
                        updatePatientList(patients);
                    },
                    error: function(xhr, status, error) {
                        console.error('환자 목록 요청 중 오류 발생:', error);
                    }
                });
            }

            // 일정 시간 간격으로 환자 목록을 갱신 (Polling)
            setInterval(loadPatientList, 3000); // 3초마다 서버에 요청

            // 환자 추가 버튼 클릭 시 서버로 환자 추가 요청
            $('#addPatientBtn').click(function() {
                var patientName = $('#patientInput').val();
                if(!patientName){
                	$('#idDiv').text("이름을 입력해주세요");
                	return;
                }
                $.ajax({
                    url: 'user/patients/add',
                    method: 'POST',
                    data: { patient: patientName },
                    dataType: 'text',
                    success: function() {
                        $('#patientInput').val(''); // 입력칸 초기화
                        loadPatientList(); // 목록 갱신
                    },
                    error: function(xhr, status, error) {
                        console.error('환자 추가 중 오류 발생:', error);
                    }
                });
            });

            // 환자 목록 업데이트 함수
            function updatePatientList(patients) {
                var patientList = $('#patientList');
                patientList.empty(); // 기존 목록 초기화

                patients.forEach(function(patient) {
                    var li = $('<li class="patient-item" data-seq="' + patient.seq + '">')
                        .append(
                            $('<span>').text(patient.name), // 이름을 span으로 감싸서 왼쪽 정렬
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
                $('#currentPatient').text(patient.name); // 호출된 환자 이름 표시

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

                // 모달을 3초 후에 닫기
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
                    },
                    error: function(xhr, status, error) {
                        console.error('환자 삭제 중 오류 발생:', error);
                    }
                });
            }

            // 모달 닫기 버튼 클릭 시
            $('.close').click(function() {
                $('#myModal').hide();
            });

            // 모달 외부 클릭 시 모달 닫기
            $(window).click(function(event) {
                if ($(event.target).hasClass('modal')) {
                    $('#myModal').hide();
                }
            });
        });
    </script>
</body>
</html>
