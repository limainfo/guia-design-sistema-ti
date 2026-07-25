package br.com.lab.backend;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InfoController {

    private final String applicationVersion;

    public InfoController(@Value("${app.version:local}") String applicationVersion) {
        this.applicationVersion = applicationVersion;
    }

    @GetMapping("/api/info")
    public Map<String, Object> info() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("service", "microbackend");
        response.put("version", applicationVersion);
        response.put("pod", hostname());
        response.put("java", System.getProperty("java.version"));
        response.put("timestamp", Instant.now().toString());
        return response;
    }

    private String hostname() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException exception) {
            return "unknown";
        }
    }
}
