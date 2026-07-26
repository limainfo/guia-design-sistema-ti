package br.com.lab.backend;

import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.Map;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Validated
public class GreetingController {

    @GetMapping("/api/greeting")
    public Map<String, Object> greeting(
            @RequestParam(defaultValue = "Kubernetes")
            @Size(min = 1, max = 40) String name) {

        return Map.of(
                "message", "Olá, " + name + "!",
                "timestamp", Instant.now().toString());
    }
}
