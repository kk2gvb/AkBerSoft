#include <zmq.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

int main (){
    

    //Создание контекста и сокета
    void *ctx = zmq_ctx_new();
    void *req = zmq_socket(ctx, ZMQ_REQ);
    zmq_connect(req, "tcp://localhost:5015");
    
    //Получение отправляемого сообщения
    printf("Enter your message: ");
    char Send_msg[51];
    if (fgets(Send_msg, sizeof(Send_msg), stdin)){
        zmq_send(req, Send_msg, strlen(Send_msg), 0);
    }
    
    
    //Отправка и получение сообщений
    for(int i = 0; i < 10; i++){
        char Receive_msg[51] = {0};
        printf("Sending: %s", Send_msg);
        zmq_send(req, Send_msg, strlen(Send_msg), 0);

        zmq_recv(req, Receive_msg, sizeof(Receive_msg),0);
        printf("Receive:%s\n\n",Receive_msg);
    }
    
    //Закрытие сокета и контекста
    zmq_close(req);
    zmq_ctx_destroy(ctx);

    return 0;
}
