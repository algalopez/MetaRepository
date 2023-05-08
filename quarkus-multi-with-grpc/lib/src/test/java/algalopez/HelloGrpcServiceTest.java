package algalopez;

import com.algalopez.grpc.HelloGrpc;
import com.algalopez.grpc.HelloReply;
import com.algalopez.grpc.HelloRequest;
import io.quarkus.grpc.GrpcClient;
import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.time.Duration;

@QuarkusTest
public class HelloGrpcServiceTest {

    @GrpcClient
    HelloGrpc helloGrpc;

    @Test
    public void testHello() {
        HelloReply reply = helloGrpc
                .sayHello(HelloRequest.newBuilder().setName("Neo").build()).await().atMost(Duration.ofSeconds(5));
        Assertions.assertEquals("Hello Neo!", reply.getMessage());
    }

}
