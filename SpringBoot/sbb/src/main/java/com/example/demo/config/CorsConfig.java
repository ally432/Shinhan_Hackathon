// com.example.demo.config.CorsConfig
package com.example.demo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry reg) {
        reg.addMapping("/**")
          .allowedOriginPatterns("*")
          .allowedMethods("POST","GET","OPTIONS")
          .allowedHeaders("*")
          .allowCredentials(false);
    }
}