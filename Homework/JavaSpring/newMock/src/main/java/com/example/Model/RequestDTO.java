package com.example.Model;

//import lombok.*;
//
//@ToString
//@NoArgsConstructor
//@AllArgsConstructor
//@Setter
//@Getter
import lombok.Data;

@Data
public class RequestDTO {
    private String rqUID;
    private String clientId;
    private String account;
    private String OpenDate;
    private String CloseDate;

}