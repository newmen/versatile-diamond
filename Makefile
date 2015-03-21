MCS_DIR		:= analyzer/lib/mcs

all:
	$(MAKE) -C $(MCS_DIR)

clean:
	$(MAKE) clean -C $(MCS_DIR)
