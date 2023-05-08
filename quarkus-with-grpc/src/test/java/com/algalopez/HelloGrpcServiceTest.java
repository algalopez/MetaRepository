package com.algalopez;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.time.Duration;

import com.algalopez.grpc.HelloGrpc;
import com.algalopez.grpc.HelloReply;
import com.algalopez.grpc.HelloRequest;
import io.quarkus.grpc.GrpcClient;
import io.quarkus.test.junit.QuarkusTest;

import org.junit.jupiter.api.Test;

@QuarkusTest
public class HelloGrpcServiceTest {

    @GrpcClient
    HelloGrpc helloGrpc;

    @Test
    public void testHello() {
        HelloReply reply = helloGrpc
                .sayHello(HelloRequest.newBuilder().setName("Neo").build()).await().atMost(Duration.ofSeconds(5));
        assertEquals("Hello Neo!", reply.getMessage());
    }

}
