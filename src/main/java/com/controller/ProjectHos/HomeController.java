package com.controller.ProjectHos;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {
	
	
	@RequestMapping(value="/")
	public String index(Model model) {
	    return "/index"; // /WEB-INF/index.jsp
	}
	
	@RequestMapping(value="/patient")
	public String patient(Model model) {
	    return "/patient"; 
	}
	
}


