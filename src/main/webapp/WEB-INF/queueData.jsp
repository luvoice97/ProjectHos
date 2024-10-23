<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.LinkedList"%>
<%@ page import="java.util.Queue"%>
<%
request.setCharacterEncoding("UTF-8");
    Queue<String> queue = (Queue<String>) session.getAttribute("queue");
    if (queue == null) {
        queue = new LinkedList<>();
    }

    for (String name : queue) {
        out.println("<li>" + name + "</li>");
    }
%>