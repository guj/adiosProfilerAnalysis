import argparse, textwrap
parser = argparse.ArgumentParser(description="ADIOS json file parser step 2 (step 1 is use compare.sh to collect properties from json)")

TAGS={
      "input_dir": "dataDir", ## key name for input direcory is "dataDir"
      "rank": "whichRank",    ## 
      "out": "plotPrefix",    ##
      "attr": "jsonAttr",     ## key refer to specific json attr
      "zero": "zeroIf",       ## key refer to a min number to be treated as 0. Spot the first rank with this value, and only plot up to this rank.
      "level": "levelAxis" 
      }

TAGS_DEFAULT={
      "input_dir": "outs/",   ## key name for input direcory defaults to "outs/"
      "rank": 0,              ## 
      "out": "plot",          ##
      "attr": "ES",           ## default json attr to look at is ES
      "zero": "0.000001",     ## ignore if smaller than
      "level": 'False'        ## whether left/right axises (if both exist) should display same range       
      }
      
parser.add_argument("ioTypes",
                    nargs="+",
                    help="A list of known adios types in the output directory.\n"
                         "Will be accessed as ["+TAGS["input_dir"]+"]/[ioType]_<secs/nCalls>_[profileTag]"
                         "e.g. outs/flatten_nCalls_ES")

helpWithDefaults=""
for k in TAGS:
    helpWithDefaults += TAGS[k] + "(default: "+ str(TAGS_DEFAULT[k])+")  "
    
parser.add_argument("--set",
                    metavar="key=value",
                    nargs='+',
                    help="The names of accepted options: "  + helpWithDefaults
                    )
args = parser.parse_args()

#print (args.set)
#print (args.file_key)

def parse_var(s):
    """
    Parse a key, value pair, separated by '='
    That's the reverse of ShellArgs.

    On the command line (argparse) a declaration will typically look like:
        foo=hello
    or
        foo="hello world"
    """
    items = s.split('=')
    key = items[0].strip() # we remove blanks around keys, as is logical
    if len(items) > 1:
        # rejoin the rest:
        value = '='.join(items[1:])
    return (key, value)


def parse_vars(items):
    """
    Parse a series of key-value pairs and return a dictionary
    """
    d = {}

    if items:
        for item in items:
            key, value = parse_var(item)
            d[key] = value
    return d

# parse the key-value pairs

command_options = parse_vars(args.set)

for k in TAGS:
    if TAGS[k] not in command_options:
        command_options[TAGS[k]] = TAGS_DEFAULT[k] 
        
if (not command_options[TAGS["input_dir"]].endswith("/")):
    command_options[TAGS["input_dir"]]+="/"


print (command_options)    
command_options[TAGS["rank"]] = int(command_options[TAGS["rank"]])
command_options[TAGS["zero"]] = float(command_options[TAGS["zero"]])

command_options[TAGS["level"]] = eval(command_options[TAGS["level"]])

print (command_options)
