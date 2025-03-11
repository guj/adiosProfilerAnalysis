import matplotlib.pyplot as plt
import numpy as np
import csv
import sys
import os
import parseMe
# Sample data


def drawBars(ax, labels, summary, timeDesc):
    ax.bar(labels, summary['ES'], 0.6, label='ES')
    if (len(summary['PP']) > 0):
        ax.bar(labels, summary['PP'], 0.6, bottom=summary['ES'],  label='PP')
    if (len(summary['PDW']) > 0):
        ax.bar(labels, summary['PDW'], 0.6, bottom=summary['ES'],  label='PDW')
    ax.bar(labels, summary['ES_aggregate_info'], 0.4, label='ES_aggregation_info')
    ax.bar(labels, summary['ES_AWD'], 0.4, bottom=summary['ES_aggregate_info'], label='ES_AWD')
    ax.bar(labels, summary['FixedMetaInfoGather'], 0.2, label='ES_fixedMetaInfoGather')
        
    ax.set_ylabel('Secs')
    ax.set_title('ADIOS Time:'+timeDesc)
    
    ax.legend()

    
def summarizeFile(inputFile, whichRank=0):
    data = csv.reader(open(inputFile, 'r'), delimiter=",", quotechar='|')
    
    data1 = np.array([row[0] for row in data], dtype=float)

    if (whichRank < 0):
        return np.max(data1)
    elif whichRank < len(data1) :
        return data1[whichRank]
    else:
        return data1[0];

    
if __name__ == "__main__": 
    print("Script name:", sys.argv[0])
    if len(sys.argv) < 2:
        print("Need Arguments for files" )
        sys.exit()

    keywords = ['PP', 'PDW', 'ES', 'ES_AWD', 'ES_aggregate_info', 'FixedMetaInfoGather']
    summary = {}
    barLabels = []
    for key in keywords:
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
            inputFile=parseMe.command_options[parseMe.TAGS["input_dir"]]+which+"_secs_"+key
            if (os.path.exists(inputFile)):
                summary[key].append( summarizeFile(inputFile, whichRank) )
            else:
                print ("No such file: "+inputFile)

    print ("summary = ", summary)
    print (barLabels)

    if (len(summary['ES']) == 0):
        print ("Nothing to plot")
        sys.exit()

    timeDesc="Rank "+str(whichRank)        
    if (whichRank == -1):
        timeDesc = "Max"
    drawBars(ax1, barLabels, summary, timeDesc)
    plt.legend()
    
        # Show plot
    plt.tight_layout()
    figName = parseMe.command_options[parseMe.TAGS["out"]]  
    if (whichRank < 0):    
        figName += "_max";
    else:
        figName +="_rank_"+str(whichRank)
        
    print (figName)
    parentDir=os.path.dirname(figName)
    
    if (os.path.isdir(parentDir)):        
        print (figName)
        plt.savefig(figName)
    else:
        print ("Missing directory! Can not save", parentDir)
        
    
    #plt.savefig(figName)
    plt.show()





