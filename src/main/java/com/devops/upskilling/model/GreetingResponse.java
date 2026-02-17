package com.devops.upskilling.model;

import java.time.LocalDateTime;

/**
 * DTO (Data Transfer Object) - Response model
 * Java Record - immutable, auto-generates boilerplate
 */
public record GreetingResponse(
    String message,
    LocalDateTime timestamp,
    String environment
) {}
