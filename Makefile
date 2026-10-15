# Makefile at top of application tree
TOP = .
include $(TOP)/configure/CONFIG

DIRS += configure
DIRS += xspressApp
DIRS += iocBoot

xspressApp_DEPEND_DIRS += configure
iocBoot_DEPEND_DIRS += xspressApp

include $(TOP)/configure/RULES_TOP
