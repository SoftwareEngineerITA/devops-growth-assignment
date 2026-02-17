package com.devops.upskilling;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Application Entry Point
 * Spring Boot auto-configuration enabled:
 * (@ComponentScan, @Configuration, @EnableAutoConfiguration)
 */
@SpringBootApplication
public class ResilientSpringPlatformApplication {

    public static void main(String[] args) {
        SpringApplication.run(ResilientSpringPlatformApplication.class, args);
    }
}
