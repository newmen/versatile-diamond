NAME		:= vd-engine-spec

ENGINE_DIR	:= ..
ENGINE_SRC_DIR	:= $(ENGINE_DIR)/cpp
ENGINE_OBJS_DIR	:= $(ENGINE_DIR)/obj

HANDG_DIR	:= ../hand-generations
HANDG_SRC_DIR	:= $(HANDG_DIR)/src
HANDG_OBJS_DIR	:= $(HANDG_DIR)/obj

all:	$(NAME)
$(NAME):
	$(MAKE) -C $(ENGINE_DIR) ARKSFLAGS=""
	$(MAKE) -C $(HANDG_DIR) simple-diamond ARKSFLAGS=""

clean:
	rm -rf obj
	rm -rf $(ENGINE_OBJS_DIR)
	rm -rf $(HANDG_OBJS_DIR)

