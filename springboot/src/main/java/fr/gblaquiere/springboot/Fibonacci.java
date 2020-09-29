package fr.gblaquiere.springboot;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.util.Date;

@RestController()
@RequestMapping("/fibonacci/")
class Fibonacci {

    @GetMapping("/")
    public ResponseEntity<?> hello(@RequestParam(required = false,name = "n") Integer nParam){
        long n = 30;
        if (nParam != null && nParam > 0){
            n = nParam;
        }
        Date before = new Date();
        long result = fibo(n);
        Date after = new Date();
        long duration = after.getTime() - before.getTime();
        String answer = "Fibonacci(" + n + ") = " + result + " found in " + duration + "ms\n";
        System.out.println(answer);
        return new ResponseEntity<>(answer, HttpStatus.OK);
    }


    // Function for nth Fibonacci number
    private long fibo(long n) {
        if (n <= 2)
            return n - 1;
        else
            return fibo(n - 1) + fibo(n - 2);
    }

}