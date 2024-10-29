package user.service.impl;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import user.bean.UserDTO;
import user.dao.UserDAO;
import user.service.UserService;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private NCPObjectStorageService ncpObjectStorageService; // NCPObjectStorageService 주입

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
        // TODO: Implement this method
        return null;
    }

    @Override
    public List<UserDTO> getList(Map<String, Integer> map) {
        return userDAO.getList(map);
    }

    @Override
    public void deletePatient(int seq) {
        userDAO.deletePatient(seq);
    }

    @Override
    public String naverTTS(String text) {
        System.out.println(text);
        String clientId = "1evaasc2yg";
        String clientSecret = "nJGdgR8zRwRKsif4Rh2YuZZFD6kwknJ3dTfZd7sm";

        try {
            String apiURL = "https://naveropenapi.apigw.ntruss.com/tts-premium/v1/tts";
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("X-NCP-APIGW-API-KEY-ID", clientId);
            con.setRequestProperty("X-NCP-APIGW-API-KEY", clientSecret);

            // URL 인코딩 적용
            String encodedText = URLEncoder.encode(text, "UTF-8");
            String postParams = "speaker=nara&volume=0&speed=5&pitch=0&format=mp3&text=" + encodedText;

            con.setDoOutput(true);
            DataOutputStream wr = new DataOutputStream(con.getOutputStream());
            wr.writeBytes(postParams);
            wr.flush();
            wr.close();

            int responseCode = con.getResponseCode();
            if (responseCode == 200) { // 정상 호출
                InputStream is = con.getInputStream();
                int read;
                byte[] bytes = new byte[1024];

                // 임시 파일 생성
                String tempname = UUID.randomUUID().toString() + ".mp3";
                File mp3File = new File(tempname);
                mp3File.createNewFile();
                OutputStream outputStream = new FileOutputStream(mp3File);

                while ((read = is.read(bytes)) != -1) {
                    outputStream.write(bytes, 0, read);
                }
                is.close();
                outputStream.close();

                // S3에 업로드
                String bucketName = "bitcamp-9th-bucket-133"; // S3 버킷 이름
                String directoryPath = "storage/"; // 디렉토리 경로
                String uploadedFileName = ncpObjectStorageService.uploadMp3File(bucketName, directoryPath, mp3File);

                // S3의 파일 URL 생성
                String fileUrl = ncpObjectStorageService.getFileUrl(bucketName, directoryPath + uploadedFileName);

                // 업로드된 파일 URL 반환
                return fileUrl;

            } else {  // 오류 발생
                BufferedReader br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
                String inputLine;
                StringBuilder response = new StringBuilder();
                while ((inputLine = br.readLine()) != null) {
                    response.append(inputLine);
                }
                br.close();
                throw new RuntimeException("Naver TTS 에러: " + response.toString());
            }
        } catch (Exception e) {
            throw new RuntimeException("Error: " + e.getMessage(), e);
        }
    }
}
