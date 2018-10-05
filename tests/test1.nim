import os

import ssh

var server = newSSH("user@server") # make sure you have ssh keys setup, password not supported

# run any simple, blocks until they are done
echo server.command("uptime")
echo server.command("ls")
echo server.command("ps")

# for smallish text files only:
server.writeFile("test.txt", "hello world\nits great here!\nnow what?")
echo server.readFile("test.txt")

# set and get environment variable, only sets it for this session
server.setEnv("TERM", "xterm")
echo server.getEnv("TERM")

server.exit()
