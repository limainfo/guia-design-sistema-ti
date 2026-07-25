package br.com.lab.backend;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class GreetingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldReturnGreeting() throws Exception {
        mockMvc.perform(get("/api/greeting").param("name", "Evaldo"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message", containsString("Evaldo")));
    }

    @Test
    void shouldRejectLongName() throws Exception {
        mockMvc.perform(get("/api/greeting").param("name", "x".repeat(41)))
                .andExpect(status().isBadRequest());
    }
}
