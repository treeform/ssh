import os, json

import ssh

var server = newSSH("root@nyt.istrolid.com")
#var server = newSSH("user@server") # make sure you have ssh keys setup, password not supported

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

# some system commands in the style of the `os` module
echo "existsFile:", server.existsFile("test.txt")
echo "existsFile:", server.existsFile("test_other.txt")
echo "existsDir:", server.existsDir("/var/log")
echo "getCurrentDir:", server.getCurrentDir()
server.setCurrentDir("/var/log")
echo "getCurrentDir:", server.getCurrentDir()



server.exit()
