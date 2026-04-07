package com.example.bouncechecker;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*") // Allow Keycloak to call this
public class BounceController {

    @Autowired
    private BounceListenerService bounceListenerService;

    @GetMapping({"", "/"})
    public Map<String, String> getEmailStatus(@RequestParam String email) {
        Map<String, String> response = new HashMap<>();
        if (bounceListenerService.hasBounced(email)) {
            response.put("status", "bounced");
        } else {
            response.put("status", "pending");
        }
        return response;
    }
}
