package com.codeit.ecspraticestarter.controller;


import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class EnvController {
    // 환경 변수 SPRING_PROFILES_ACTIVE 값 (없으면 null)
    @Value("${SPRING_PROFILES_ACTIVE:#{null}}")
    private String springProfilesActive;

    @Value("${DB_HOST:#{null}}")
    private String dbHost;

    @Value("${DB_PASSWORD:#{null}}")
    private String dbPassword;

    @GetMapping("/env")
    public String showEnv() {
        return String.format("""
                SPRING_PROFILES_ACTIVE = %s
                DB_HOST = %s
                DB_PASSWORD = %s
                """, springProfilesActive, dbHost, dbPassword);
    }
}
