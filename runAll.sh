echo "==> Extracting data of interest"
source ./extract.sh all sampleJson/testMe_flatten sampleJson/testMe_default sampleJson/testMe_joined

mkdir plots

echo "==> side by side comparison of PP PDW ES ES_AWD ES_aggregate_info FixedMetaInfoGather transport_0.wbytes "
echo "    for default & flatten types (joined and default are pretty identical)"

type1=default
type2=flatten


python3 plotRanks.py ${type1} ${type2} --set plotPrefix=plots/dvf jsonAttr=ES
python3 plotRanks.py ${type1} ${type2} --set plotPrefix=plots/dvf jsonAttr=ES_AWD
python3 plotRanks.py ${type1} ${type2} --set plotPrefix=plots/dvf jsonAttr=ES_aggregate_info levelAxis=True logScale=x
python3 plotRanks.py ${type1} ${type2} --set plotPrefix=plots/dvf jsonAttr=FixedMetaInfoGather  levelAxis=True logScale=xy
python3 plotRanks.py ${type1} ${type2} --set plotPrefix=plots/dvf jsonAttr=PDW
python3 plotRanks.py ${type1} ${type2} --set plotPrefix=plots/dvf jsonAttr=PP zeroIf=0.01

python3 plotRanks.py ${type1} ${type2} --set plotPrefix=plots/dvf jsonAttr=transport_0.wbytes  whichKind=MB

type3=joined
python3 plotRanks.py ${type1} ${type3} --set plotPrefix=plots/dvj jsonAttr=PP zeroIf=0.01

echo "==> plot all the times spent on rank 0"
python3 plotStack.py  ${type1} ${type2} ${type3} --set dataDir=outs whichRank=0 plotPrefix=plots/dfj

echo "==> plot numCalls occurred"
python3 plotCall.py ${type1} ${type2} ${type3} --set plotPrefix=plots/dvf

