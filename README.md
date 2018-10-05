
# SSH - Connect to machines over SSH and run commands there.

Example:

```nim
var server = newSSH("user@server")
echo server.command("uptime")
echo server.command("ls")
server.writeFile("test.txt", "hello world\nits great here!\nnow what?")
echo server.readFile("test.txt")
server.exit()
```