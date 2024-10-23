// MonoRecipe/src/main/java/spring/conf/SpringConfiguration.java
package spring.conf;

import org.apache.commons.dbcp2.BasicDataSource;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;


@Configuration
@EnableTransactionManagement
@PropertySource("classpath:spring/db.properties")
@MapperScan("admin.dao user.dao dish.dao review.dao favorite.dao") 
public class SpringConfiguration { 
	
	/** Connection Pool */
	private @Value("${jdbc.driver}") String driver;
	private @Value("${jdbc.url}") String url;
	private @Value("${jdbc.username}") String username;
	private @Value("${jdbc.password}") String password;

	@Autowired
	private ApplicationContext context;

	/** DataSource */
	@Bean
	public BasicDataSource dataSource() {
		BasicDataSource basicDataSource = new BasicDataSource();
		basicDataSource.setDriverClassName(driver);
		basicDataSource.setUrl(url);
		basicDataSource.setUsername(username);
		basicDataSource.setPassword(password);
		
		return basicDataSource;
	}
	

	/** SqlSessionFactory */
	@Bean
	public SqlSessionFactory sqlSessionFactory() throws Exception {
		SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
		sqlSessionFactoryBean.setDataSource(dataSource());
		
		sqlSessionFactoryBean.setMapperLocations(
				context.getResources("classpath:mapper/*Mapper.xml")
		);
		
		sqlSessionFactoryBean.setTypeAliasesPackage("*.bean");
		
		return sqlSessionFactoryBean.getObject(); // SqlSessionFactory 로 변환하여 넘겨줌
	}
	
	
	/** SqlSession */
	@Bean
	public SqlSessionTemplate sqlSession() throws Exception {
		SqlSessionTemplate sqlSessionTemplate = new SqlSessionTemplate(sqlSessionFactory());
		
		return sqlSessionTemplate;
	}
	
	/** TransactionManager */
	@Bean
	public DataSourceTransactionManager transactionManager() {
		DataSourceTransactionManager dataSourceTransactionManager = 
				new DataSourceTransactionManager(dataSource());
		
		return dataSourceTransactionManager;
	}
	
	
}
