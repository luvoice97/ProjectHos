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
	
	
    // 환자 추가
	@PostMapping("/user/patients/list")
	@ResponseBody
	public List<UserDTO> listPatient() {
	    Map<String, Integer> map = new HashMap<>();
	    List<UserDTO> userDTO = userService.getList(map);
	    return userDTO; // JSON 형식으로 자동 변환되어 반환됨
	}

    // 환자 추가
    @PostMapping("/user/patients/add")
    @ResponseBody
    public String addPatient(@RequestParam("patient") String name) {
    	System.out.println("name = "+name);
        userService.write(name);
        return "환자가 성공적으로 추가되었습니다!";
    }
    
    @PostMapping("/user/patients/call")
    @ResponseBody
    public void callPatient(@RequestParam("seq") int seq ,@RequestParam("name") String name,HttpSession session) {
    	Map<String,Object> map =new HashMap<>();
    	map.put("seq", seq);
    	map.put("name", name);
    	userService.TempMember(map);
    	System.out.println(name+seq);
    	userService.deletePatient(seq);
    }

    @PostMapping("/user/patients/delete")
    @ResponseBody
    public String deletePatient(@RequestParam int seq) {
    	   userService.deletePatient(seq);
    	 return"success";
    }
    
    @PostMapping("/user/patients/checkUserDTO")
    @ResponseBody
    public String checkUserDTO(HttpSession session) {
        UserDTO userDTO =userService.GetTempMember();
        if (userDTO != null) {
            return userDTO.getName(); 
        }
        return null; 
    }
    
    @PostMapping("/user/patients/CheckCurrent")
    @ResponseBody
    public String CheckCurrent(HttpSession session) {
        UserDTO userDTO =userService.GetTempMember();
        if (userDTO != null) {
            return userDTO.getName(); 
        }
        return null; 
    }
    

    
    @PostMapping("/user/patients/clearSession")
    @ResponseBody
    public void clearSession() {
    	userService.DeleteTempMember();
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
	
	@RequestMapping("/user/naverTTS")
	@ResponseBody
	public String naverTTS(@RequestParam(value = "text", defaultValue = "안녕하세요 네이버 TTS입니다") String text) {
	    String completeText = text + "님 진료실로 들어오세요";
	    String fileUrl = userService.naverTTS(completeText);
	    return fileUrl; 
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
