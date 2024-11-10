package com.example.Controller;


import com.example.Model.ResponseDTO;
import com.example.Model.RequestDTO;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;

@RestController

public class MainController {
    private Logger log = LoggerFactory.getLogger(MainController.class);

    ObjectMapper mapper = new ObjectMapper();

    @PostMapping(
            // Адрес для нашеё заглушки.
            value = "/info/postBalances",
            // Переменные для логирования.
            produces = MediaType.APPLICATION_JSON_VALUE,
            consumes = MediaType.APPLICATION_JSON_VALUE
    )
    public Object postBalance(@RequestBody RequestDTO requestDTO) {
        try {
            String clientId = requestDTO.getClientId();
            char firstDigit = clientId.charAt(0);
            BigDecimal maxLimit;
            String RqID = requestDTO.getRqUID();

            if (firstDigit == '8') {
                maxLimit = new BigDecimal(2000);
            } else if (firstDigit == '9') {
                maxLimit = new BigDecimal(1000);
            } else {
                maxLimit = new BigDecimal(10000);
            }

            ResponseDTO responseDTO = new ResponseDTO();

            responseDTO.setRqUID(RqID);
            responseDTO.setClientId(clientId);
            responseDTO.setAccount(requestDTO.getAccount());
            responseDTO.setCurrency("RUB");
            responseDTO.setBalance(new BigDecimal("7777"));
            responseDTO.setMaxLimit(maxLimit);

            log.error("****** ReuqestDTO *****" + mapper.writerWithDefaultPrettyPrinter().writeValueAsString(requestDTO));
            log.error("****** ResponseDTO *****" + mapper.writerWithDefaultPrettyPrinter().writeValueAsString(responseDTO));

            return responseDTO;


        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}
