#include /etc/garmin-connectiq/Makefile.ciq
include Makefile.ciq

MY_PROJECT := lallassu
CIQ_DEVICE ?= fr255m
DEVICE_ID := 3965
MY_JUNGLES := monkey.jungle

# Support building for both devices
.PHONY: all-devices
all-devices:
	$(MAKE) release CIQ_DEVICE=fr255m
	$(MAKE) release CIQ_DEVICE=fr255sm

.PHONY: debug-all
debug-all:
	$(MAKE) debug CIQ_DEVICE=fr255m
	$(MAKE) debug CIQ_DEVICE=fr255sm

# Build for specific devices
.PHONY: fr255m
fr255m:
	$(MAKE) run-release CIQ_DEVICE=fr255m

.PHONY: fr255m-debug
fr255m-debug:
	$(MAKE) run-debug CIQ_DEVICE=fr255m

.PHONY: fr255sm
fr255sm:
	$(MAKE) run-release CIQ_DEVICE=fr255sm

.PHONY: fr255sm-debug
fr255sm-debug:
	$(MAKE) run-debug CIQ_DEVICE=fr255sm
