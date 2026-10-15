# xspress IOC start-up script.
#
# Run it from this directory, which holds envPaths (TOP and the support module
# paths, written by make):
#   ../../bin/linux-x86_64/xspress stxspress.boot
# A copy elsewhere works too, as long as the IOC starts in this directory.
#
# XSPRESS_NUM_CARDS (environment, default 4) is the number of cards: one frame
# receiver / frame processor pair and two channels per card. It selects
# db/xspress_<N>card.db; the IOC stops if there is none for the value.
#
# odin-control must listen on 127.0.0.1:8888 and the live view merge must
# publish on tcp://127.0.0.1:15550.
# EPICS_CA_MAX_ARRAY_BYTES must be large enough for the live view array
# (XSPRESS:ARR).

< envPaths

# -------------------------------------------
# Environment variables
# -------------------------------------------

epicsEnvSet "EPICS_TS_MIN_WEST", '0'
epicsEnvSet "XSPRESS_NUM_CARDS", "$(XSPRESS_NUM_CARDS=4)"

# Stop on any error until the database is loaded (e.g. no database for
# XSPRESS_NUM_CARDS).
on error halt

# -------------------------------------------
# Device initialisation
# -------------------------------------------

dbLoadDatabase "$(TOP)/dbd/xspress.dbd"
xspress_registerRecordDeviceDriver(pdbbase)

callbackSetQueueSize(400000)

# odinDataDriverConfig(const char * portName, const char * serverPort, int odinServerPort, int odinDataCount, const char * datasetName, const char * detectorName, int maxBuffers, size_t maxMemory)
odinDataDriverConfig("ODN.OD", "127.0.0.1", 8888, $(XSPRESS_NUM_CARDS), "data", "xspress", 0, 0)

# odinDetectorConfig(const char * portName, const char * serverPort, int odinServerPort, const char * detectorName, int maxBuffers, size_t maxMemory, int priority, int stackSize)
odinDetectorConfig("ODN.CAM", "127.0.0.1", 8888, "xspress", 0, 0)

# NDStdArraysConfigure(portName, queueSize, blockingCallbacks, NDArrayPort, NDArrayAddr, maxBuffers, maxMemory, priority, stackSize, maxThreads)
NDStdArraysConfigure("ODN.ARR", 100, 0, "ODN.CAM", 0, 0, 0, 0, 0, 1)

dbLoadRecords "$(TOP)/db/xspress_$(XSPRESS_NUM_CARDS)card.db"

on error continue

# -------------------------------------------
# Final IOC initialisation
# -------------------------------------------

iocInit

# -------------------------------------------
# Update initial PV values
# -------------------------------------------

dbpf "XSPRESS:OD:ReadStatus.SCAN", "7"
dbpf "XSPRESS:CAM:ReadStatus.SCAN", "7"
dbpf "XSPRESS:CAM:LiveViewEndpoint", "tcp://127.0.0.1:15550"

dbpf "XSPRESS:CAM:TriggerMode", "2"

dbpf "XSPRESS:OD:FilePath", "/tmp"
dbpf "XSPRESS:OD:FileName", "example"

# -------------------------------------------
# Reconfigure and wait to reconnect
# -------------------------------------------

dbpf "XSPRESS:CAM:RECONFIGURE", "1"

# Wait for configure to complete
epicsThreadSleep (5.0)

# -------------------------------------------
# Odin PVs which can be lost from reconfigure
# -------------------------------------------
dbpf "XSPRESS:OD:ImageHeight", "1"
dbpf "XSPRESS:OD:ImageWidth", "4096"
dbpf "XSPRESS:OD:NumFramesChunks", "1"
dbpf "XSPRESS:OD:NumRowChunks", "1"
dbpf "XSPRESS:OD:NumColChunks", "4096"

# -------------------------------------------
# Enable NDStdArrays callbacks for live view
# -------------------------------------------
dbpf "XSPRESS:ARR:EnableCallbacks", "Enable"
