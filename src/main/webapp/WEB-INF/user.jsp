
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.LinkedList"%>
<%@ page import="java.util.Queue"%>
<%
    request.setCharacterEncoding("UTF-8");

    // 세션에서 큐를 가져옴
    Queue<String> queue = (Queue<String>) session.getAttribute("queue");
    if (queue == null) {
        queue = new LinkedList<>();
        session.setAttribute("queue", queue); // 큐를 세션에 저장
    }

    String currentNumber = (String) session.getAttribute("currentNumber");
    if (currentNumber == null) {
        currentNumber = "없음"; // 기본값 설정
    }

    //  호출
    String action = request.getParameter("action");
    if ("call".equals(action)) {
        if (!queue.isEmpty()) {
            currentNumber = queue.poll(); // 다음 환자 호출
            session.setAttribute("currentNumber", currentNumber);
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>대기열</title>
    <link rel="stylesheet" href="css/style.css">
    <script>
        let lastCurrentName = "없음"; // 이전 호출된 환자 이름

        function fetchQueue() {
            const xhr = new XMLHttpRequest();
            xhr.open("GET", "queueData.jsp", true);
            xhr.onload = function () {
                if (xhr.status === 200) {
                    document.getElementById("queueList").innerHTML = xhr.responseText;
                }
            };
            xhr.send();
        }

        function fetchCurrentName() {
            const xhr = new XMLHttpRequest();
            xhr.open("GET", "currentName.jsp", true);
            xhr.onload = function () {
                if (xhr.status === 200) {
                    const currentName = xhr.responseText.trim();
                    const currentNameP = currentName + "님 진료실로 들어오세요";
                    document.getElementById("currentName").innerText = currentName.length > 0 ? currentName : "없음";

                    // 이름이 변경된 경우에만 팝업 표시
                    if (currentName !== lastCurrentName && currentName !== "없음") {
                        showPopup(currentNameP); // 팝업 표시
                        playBGM(); // BGM 재생
                        lastCurrentName = currentName; // 현재 이름 업데이트
                    } else if (currentName === "없음") {
                        lastCurrentName = "없음"; // 현재 이름이 없으면 업데이트
                    }
                }
            };
            xhr.send();
        }

        function showPopup(name) {
            const popup = document.getElementById("popup");
            popup.innerText = name; // 팝업에 환자 이름 설정
            popup.style.display = "block"; // 팝업 보이기
            setTimeout(() => {
                popup.style.display = "none"; // 3초 후 팝업 숨기기
            }, 3000);
        }

        function playBGM() {
            const audio = document.getElementById("bgm");
            audio.currentTime = 0; // 시작 시간 초기화
            audio.play(); // BGM 재생
        }

        // 0.5초마다 대기열과 현재 호출된 이름을 업데이트
        setInterval(fetchQueue, 500);
        setInterval(fetchCurrentName, 500);
    </script>
    <style>
        #popup {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            padding: 40px; /* 패딩을 늘려서 크기 증가 */
            background-color: rgba(255, 255, 255, 0.9);
            border: 2px solid #4a90e2;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            font-size: 32px; /* 폰트 크기 증가 */
            z-index: 1000; /* 다른 요소 위에 표시 */
        }
    </style>
</head>
<body>
    <header>
        <h1>대기열</h1>
    </header>
    <div class="container">
        <div class="flex-container">
            <div class="current">
                <h2>현재 진료중인 환자</h2>
                <h1 id="currentName"><%= currentNumber %></h1>
            </div>
            <div class="queue">
                <h2>대기환자</h2>
                <ul id="queueList">
                    <%
                        for (String name : queue) {
                            out.println("<li>" + name + "</li>");
                        }
                    %>
                </ul>
            </div>
        </div>
    </div>

    <!-- 팝업 요소 -->
    <div id="popup"></div>
    
    <!-- BGM 오디오 요소 -->
    <audio id="bgm" src="bgm/dingdong.mp3" preload="auto"></audio>
</body>
</html>