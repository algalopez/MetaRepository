package com.algalopez.grpc;

import static com.algalopez.grpc.HelloGrpcGrpc.getServiceDescriptor;
import static io.grpc.stub.ServerCalls.asyncUnaryCall;

@jakarta.annotation.Generated(value = "by Mutiny Grpc generator", comments = "Source: hello.proto")
public final class MutinyHelloGrpcGrpc implements io.quarkus.grpc.MutinyGrpc {

    private MutinyHelloGrpcGrpc() {
    }

    public static MutinyHelloGrpcStub newMutinyStub(io.grpc.Channel channel) {
        return new MutinyHelloGrpcStub(channel);
    }

    public static class MutinyHelloGrpcStub extends io.grpc.stub.AbstractStub<MutinyHelloGrpcStub> implements io.quarkus.grpc.MutinyStub {

        private HelloGrpcGrpc.HelloGrpcStub delegateStub;

        private MutinyHelloGrpcStub(io.grpc.Channel channel) {
            super(channel);
            delegateStub = HelloGrpcGrpc.newStub(channel);
        }

        private MutinyHelloGrpcStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
            super(channel, callOptions);
            delegateStub = HelloGrpcGrpc.newStub(channel).build(channel, callOptions);
        }

        @Override
        protected MutinyHelloGrpcStub build(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
            return new MutinyHelloGrpcStub(channel, callOptions);
        }

        public io.smallrye.mutiny.Uni<HelloReply> sayHello(HelloRequest request) {
            return io.quarkus.grpc.stubs.ClientCalls.oneToOne(request, delegateStub::sayHello);
        }
    }

    public static abstract class HelloGrpcImplBase implements io.grpc.BindableService {

        private String compression;

        /**
         * Set whether the server will try to use a compressed response.
         *
         * @param compression the compression, e.g {@code gzip}
         */
        public HelloGrpcImplBase withCompression(String compression) {
            this.compression = compression;
            return this;
        }

        public io.smallrye.mutiny.Uni<HelloReply> sayHello(HelloRequest request) {
            throw new io.grpc.StatusRuntimeException(io.grpc.Status.UNIMPLEMENTED);
        }

        @Override
        public io.grpc.ServerServiceDefinition bindService() {
            return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor()).addMethod(HelloGrpcGrpc.getSayHelloMethod(), asyncUnaryCall(new MethodHandlers<HelloRequest, HelloReply>(this, METHODID_SAY_HELLO, compression))).build();
        }
    }

    private static final int METHODID_SAY_HELLO = 0;

    private static final class MethodHandlers<Req, Resp> implements io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>, io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>, io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>, io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {

        private final HelloGrpcImplBase serviceImpl;

        private final int methodId;

        private final String compression;

        MethodHandlers(HelloGrpcImplBase serviceImpl, int methodId, String compression) {
            this.serviceImpl = serviceImpl;
            this.methodId = methodId;
            this.compression = compression;
        }

        @Override
        @SuppressWarnings("unchecked")
        public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
            switch(methodId) {
                case METHODID_SAY_HELLO:
                    io.quarkus.grpc.stubs.ServerCalls.oneToOne((HelloRequest) request, (io.grpc.stub.StreamObserver<HelloReply>) responseObserver, compression, serviceImpl::sayHello);
                    break;
                default:
                    throw new AssertionError();
            }
        }

        @Override
        @SuppressWarnings("unchecked")
        public io.grpc.stub.StreamObserver<Req> invoke(io.grpc.stub.StreamObserver<Resp> responseObserver) {
            switch(methodId) {
                default:
                    throw new AssertionError();
            }
        }
    }
}
