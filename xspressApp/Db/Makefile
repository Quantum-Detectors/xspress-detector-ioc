TOP = ../..
include $(TOP)/configure/CONFIG

# Card counts the IOC can start with (XSPRESS_NUM_CARDS in the start-up
# script): one database per count, db/xspress_<N>card.db. Each count needs a
# matching OdinDataStatus<N>.edl screen from ADOdin.
XSPRESS_CARD_COUNTS = 1 2 4 8 9 16

DB += $(XSPRESS_CARD_COUNTS:%=xspress_%card.db)

include $(TOP)/configure/RULES

# The substitutions for <N> cards (2 channels per card).
xspress_%card.substitutions: ../xspress-substitutions.sh
	$(SHELL) $< $* > $@
