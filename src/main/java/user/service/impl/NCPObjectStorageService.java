package user.service.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;

import spring.conf.NaverConfiguration;

@Service
public class NCPObjectStorageService {
    final AmazonS3 s3;

    @Autowired
    public NCPObjectStorageService(NaverConfiguration naverConfiguration) {
        s3 = AmazonS3ClientBuilder
                .standard()
                .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(
                        naverConfiguration.getEndPoint(), 
                        naverConfiguration.getRegionName()))
                .withCredentials(new AWSStaticCredentialsProvider(
                        new BasicAWSCredentials(
                                naverConfiguration.getAccessKey(),
                                naverConfiguration.getSecretKey())))
                .build();        
    }

    public String uploadMp3File(String bucketName, String directoryPath, File mp3File) {
        try (InputStream inputStream = new FileInputStream(mp3File)) {
            String mp3FileName = UUID.randomUUID().toString() + ".mp3";
            
            ObjectMetadata objectMetadata = new ObjectMetadata();
            objectMetadata.setContentType("audio/mpeg");

            PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName,
                    directoryPath + mp3FileName,
                    inputStream,
                    objectMetadata)
                    .withCannedAcl(CannedAccessControlList.PublicRead);

            s3.putObject(putObjectRequest);
            return mp3FileName;
        } catch (Exception e) {
            throw new RuntimeException("파일 업로드 에러: " + e.getMessage(), e);
        }
    }

    public String getFileUrl(String bucketName, String objectKey) {
        return s3.getUrl(bucketName, objectKey).toString();
    }
}
