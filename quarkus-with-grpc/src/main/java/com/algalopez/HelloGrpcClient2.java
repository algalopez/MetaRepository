package com.algalopez;

import com.algalopez.grpc.HelloGrpc;
import com.algalopez.grpc.HelloGrpcGrpc;
import com.algalopez.grpc.HelloReply;
import com.algalopez.grpc.HelloRequest;
import io.quarkus.grpc.GrpcClient;
import jakarta.enterprise.context.ApplicationScoped;

import java.time.Duration;

@ApplicationScoped
public class HelloGrpcClient2 {

    @GrpcClient//("asd")
    HelloGrpcGrpc.HelloGrpcBlockingStub helloGrpc;

    public void asd() {
        HelloReply reply = helloGrpc.sayHello(HelloRequest.newBuilder().setName("Neo").build());

        System.out.printf("reply: " + reply);
    }
}
