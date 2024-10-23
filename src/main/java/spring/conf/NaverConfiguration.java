// MonoRecipe/src/main/java/spring/conf/NaverConfiguration.java

package spring.conf;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

import lombok.Getter;
import lombok.Setter;

@Configuration
@PropertySource("classpath:spring/naver.properties")
@Getter
@Setter
public class NaverConfiguration {
	
	@Value("${ncp.accessKey}")
	private String accessKey;
	
	@Value("${ncp.secretKey}")
	private String secretKey;
	
	@Value("${ncp.regionName}")
	private String regionName;
	
	@Value("${ncp.endPoint}")
	private String endPoint;
	
}
