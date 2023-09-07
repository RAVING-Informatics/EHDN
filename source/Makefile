CC=g++ -O3 -std=c++11 -static

BOOST_BASE=/illumina/thirdparty/boost/boost_1_54_0_python2.7/

BOOST_INC_DIR=${BOOST_BASE}/include
BOOST_LIB_DIR=${BOOST_BASE}/lib
BOOST_LIB_SPEC=-lboost_program_options -lboost_filesystem -lboost_system -lboost_regex -lboost_date_time -lpthread

SAMTOOLS_BASE=/home/edolzhenko/projects/htslib-1.9/
SAMTOOLS_INC_DIR=${SAMTOOLS_BASE}
SAMTOOLS_LIB_DIR=${SAMTOOLS_BASE}
# actually -lhts -lz BUT -lz already specified separately
SAMTOOLS_LIB_SPEC=-lhts -llzma

COMPR_LIB_SPEC=-lz -lbz2 #-lcurl -lcrypto #

SRC_DIR=app
INC_DIR=-I. -I/home/edolzhenko/projects/ExpansionHunterDenovo/source/thirdparty -I${SAMTOOLS_INC_DIR}
LIB_DIR=src
INSTALL_DIR=bin
BUILD_DIR=local-build

LIBS=${BUILD_DIR}/SequenceUtils.o ${BUILD_DIR}/MergeParameters.o \
     ${BUILD_DIR}/MergeWorkflow.o ${BUILD_DIR}/MultisampleProfile.o \
     ${BUILD_DIR}/HtsFileStreamer.o ${BUILD_DIR}/HtsHelpers.o \
     ${BUILD_DIR}/Reference.o ${BUILD_DIR}/GenomicRegion.o \
     ${BUILD_DIR}/ReferenceContigInfo.o ${BUILD_DIR}/PairCollector.o \
     ${BUILD_DIR}/ProfileParameters.o ${BUILD_DIR}/ProfileWorkflow.o \
     ${BUILD_DIR}/ReadClassification.o ${BUILD_DIR}/SampleRunStats.o \
     ${BUILD_DIR}/IrrFinder.o ${BUILD_DIR}/Purity.o ${BUILD_DIR}/Read.o \





all: ${BUILD_DIR} ${INSTALL_DIR} ${INSTALL_DIR}/ExpansionHunterDenovo

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR} 


${BUILD_DIR}/%.o: merge/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: io/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: region/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${SAMTOOLS_INC_DIR}

${BUILD_DIR}/%.o: reads/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: profile/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: sample_analysis/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: common/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: classification/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: reads/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: region_spec/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: alignment/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: stats/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: filtering/%.cpp
	${CC} -c -o $@ $< ${INC_DIR} -I ${BOOST_INC_DIR}

${BUILD_DIR}/%.o: ${LIB_DIR}/%.cpp 
	${CC} -c -o $@ $< -I ${BOOST_INC_DIR} ${INC_DIR}

${INSTALL_DIR}:
	mkdir -p ${INSTALL_DIR}

${INSTALL_DIR}/ExpansionHunterDenovo: ${SRC_DIR}/ExpansionHunterDenovo.cpp ${LIBS}
	${CC} -o $@ $^ -I ${SAMTOOLS_INC_DIR} \
	    -I ${BOOST_INC_DIR} ${INC_DIR} -L ${SAMTOOLS_LIB_DIR} -L ${BOOST_LIB_DIR} ${SAMTOOLS_LIB_SPEC} ${COMPR_LIB_SPEC} ${BOOST_LIB_SPEC} 

	    #-L /illumina/scratch/popdata/users/edolzhenko/anaconda3/lib/
