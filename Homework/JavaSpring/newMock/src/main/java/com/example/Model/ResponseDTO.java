package com.example.Model;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ResponseDTO {

    private String rqUID;
    private String clientId;
    private String account;
    private String currency;
    private BigDecimal balance;
    private BigDecimal maxLimit;

}
