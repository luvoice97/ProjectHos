package user.service;

import java.util.List;
import java.util.Map;

import user.bean.UserDTO;

public interface UserService {

	String getExistId(String uid);

	void write(String patient);

	UserDTO login(UserDTO userDTO);

	UserDTO getMember(String uemail);

	void update(UserDTO userDTO);

	void delete(UserDTO userDTO);

	Map<String, Object> list(String pg);


	UserDTO naverLogin(Map<String, Object> map);

	List<UserDTO> getList(Map<String, Integer> map);

	void deletePatient(int seq);

	String naverTTS(String text);

	void TempMember(Map<String, Object> map);

	UserDTO GetTempMember();

	void DeleteTempMember();




}
