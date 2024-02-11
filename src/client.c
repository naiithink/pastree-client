/**
 * Hypertext Transfer Protocol (HTTP/1.1): Message Syntax and Routing
 * <https://www.rfc-editor.org/rfc/rfc7230>
 */

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <unistd.h>

#include <netdb.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define SERVER_PORT 80

#define MAXLINE     4096
#define SA          struct sockaddr

int main(int argc, char **argv)
{
    int                sockfd, n;
    int                sendbytes;
    struct sockaddr_in servaddr;
    char               sendline[MAXLINE];
    char               recvline[MAXLINE];

    if (argc != 2)
    {
        fprintf(stderr, "Invalid argument\n");
        return 1;
    }

    /**
     * Creates a socket
     */
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        fprintf(stderr, "Error creating socket\n");
        return 1;
    }

    /* Initializes to 0's */
    bzero(&servaddr, sizeof(servaddr));

    servaddr.sin_family = AF_INET;

    /**
     * Port
     *
     * htons    := host to network, short
     *          ::= Converts to the network standard byte order (from big-endian
     * or little-endian)
     */
    servaddr.sin_port = htons(SERVER_PORT);

    /**
     * Converts text representation of IP address into the binary representation
     * of the address
     *
     * "1.2.3.4" => [1,2,3,4]
     */
    if (inet_pton(AF_INET, argv[1], &servaddr.sin_addr) <= 0)
    {
        fprintf(stderr, "inet_pton error for %s\n", argv[1]);
        return 1;
    }

    /**
     * Connects to the server
     */
    if (connect(sockfd, (SA *) &servaddr, sizeof(servaddr)) < 0)
    {
        fprintf(stderr, "Connection failed\n");
        return 1;
    }

    /**
     * HTTP requests
     *
     * 1.       Start line    :=      <HTTP_METHOD> <request_target>
     * <HTTP/version>
     * 2. (opt) Headers       :=      [<Header> ":" <value>]*
     * 3.       An empty line
     * 4. (opt) Body
     *
     * Use 'CRLF' as NL <https://www.rfc-editor.org/rfc/rfc7230#section-3>
     *
     * This instance:
     * --
     * GET / HTTP/1.1
     *
     */
    snprintf(sendline, MAXLINE, "GET / HTTP/1.1\r\n\r\n");
    sendbytes = strlen(sendline);

    /**
     * Sending 'request': writes to the socket
     */
    if (write(sockfd, sendline, sendbytes) != sendbytes)
    {
        fprintf(stderr, "Error writing to socket\n");
        return 1;
    }

    /**
     * Receiving 'response'
     */
    memset(recvline, 0, MAXLINE);
    while ((n = read(sockfd, recvline, MAXLINE - 1)) > 0)
    {
        printf("%s", recvline);
        memset(recvline, 0, MAXLINE);
    }

    if (n < 0)
    {
        fprintf(stderr, "Read error\n");
        return 1;
    }

    return 0;
}
