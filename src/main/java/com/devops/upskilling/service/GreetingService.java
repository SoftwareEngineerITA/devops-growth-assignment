package com.devops.upskilling.service;

import com.devops.upskilling.model.GreetingResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * Business Logic Layer - Separation of Concerns
 * Service layer enables scalability and testability
 */
@Service
public class GreetingService {

    // Externalized configuration - 12-Factor App principle
    // Value from ConfigMap or application.properties (default: "Hello")
    @Value("${app.greeting.message:Hello}")
    private String greetingMessage;

    @Value("${app.environment:local}")
    private String environment;

    public GreetingResponse createGreeting(String name) {
        String message = String.format("%s, %s! (from %s environment)", 
                                       greetingMessage, name, environment);
        
        return new GreetingResponse(
            message,
            LocalDateTime.now(),
            environment
        );
    }
}
