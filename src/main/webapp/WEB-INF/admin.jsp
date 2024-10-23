<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.LinkedList"%>
<%@ page import="java.util.Queue"%>
<%
    request.setCharacterEncoding("UTF-8");

 
    String password = (String) session.getAttribute("authenticated");
    String inputPassword = request.getParameter("password");

    if ("8670".equals(inputPassword)) {
        session.setAttribute("authenticated", "true");
        password = "true"; 
    }

    Queue<String> queue = (Queue<String>) session.getAttribute("queue");
    if (queue == null) {
        queue = new LinkedList<>();
        session.setAttribute("queue", queue);
    }

    String currentNumber = (String) session.getAttribute("currentNumber");
    if (currentNumber == null) {
        currentNumber = "";
    }

    String inputName = request.getParameter("inputName");
    if (inputName != null && !inputName.isEmpty()) {
        queue.add(inputName);
    }

    if ("call".equals(request.getParameter("action"))) {
        if (!queue.isEmpty()) {
            currentNumber = queue.poll();
            session.setAttribute("currentNumber", currentNumber);
        }
    }

    String priorityName = request.getParameter("priorityName");
    if (priorityName != null && !priorityName.isEmpty()) {
        if (queue.remove(priorityName)) {
            currentNumber = priorityName;
            session.setAttribute("currentNumber", currentNumber);
        }
    }

    String deleteName = request.getParameter("deleteName");
    if (deleteName != null && !deleteName.isEmpty()) {
        queue.remove(deleteName);
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 대기열 관리</title>
    <link rel="stylesheet" href="css/style.css">
    <meta http-equiv="refresh" content="5"> <!-- 5초마다 페이지 새로고침 -->
</head>
<body>
    <header>
        <h1>관리자 페이지</h1>
    </header>

    <div class="container">
        <% if (password == null) { %>
            <h2>비밀번호 입력</h2>
            <form method="post">
                <input type="password" name="password" placeholder="비밀번호" required>
                <button type="submit">로그인</button>
            </form>
        <% } else { %>
            <div class="flex-container">
                <div class="current">
                    <h2>현재 호출한 환자</h2>
                    <h1 id="currentName"><%= currentNumber.isEmpty() ? "없음" : currentNumber %></h1>

                    <h3>이름 추가</h3>
                    <form method="post">
                        <input type="text" name="inputName" placeholder="이름 입력" required>
                        <br><br>
                        <button type="submit">추가하기</button>
                    </form>

                    <form method="post" style="margin-top: 10px;">
                        <input type="hidden" name="action" value="call">
                        <button type="submit">호출하기</button>
                    </form>
                </div>
                <div class="queue">
                    <h2>대기열</h2>
                    <ul>
                        <%
                            int index = 1;
                            for (String name : queue) {
                                out.println("<li>" + index + ". " + name + 
                                    " <form style='display:inline;' method='post'>" +
                                    "<input type='hidden' name='priorityName' value='" + name + "'>" +
                                    "<button type='submit'>우선 호출</button></form>" +
                                    " <form style='display:inline;' method='post'>" +
                                    "<input type='hidden' name='deleteName' value='" + name + "'>" +
                                    "<button type='submit'>삭제</button></form></li>");
                                index++;
                            }
                        %>
                    </ul>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        function fetchCurrentName() {
            const xhr = new XMLHttpRequest();
            xhr.open("GET", "currentName.jsp", true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    const currentName = xhr.responseText.trim();
                    document.getElementById("currentName").innerText = currentName.length > 0 ? currentName : "없음";
                }
            };
            xhr.send();
        }

        setInterval(fetchCurrentName, 500);
    </script>
</body>
</html>