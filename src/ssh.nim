import osproc, streams, times, strutils, json
import winlean

# command seperator used to chunk ssh output
const cmdSep = "AAABBBCCCCsshmonAAABBBCCC"


when defined(windows):
  const openSSHPath = "ssh.exe"
else:
  const openSSHPath = "ssh"


type
  SSH = ref object
    process: Process
    buffer: string


proc read*(ssh: var SSH, timeout=1000): string =
  # Low level read for some output with timeout
  while true:
    sleep(int32(timeout))
    var x: int32
    discard peekNamedPipe(ssh.process.outputHandle(), lpTotalBytesAvail=addr x)
    if x > 0:
      # oh new data!
      result.add ssh.process.outputStream().readStr(x)
      continue
    break
  ssh.buffer.add result


proc output*(ssh: var SSH): string =
  # Read output chunks seperated by `cmdSep`
  while true:
    discard ssh.read(10)
    var idx = ssh.buffer.find(cmdSep)
    if idx >= 0:
      result = ssh.buffer[0..<idx]
      ssh.buffer = ssh.buffer[idx + cmdSep.len .. ^1]
      return


proc commandNoOutput*(ssh: var SSH, command: string) =
  # run command, you would be required to run output() yourself
  ssh.process.inputStream().write(command & "\n")


proc command*(ssh: var SSH, command: string): string =
  # run command
  ssh.commandNoOutput(command)
  var output = ssh.output()
  # remove the command itself
  return output[command.len+1..^1]


proc writeFile*(ssh: var SSH, filepath: string, data: string) =
  # Warning, uses `echo`/`quoteShell`, to be used for small text files only
  discard ssh.command("echo " & quoteShellPosix(data) & " > " & filepath)


proc readFile*(ssh: var SSH, filepath: string): string =
  # Warning, uses `cat`, to be used for small text files only
  ssh.command("cat " & filepath)[0..^2].replace("\\n", "\n")


proc exit*(ssh: var SSH) =
  # exit the shell
  ssh.commandNoOutput("exit")
  sleep(10)
  ssh.process.terminate()


proc newSSH*(serverAddress: string): SSH =
  # Start new SSH connection
  result = SSH()
  result.process = startProcess(openSSHPath, args=[serverAddress, "bash", "-i"])

  # set the promt to some thing known so that we can split by it
  result.commandNoOutput("export PS1=\"" & cmdSep.replace("\n", "\\n") & "\"")
  # setting prompt produces 2 chunks, discard them
  discard result.output()
  discard result.output()




