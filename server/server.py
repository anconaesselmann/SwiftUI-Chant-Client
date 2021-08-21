#!/usr/bin/env python

# Inspired by https://pythonprogramming.net/server-chatroom-sockets-tutorial-python-3/

import socket
import select
import uuid
from datetime import datetime

from Auth import Authenticaton
from Messages import *
from MessageSerialization import serialize
# from MessageSerialization import read_from_stream
from MessageSerialization import HEADER_TYPE_LENGTH
from MessageSerialization import MEADER_MESSAGE_LENGTH

HEADER_LENGTH = 10

IP = "127.0.0.1"
PORT = 20212

auth = Authenticaton()

# Create a socket
# socket.AF_INET - address family, IPv4, some otehr possible are AF_INET6, AF_BLUETOOTH, AF_UNIX
# socket.SOCK_STREAM - TCP, conection-based, socket.SOCK_DGRAM - UDP, connectionless, datagrams, socket.SOCK_RAW - raw IP packets
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# SO_ - socket option
# SOL_ - socket option level
# Sets REUSEADDR (as a socket option) to 1 on socket
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

# Bind, so server informs operating system that it's going to use given IP and port
# For a server using 0.0.0.0 means to listen on all available interfaces, useful to connect locally to 127.0.0.1 and remotely to LAN interface IP
server_socket.bind((IP, PORT))

# This makes server listen to new connections
server_socket.listen()

# List of sockets for select.select()
sockets_list = [server_socket]

# List of connected clients - socket as a key, user header and name as data
clients = {}

class User:
    def __init__(self, name, token):
        self.name = name
        self.token = token

class Message:
    def __init__(self, message_type, data):
        self.message_type = message_type
        self.data = data

print(f'Listening for connections on {IP}:{PORT}...')

def accept(user, client_socket, client_address):
    clients[client_socket] = user
    sockets_list.append(client_socket)
    print('Accepted new connection from {}:{}, username: {}'.format(*client_address, user.name))

def read(client_socket):
    print("reading from socket")
    try:
        type_header = client_socket.recv(HEADER_TYPE_LENGTH)
        print(type_header)
        type_int = int(type_header.decode('utf-8').strip())
        print(type_int)
        message_type = MessageType(type_int)
        print(message_type)
        message_header = client_socket.recv(MEADER_MESSAGE_LENGTH)
        message_length = int(message_header.decode('utf-8').strip())
        data = client_socket.recv(message_length)
        print(data)
        return Message(message_type = message_type, data = data)
    except Exception as e:
        print("Could not read from socket.", e)
        return False

def send_logged_in(client_socket, token):
    message = LoggedInResponse(user_id = token.user_id, token = token.token, expires = token.expires)
    serialized = serialize(message = message)
    client_socket.send(serialized.encode())
    print("User logged in")

def connect(client_socket, client_address):
    try:
        message = read(client_socket = client_socket)
        if not message:
            print("could not read message")
            return False

        user = None
        if message.message_type == MessageType.NEW_USER:
            request = NewUserRequest.fromJSON(json_data = message.data)
            user_name = request.name
            token = auth.create_user(email = request.email, name = request.name, password = request.password)
            if token is None:
                print("User already exists")
                return False
            user = User(name = user_name, token = token)
        elif message.message_type == MessageType.EMAIL_LOGIN:
            request = EmailLoginRequest.fromJSON(json_data = message.data)
            token = auth.log_in(email = request.email, password = request.password)
            if token is None:
                print("Email/password incorrect")
                return False
            user_name = auth.user_name_for(token.user_id)
            user = User(name = user_name, token = token)
        elif message.message_type == MessageType.TOKEN_LOGIN:
            request = TokenLoginRequest.fromJSON(json_data = message.data)
            token = auth.validate(user_id = uuid.UUID(request.user_id), token = uuid.UUID(request.token))
            if token is None:
                print("user_id/token incorrect or expiredd")
                return False
            user_name = auth.user_name_for(token.user_id)
            user = User(name = user_name, token = token)
        else:
            print("Invalid connection message")
            return False

        accept(user = user, client_socket = client_socket, client_address = client_address)
        send_logged_in(client_socket = client_socket, token = token)
        return True
    except Exception as e:
        print("Could not connect", e)
        return False


# Handles message receiving
def receive_message(client_socket):
    print("message recieved")
    # try:
    message = read(client_socket = client_socket)
    if not message:
        print("could not read message")
        return False
    
    elif message.message_type == MessageType.CHAT_CLIENT:
        print("CHAT_CLIENT")
        request = ChatMessageRequest.fromJSON(json_data = message.data)
        print("request: ", request.sender_id, request.chat_id, request.message_id, request.token, request.body)
        token = auth.validate(user_id = uuid.UUID(request.sender_id), token = uuid.UUID(request.token))
        if token is None:
            print("Not a valid message")
            return False
        print("Valid message")

        print("Valid body: ", request.body)
        sender_name = auth.name_for_id(user_id = uuid.UUID(request.sender_id))
        print("Creating server message")
        server_message = ChatMessageResponse(chat_id = uuid.UUID(request.chat_id), message_id = uuid.UUID(request.message_id), sender_name = sender_name, body = request.body, date = datetime.now().__str__())
        print("server message: ", server_message)
        return server_message
    elif message.message_type == MessageType.LOGGED_OUT:
        print("LOGGED_OUT")
        request = LogoutRequest.fromJSON(json_data = message.data)
        token = auth.validate(user_id = uuid.UUID(request.user_id), token = uuid.UUID(request.token))
        if token is None:
            print("user_id/token incorrect or expiredd")
            return False

        auth.log_out(user_id = uuid.UUID(request.user_id), token = uuid.UUID(request.token))
        print("Logged out")
        return False
    else:
        print("Unknown message")
        return False

while True:

    # Calls Unix select() system call or Windows select() WinSock call with three parameters:
    #   - rlist - sockets to be monitored for incoming data
    #   - wlist - sockets for data to be send to (checks if for example buffers are not full and socket is ready to send some data)
    #   - xlist - sockets to be monitored for exceptions (we want to monitor all sockets for errors, so we can use rlist)
    # Returns lists:
    #   - reading - sockets we received some data on (that way we don't have to check sockets manually)
    #   - writing - sockets ready for data to be send thru them
    #   - errors  - sockets with some exceptions
    # This is a blocking call, code execution will "wait" here and "get" notified in case any action should be taken
    read_sockets, _, exception_sockets = select.select(sockets_list, [], sockets_list)

    # Iterate over notified sockets
    for notified_socket in read_sockets:
        if notified_socket == server_socket:

            client_socket, client_address = server_socket.accept()

            if connect(client_socket = client_socket, client_address = client_address):
                print("Connected")
            else:
                print("Not connected")
        else:
            # existing socket is sending a message
            print("reading message")
            message = receive_message(client_socket = notified_socket)
            print("message recieved")

            # If False, client disconnected, cleanup
            if message is False:
                print('Closed connection from: {}'.format(clients[notified_socket].name))

                # Remove from list for socket.socket()
                sockets_list.remove(notified_socket)

                # Remove from our list of users
                del clients[notified_socket]

                continue

            # Get user by notified socket, so we will know who sent the message
            user = clients[notified_socket]

            print(f'Received message from {user.name}: {message.body}')

            # Iterate over connected clients and broadcast message
            for client_socket in clients:

                # # But don't sent it to sender
                if client_socket != notified_socket:
                    serialized = serialize(message = message)
                    print(serialized)
                    client_socket.send(serialized.encode())

    # It's not really necessary to have this, but will handle some socket exceptions just in case
    for notified_socket in exception_sockets:

        # Remove from list for socket.socket()
        sockets_list.remove(notified_socket)

        # Remove from our list of users
        del clients[notified_socket]

