package user.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;


import user.bean.UserDTO;
import user.bean.UserPaging;
import user.dao.UserDAO;
import user.service.UserService;

@Service
public class UserServiceImpl implements UserService {

	@Autowired
	private UserDAO userDAO;
	
	@Autowired
	private UserPaging userPaging;



	@Override
	public UserDTO login(UserDTO userDTO) {
		return userDAO.login(userDTO);
		
	}



	@Override
	public UserDTO getMember(String uemail) {
		return userDAO.getMember(uemail);
	}



	@Override
	public void update(UserDTO userDTO) {
		userDAO.update(userDTO);
		
	}



	@Override
	public void delete(UserDTO userDTO) {
		userDAO.delete(userDTO);
		
	}


	@Override
	public UserDTO naverLogin(Map<String, Object> map) {
		return userDAO.naverLogin(map);
	}



	@Override
	public String getExistId(String uid) {
		return null;
	}



	@Override
	public void write(String name) {
		userDAO.write(name);
		
	}



	@Override
	public Map<String, Object> list(String pg) {
		// TODO Auto-generated method stub
		return null;
	}



}
