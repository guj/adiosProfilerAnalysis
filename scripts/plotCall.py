import matplotlib.pyplot as plt
import numpy as np
import csv
import sys
import os
import parseMe
# Sample data


def plotBars(ax, labels, summary, timeDesc=""):
    barWidth=0.40
    br = {}
    dataSize = len(summary[parseMe.args.ioTypes[0]])
    br[0] = np.arange(dataSize)
    for i in range(1, dataSize):
        br[i] = [x + barWidth for x in br[i-1]]

    for i in range(0, len(parseMe.args.ioTypes)):
        which = parseMe.args.ioTypes[i]
        ax.bar(br[i], summary[which], 0.4, label=which)
    ax.set_ylabel('NumCalls')
    ax.set_title('ADIOS numCalls:'+timeDesc)

    labels = ['PP', 'PDW', 'ES', 'ES\nAWD', 'ES\naggregate\ninfo', 'FixedMeta\nInfoGather']
    ax.set_xticks([r + barWidth for r in range(dataSize)], 
                  labels)
    # Add legend
    ax.legend()

def summarizeFile(inputFile, whichRank=0):
    data = csv.reader(open(inputFile, 'r'), delimiter=",", quotechar='|')

    data1 = np.array([row[0] for row in data], dtype=float)
    return int(data1[0]);

if __name__ == "__main__": 
    print("Script name:", sys.argv[0])
    if len(sys.argv) < 2:
        print("Need Arguments for files" )
        sys.exit()

    keywords = ['PP', 'PDW', 'ES', 'ES_AWD', 'ES_aggregate_info', 'FixedMetaInfoGather']
    summary = {}
    barLabels = []
    for key in parseMe.args.ioTypes:
        summary[key]=[]
        
    fig, ax1 = plt.subplots()

    print (parseMe.args.ioTypes)
    whichRank = parseMe.command_options[parseMe.TAGS["rank"]];
    #for i in range(0, len(parseMe.args.ioTypes)):    
        #which=sys.argv[i] ## default flatten joined
    #    which=parseMe.args.ioTypes[i]
    for which in parseMe.args.ioTypes:
        barLabels.append(which);
        for key in keywords:
            inputFile=parseMe.command_options[parseMe.TAGS["input_dir"]]+which+"_nCalls_"+key
            if (os.path.exists(inputFile)):
                summary[which].append( summarizeFile(inputFile, whichRank) )
            else:
                summary[which].append( 0 )

    print (barLabels)

    if (len(summary[parseMe.args.ioTypes[0]]) == 0):
        print ("Nothing to plot")
        sys.exit()

    plotBars(ax1, keywords, summary)
    plt.legend()
    
        # Show plot
    plt.tight_layout()
    figName = parseMe.command_options[parseMe.TAGS["out"]] +"_nCalls"

    print (figName)
    plt.savefig(figName)
    plt.show()





