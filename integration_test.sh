UNZIPED=./data_package
JAR=target/scala-2.12/FlashFry-assembly-1.9.8.jar
TEST_DATABASE=$UNZIPED/chr22_cas9ngg_database
MD5SUM=md5 # this is mac specific, change for linux

mkdir tmp

# #############################################################
#
# generate the database of targets from the example fasta file
#
# #############################################################
java -Xmx4g -jar $JAR \
     index \
     --tmpLocation ./tmp \
     --database $UNZIPED/chr22_cas9ngg_database \
     --reference $UNZIPED/chr22.fa.gz \
     --enzyme spcas9ngg


# #############################################################
#
# discover off-targets without and with off-target positions
#
# #############################################################
java -Xmx4g -jar $JAR \
     discover \
     --database $UNZIPED/chr22_cas9ngg_database \
     --fasta $UNZIPED/EMX1_GAGTCCGAGCAGAAGAAGAAGGG.fasta \
     --output $UNZIPED/EMX1.output

java -Xmx4g -jar $JAR \
     discover \
     --database $UNZIPED/chr22_cas9ngg_database \
     --fasta $UNZIPED/EMX1_GAGTCCGAGCAGAAGAAGAAGGG.fasta \
     --output $UNZIPED/EMX1.output.with_positions \
     --positionOutput


# #############################################################
#
# score the resulting targets with common metrics
#
# #############################################################
java -Xmx4g -jar $JAR \
     score \
     --input $UNZIPED/EMX1.output \
     --output $UNZIPED/EMX1.output.scored \
     --scoringMetrics doench2014ontarget,doench2016cfd,DanGerous,hsu2013,minot \
     --database $UNZIPED/chr22_cas9ngg_database

java \
    -jar $JAR \
    score  \
    --input $UNZIPED/EMX1.output \
    --output $UNZIPED/EMX1.output.scored_with_ots \
    --scoringMetrics doench2014ontarget,doench2016cfd,dangerous,hsu2013,minot \
    --database $UNZIPED/chr22_cas9ngg_database \
    --includeOTs

java \
    -jar $JAR \
    score  \
    --input $UNZIPED/EMX1.output \
    --output $UNZIPED/EMX1.output.scored_with_ots.all \
    --scoringMetrics hsu2013,doench2014ontarget,doench2016cfd,moreno2015,bedannotator,dangerous,minot,reciprocalofftargets,rank  \
    --database $UNZIPED/chr22_cas9ngg_database \
    --includeOTs

java \
    -jar $JAR \
    score  \
    --input $UNZIPED/EMX1.output.with_positions \
    --output $UNZIPED/EMX1.output.with_positions.scored \
    --scoringMetrics hsu2013,doench2014ontarget,doench2016cfd,moreno2015,bedannotator,dangerous,minot,reciprocalofftargets,rank  \
    --database $UNZIPED/chr22_cas9ngg_database \
    --includeOTs


# check all three output files - this uses 
$MD5SUM -q $UNZIPED/EMX1.output | xargs -I {} test 895e282bf486c359667e2c3e0e0e0260 = {}
echo "discovery OK if 0 == " $?

$MD5SUM -q $UNZIPED/EMX1.output.scored | xargs -I {} test d8ba6c2e619cfa811d63992436ccbf7d = {}
echo "scoring without OTs OK if 0 == " $?

$MD5SUM -q $UNZIPED/EMX1.output.scored_with_ots | xargs -I {} test 9b6ef85f0e54b8ff017cedcc8c7ceb15 = {}
echo "scoring with OT output  OK if 0 == " $?

$MD5SUM -q $UNZIPED/EMX1.output.with_positions.scored | xargs -I {} test 5d260a04bdf98166c7500690ee092476 = {}
echo "scoring with OT output and position OK if 0 == " $?

rm -r ./tmp
