TOP = ../../..
include $(TOP)/configure/CONFIG

# The GUI launcher and its desktop entry (share/applications), with the
# install paths filled in.
SCRIPTS += stxspress-gui
TARGETS += qd-xspress-gui.desktop

include $(TOP)/configure/RULES

GUI_SUBST = -e 's|@TOP@|$(abspath $(INSTALL_LOCATION))|g' \
    -e 's|@ARCH@|$(T_A)|g' \
    -e 's|@ASYN@|$(ASYN)|g' \
    -e 's|@ADCORE@|$(ADCORE)|g' \
    -e 's|@ADODIN@|$(ADODIN)|g' \
    -e 's|@PROCSERVCONTROL@|$(PROCSERVCONTROL)|g' \
    -e 's|@XSPRESS_GUI_ENV@|$(XSPRESS_GUI_ENV)|g' \
    -e 's|@XSPRESS_IOC_ENV@|$(XSPRESS_IOC_ENV)|g'
GUI_DEPS = $(wildcard $(TOP)/configure/RELEASE* $(TOP)/configure/CONFIG_SITE*)

stxspress-gui: ../stxspress-gui.in $(GUI_DEPS)
	sed $(GUI_SUBST) $< > $@

qd-xspress-gui.desktop: ../qd-xspress-gui.desktop.in $(GUI_DEPS)
	sed $(GUI_SUBST) $< > $@

DESKTOP_DIR = $(INSTALL_LOCATION)/share/applications
buildInstall: $(DESKTOP_DIR)/qd-xspress-gui.desktop
$(DESKTOP_DIR)/%.desktop: %.desktop
	$(INSTALL) -d -m 644 $< $(@D)
