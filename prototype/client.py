import socket
import sys


HOST = "0.0.0.0"
PORT = 63740

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

client_socket.connect((HOST, PORT))

request = f"""\
1.0.0
PULL
{sys.argv[1]}

"""

client_socket.sendall(request.encode())

done = 0

while done != 1:
    response = client_socket.recv(1024).decode()
    response_lines = response.split("\n")
    print(response_lines, "\n")

    if response_lines[0] not in ['0', '1']:
        break

client_socket.close()
