package com.example.Controller;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Random;

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
            // Переменная для обозначения максимального лимита.
            BigDecimal maxLimit;
            // Переменнтая для обозначения типа валюты.
            String currency;
            // Переменная, для генерации рандомного значения баланса.
            BigDecimal random_balance;
            // Переменные обозначающие тип валюты и максимальный лимит по ней.
            final String US = "US";
            BigDecimal US_limit = new BigDecimal("2000.00");
            final String EU = "EU";
            BigDecimal EU_limit = new BigDecimal("1000.00");
            final String RUB = "RUB";
            BigDecimal RUB_limit = new BigDecimal("10000.00");

            String RqID = requestDTO.getRqUID();

            if (firstDigit == '8') {
                maxLimit = US_limit;
                currency = US;
                random_balance = generateRandomBigDecimal(US_limit);
            } else if (firstDigit == '9') {
                maxLimit = EU_limit;
                currency = EU;
                random_balance = generateRandomBigDecimal(EU_limit);
            } else {
                maxLimit = RUB_limit;
                currency = RUB;
                random_balance = generateRandomBigDecimal(RUB_limit);
            }


            ResponseDTO responseDTO = new ResponseDTO();

            responseDTO.setRqUID(RqID);
            responseDTO.setClientId(clientId);
            responseDTO.setAccount(requestDTO.getAccount());
            responseDTO.setCurrency(currency);
            responseDTO.setBalance(random_balance);
            responseDTO.setMaxLimit(maxLimit);

            log.error("****** ReuqestDTO *****" + mapper.writerWithDefaultPrettyPrinter().writeValueAsString(requestDTO));
            log.error("****** ResponseDTO *****" + mapper.writerWithDefaultPrettyPrinter().writeValueAsString(responseDTO));

            return responseDTO;


        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // Метод для генерации рандомного значения типа данных BigDecimal.
    public static BigDecimal generateRandomBigDecimal(BigDecimal max) {
        // Используем java.util.Random для генерации случайного значения.
        Random random = new Random();
        // Генерируем случайное значение.
        BigDecimal randomBigDecimal = max.multiply(BigDecimal.valueOf(random.nextDouble()));
        // Устанавливаем нужную точность (по желанию).
        return randomBigDecimal.setScale(2, RoundingMode.HALF_UP); // 2 знака после запятой
    }
}
