package com.algalopez;

import com.algalopez.grpc.HelloGrpc;
import com.algalopez.grpc.HelloReply;
import com.algalopez.grpc.HelloRequest;
import io.quarkus.grpc.GrpcClient;
import jakarta.enterprise.context.ApplicationScoped;

import java.time.Duration;

@ApplicationScoped
public class HelloGrpcClient {

    @GrpcClient("asd")
    HelloGrpc helloGrpc;

    public void asd() {
        HelloReply reply = helloGrpc
                .sayHello(HelloRequest.newBuilder().setName("Neo").build()).await().atMost(Duration.ofSeconds(5));

        System.out.printf("reply: " + reply);
    }
}
