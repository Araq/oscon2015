
import strutils, os, re

proc main(file: string) =
  discard execShellCmd("nim rst2html $1.rst" % file)

  const
    patternA = "<span class\\=\"Operator\">***</span>" &
               "(.*)" &
               "<span class\\=\"Operator\">***</span>"

  proc writeln(buf: var string; x: string) = buf.add x & "\n"

  proc tline(line: string): string =
    result = line.replacef(re(patternA.replace("***", r"\*\*\*"), {}),
                            "<span style=\"background-color:#FF7700\">$1</span>")
    result = result.replacef(re(patternA.replace("***", r"\+\+\+"), {}),
                   "<span style=\"background-color:#FFFF00\">$1</span>")
    result = result.replacef(re(patternA.replace("***", r"\=\=\="), {}),
                   "<span style=\"background-color:#7777FF\">$1</span>")

  var f = ""
  var count = 0
  for line in lines("$1.html" % file):
    if line.contains("<h1"):
      inc count
      if count != 1:
        f.writeln("</div>")
      f.writeln("<div class=\"slide\">")
      f.writeln(line.tline)
    elif line.contains("<h2 "):
      f.writeln("</div><div class=\"slide\" class=\"incremental\">")
      let a = line.replace("<h2 ", "<h1 ").replace("</h2>", "</h1>")
      f.writeln(a.tline)
    elif line.contains("</html>"):
      f.writeln("</div>")
      f.writeln(line.tline)
    else:
      f.writeln(line.tline)
  writeFile("$1.html" % file, f)

for x in os.walkFiles("*.rst"):
  main(x.splitFile.name)
