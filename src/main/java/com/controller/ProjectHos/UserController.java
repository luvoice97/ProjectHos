package com.controller.ProjectHos;



import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.mail.internet.MimeMessage;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import user.bean.UserDTO;
import user.service.UserService;



@Controller
public class UserController {
   
	@Autowired
	private UserDTO userDTO;
	
	@Autowired
	private UserService userService;
	
	/*
	 * // 모든 사용자(환자) 목록 반환
	 * 
	 * @GetMapping("/patients")
	 * 
	 * @ResponseBody public List<UserDTO> getPatients() { return
	 * userService.getPatients(); }
	 */

    // 환자 추가
    @PostMapping("/user/patients/add")
    @ResponseBody
    public String addPatient(@RequestParam("patient") String name) {
    	System.out.println("name = "+name);
        userService.write(name);
        return "환자가 성공적으로 추가되었습니다!";
    }

	/*
	 * // 환자 호출
	 * 
	 * @PostMapping("/patients/call")
	 * 
	 * @ResponseBody public String callPatient() { String calledPatient =
	 * userService.callPatient(); return calledPatient != null ? "호출된 환자: " +
	 * calledPatient : "대기 중인 환자가 없습니다."; }
	 * 
	 * // 우선 환자 호출
	 * 
	 * @PostMapping("/patients/priorityCall")
	 * 
	 * @ResponseBody public String priorityCallPatient(@RequestParam("priorityName")
	 * String priorityName) { boolean isCalled =
	 * userService.priorityCallPatient(priorityName); return isCalled ?
	 * "우선 호출된 환자: " + priorityName : "해당 환자는 대기열에 없습니다."; }
	 * 
	 * // 환자 대기열에서 삭제
	 * 
	 * @PostMapping("/patients/delete")
	 * 
	 * @ResponseBody public String deletePatient(@RequestParam("deleteName") String
	 * deleteName) { boolean isDeleted = userService.deletePatient(deleteName);
	 * return isDeleted ? deleteName + " 환자가 대기열에서 삭제되었습니다." : "해당 환자는 대기열에 없습니다.";
	 * }
	 */
	
	
	@RequestMapping(value="/user/signIn", method = RequestMethod.GET)
	public String userSignIn() {
		return "/user/userSignIn";
	}
	
	@RequestMapping(value="/user/login")
	public String login(@ModelAttribute UserDTO userDTO, Model model,HttpSession session) {	
	    userDTO = userService.login(userDTO);
	    
	    if (userDTO == null) {
	        model.addAttribute("error", "로그인 실패! 이메일 또는 비밀번호가 잘못되었습니다.");
	        return "/user/userSignIn"; 
	    }
	    session.setAttribute("userDTO", userDTO);

	    return "redirect:/";// /WEB-INF/index.jsp
	}
	


	

	
	@RequestMapping(value="/user/userList", method = RequestMethod.GET)
	public String list(@RequestParam(required = false, defaultValue = "1") String pg, Model model) {
		Map<String, Object> map2 = userService.list(pg);
		
		map2.put("pg", pg);
		
		model.addAttribute("map2", map2);
		
		//model.addAttribute("list", map2.get("list"));
		//model.addAttribute("userPaging", map2.get("userPaging"));
		return "/user/userList"; //=> /WEB-INF/user/list.jsp
	}
	
	@RequestMapping(value="/user/callback", method = RequestMethod.GET)
	public String userCallback()  {
		return "/user/callback";
	}
	
	@ResponseBody
	@RequestMapping("/user/naverLogin")
	public int naverLogin(@RequestParam("uid") String uid, 
	                      @RequestParam("uname") String uname, 
	                      @RequestParam("uemail") String uemail,
	                      HttpSession session) {
		
			
	    if (userService.getExistId(uemail) != "non_exist") {
	    	Map<String, Object> map = new HashMap<>();
	    	map.put("uemail", uemail);
	    	map.put("uid", uemail);
	    	map.put("uname", uname+"naver");
	        userDTO = userService.naverLogin(map);

	    } else {
	        userDTO = new UserDTO();
	        userDTO = userService.login(userDTO);
	    }
	    session.setAttribute("userDTO", userDTO);
	    return 1; 
	}
	
	


	  
	   

	  

}
