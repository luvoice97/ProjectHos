<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
    String currentNumber = (String) session.getAttribute("currentNumber");
    if (currentNumber == null || currentNumber.isEmpty()) {
        out.print("없음");
    } else {
        out.print(currentNumber);
    }
%>