package com.devops.upskilling.controller;

import com.devops.upskilling.model.GreetingResponse;
import com.devops.upskilling.service.GreetingService;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * REST Controller - Main API endpoints
 * Base path: /api
 */
@Validated
@RestController
@RequestMapping("/api")
public class GreetingController {

    private final GreetingService greetingService;

    // Constructor injection for immutability and testability
    public GreetingController(GreetingService greetingService) {
        this.greetingService = greetingService;
    }

    // GET /api/greet?name=Milan - Returns personalized greeting
    @GetMapping("/greet")
    public ResponseEntity<GreetingResponse> greet(
            @RequestParam(defaultValue = "World") 
            @NotBlank(message = "Name cannot be blank") 
            String name) {
        
        GreetingResponse response = greetingService.createGreeting(name);
        return ResponseEntity.ok(response);
    }

    // GET /api/status - Application-level status check
    @GetMapping("/status")
    public ResponseEntity<String> status() {
        return ResponseEntity.ok("Application is running");
    }
}
