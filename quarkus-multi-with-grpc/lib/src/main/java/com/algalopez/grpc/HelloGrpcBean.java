package com.algalopez.grpc;

import io.grpc.BindableService;
import io.quarkus.grpc.GrpcService;
import io.quarkus.grpc.MutinyBean;

@jakarta.annotation.Generated(value = "by Mutiny Grpc generator", comments = "Source: hello.proto")
public class HelloGrpcBean extends MutinyHelloGrpcGrpc.HelloGrpcImplBase implements BindableService, MutinyBean {

    private final HelloGrpc delegate;

    HelloGrpcBean(@GrpcService HelloGrpc delegate) {
        this.delegate = delegate;
    }

    @Override
    public io.smallrye.mutiny.Uni<HelloReply> sayHello(HelloRequest request) {
        try {
            return delegate.sayHello(request);
        } catch (UnsupportedOperationException e) {
            throw new io.grpc.StatusRuntimeException(io.grpc.Status.UNIMPLEMENTED);
        }
    }
}
