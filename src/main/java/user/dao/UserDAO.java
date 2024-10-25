package user.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import user.bean.UserDTO;

@Mapper
public interface UserDAO {



	UserDTO login(UserDTO userDTO);

	UserDTO getMember(String uemail);

	void update(UserDTO userDTO);

	void delete(UserDTO userDTO);

	List<UserDTO> list(Map<String, Integer> map);

	UserDTO naverLogin(String uid, String uname, String uemail);

	UserDTO naverLogin(Map<String, Object> map);

	void write(String name);

	List<UserDTO> getList(Map<String, Integer> map);

	void deletePatient(int seq);

}
