package com.algalopez;

import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;


@QuarkusTest
public class HelloGrpcClient2Test {

    @Inject
    HelloGrpcClient2 helloGrpcClient;

    @Test
    public void testHello() {
        helloGrpcClient.asd();

    }

}
