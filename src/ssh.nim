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


proc write*(ssh: var SSH, data: string) =
  # run command, you would be required to run output() yourself
  ssh.process.inputStream().write(data)


proc commandNoOutput*(ssh: var SSH, command: string) =
  # run command, you would be required to run output() yourself
  ssh.write(command & "\n")


proc command*(ssh: var SSH, command: string): string =
  # run command
  ssh.commandNoOutput(command)
  var output = ssh.output()
  # remove the command itself
  return output[0..^1]


proc writeFile*(ssh: var SSH, filepath: string, data: string) =
  # Warning, uses `echo`/`quoteShell`, to be used for small text files only
  discard ssh.command("echo " & quoteShellPosix(data) & " > " & filepath)


proc readFile*(ssh: var SSH, filepath: string): string =
  # Warning, uses `cat`, to be used for small text files only
  ssh.command("cat " & filepath)[0..^2].replace("\\n", "\n")



proc setEnv*(ssh: var SSH, name: string, value: string) =
  # Sets environment variable, does not persist, only for this session
  if name == "PS1":
    echo "Warning: Setting PS1 will screw up command handling."
  discard ssh.command("export " & name & "=" & quoteShellPosix(value))


proc getEnv*(ssh: var SSH, name: string): string =
  # Reads environment variable
  ssh.command("printenv " & name).strip()


proc existsFile*(ssh: var SSH, filepath: string): bool =
  # Warning, uses `cat`, to be used for small text files only
  let
    output = ssh.command("ls -l " & quoteShellPosix(filepath))
    split = output.split("\n")
  if split.len == 0:
    return false
  let
    lsLine =split[0].splitWhitespace()
  if lsLine.len < 8:
    return false
  lsLine[0][0] == '-' and lsLine[8] == filepath


proc existsDir*(ssh: var SSH, filepath: string): bool =
  # Warning, uses `cat`, to be used for small text files only
  let
    output = ssh.command("ls -l " & quoteShellPosix(filepath))
  let
    lsLine = output.split("\n")[0].splitWhitespace()
  lsLine[0] == "total"


proc getCurrentDir*(ssh: var SSH): string =
  ssh.getEnv("PWD")


proc setCurrentDir*(ssh: var SSH, path: string) =
  discard ssh.command("cd " & quoteShellPosix(path))




proc exit*(ssh: var SSH) =
  # exit the shell
  ssh.commandNoOutput("exit")
  sleep(10)
  ssh.process.terminate()


proc newSSH*(serverAddress: string): SSH =
  # Start new SSH connection
  var ssh = SSH()
  ssh.process = startProcess(openSSHPath, args=[serverAddress, "sh", "-i"])

  # set the promt to some thing known so that we can split by it
  ssh.setEnv("PS1", cmdSep)
  return ssh




