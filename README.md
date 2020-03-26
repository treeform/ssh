
⚠️ Depricated please use https://github.com/treeform/asyncssh instead. ⚠️


# SSH - Connect to machines to run commands.

## Basics

```nim
import ssh
# make sure you have ssh keys setup, password not supported
var server = newSSH("user@server")
```
Then run some commands:
```nim
# run any simple, blocks until they are done
echo server.command("uptime")
echo server.command("ls")
echo server.command("ps")
```
The library will wait each command to finish, and will returns its output.

## Simple File I/O

Use this smallish text files only, like config files. For bigger I recommend `scp` or `rsync`.
```nim
server.writeFile("test.txt", "hello world\nits great here!\nnow what?")
echo server.readFile("test.txt")
```

## Environment Variables

Set and get environment variable, only sets it for this session.

```nim
server.setEnv("TERM", "xterm")
echo server.getEnv("TERM")
```

## Some os like functions.

I have added some functions similar to the `os` module:
* getCurrentDir
* setCurrentDir
* existsFile
* existsDir

Most of them can easily be done by command line tools like `cd`, `pwd`, and `ls`, but this way it's type-checked.


## Exit the server when you are done.
```nim
server.exit()
```


