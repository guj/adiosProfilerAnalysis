import sys
import numpy as np
import matplotlib.pyplot as plt


attr_ES="ES_"
attr_Fix="FixedMetaInfoGather_"

def getLineCount(r):
    fname="/tmp/"+attr_ES+str(r)+".start"
    
    with open(fname, 'r') as fp:
        lines = len(fp.readlines())
        print('Total Number of lines:', lines)
        return lines
    return 0
    
def getInfo(attr, whichRank):
    fStart="/tmp/"+attr+str(whichRank)+".start"
    fDur  ="/tmp/"+attr+str(whichRank)+".dur"
    array1 = read_csv_array(fStart)
    #print ("read", fStart)
    array2 = read_csv_array(fDur)
    # Validate arrays
    if array1.shape != array2.shape:
        raise ValueError("Arrays must have the same length for plotting")        
    return list(zip(array1, array2))

def read_csv_array(filename):
    """Read a float array from a single-column CSV file."""
    try:
        # Load CSV, assuming one column, no header
        array = np.loadtxt(filename, dtype=float, delimiter=',')
        if array.ndim != 1:
            raise ValueError("CSV file must contain a single column of floats")
        return array
    except FileNotFoundError:
        raise FileNotFoundError(f"File {filename} not found")    
    except ValueError as e:
        raise ValueError(f"Error reading {filename}: {str(e)}")

    
def plot_rank_gantt(gnt, rank1, fc, yrange):
    height= yrange[1]
    
    try:        
        info1 = getInfo(attr_ES, rank1)
        info2 = getInfo(attr_Fix, rank1)
        
        for step in range(0, len(info1)):
            row = int(step/3)
            col = step % 3
            gnt[row, col].grid(True)            
            #gnt[row, col].text(info1[step][0]+info1[step][1]/3, yrange[0], "rank: "+str(rank1), color='lime')
            gnt[row, col].broken_barh([info1[step]], yrange, facecolors = fc, label="for "+str(rank1))
            if (info2[step][1] > 1):
                gnt[row, col].broken_barh([info2[step]], (yrange[0]+height/3, height/2), facecolors = 'tab:orange', label="for "+str(rank1))
            else:
                tmp=(info2[step][0], min(info1[step][1]/10, 5))
                gnt[row, col].broken_barh([tmp], (yrange[0]+height/3, height/2), facecolors = 'red', label="for "+str(rank1))
            
    except Exception as e:
        print(f"An unexpected error occurred: {e}") 
                    

    
def main():
    # Check command-line arguments
    if len(sys.argv) < 2:
        print("Usage: python plot_csv_arrays.py rank1 (optional: more ranks)")
        print("  note: if there are two input ranks, r1, r2, and r1 < r2, then all ranks between r1 r2 will be plotted")
        sys.exit(1)

    rank1 = int(sys.argv[1])
    rank2 = -1;

    numLines = getLineCount(rank1)

    nCols = 3
    nRows = int(numLines/nCols)
    print (nRows, nCols)
    if (numLines % nCols > 0):
        nRows = nRows + 1
    try:
        fig, gnt = plt.subplots(nRows, nCols, sharey=True, figsize=(20, 15))
            
        # Setting graph attribute
        if (len(sys.argv) >= 3):
            rank2 = int(sys.argv[2])

        yticks=[''];
        if ( (rank1 < rank2) and (len(sys.argv) == 3) ):
            for r in range(rank1, rank2+1):
                yticks.append("rank "+str(r))
                c = 'tab:gray'
                if r % 2 == 0:
                    c = 'tab:cyan'
                yrange = (r-0.3, 0.6)                    
                plot_rank_gantt(gnt, r, c, yrange)
        else:        
            for i in range(1, len(sys.argv)):
                rr = int(sys.argv[i])
                yrange = (i-0.4, 0.8)                
                plot_rank_gantt(gnt, rr, 'tab:gray', yrange)
                yticks.append("rank "+str(rr))
                #height = max(5, (rank1-rank2)/3)
            #gnt[0,0].set_yticks(range(0, len(sys.argv)))
            #gnt[0,0].set_yticklabels(['11', '22', '33', '44'])
        gnt[0,0].set_yticks(range(0, len(yticks)))    
        gnt[0,0].set_yticklabels(yticks);

        if (numLines % nCols > 0):
            gnt[nRows-1, nCols-1].set_visible(False)
        plt.tight_layout()
        plt.savefig("gantt1.png")
        plt.show()
        plt.close()
        
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
