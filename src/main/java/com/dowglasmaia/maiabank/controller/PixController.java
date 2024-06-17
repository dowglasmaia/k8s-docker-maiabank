package com.dowglasmaia.maiabank.controller;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/transactions")
public class PixController {

    @PostMapping
    public ResponseEntity<String> receivers(){
        String response = "API-ON";
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }
}
