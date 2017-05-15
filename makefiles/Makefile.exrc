#RECURSIVE=NO
DO_PRINT_DEPENDS := .tbexrc .tags

export TESTS := NO
EXRC_PL := ~/.bin/tbexrc.pl

DO_CLEAN += rm-tags-dependency-files
include Makefile

SOURCES.cpp := $(filter $(addprefix %.,cpp cxx C cc c++),$(SOURCES))
SOURCES.cc := $(filter $(addprefix %.,c s S),$(SOURCES))

# 2 -- TAG_DEP_SCR := -n -e ':loop /\\$$/{N; b loop;}' -e 's/.o: /.tags: /p;'

.tbexrc:  $(EXRC_PL)
	@${ECHO} "#   build $@"
	#@${ECHO} "INCLUDES:$(INCLUDES)"
	#@${ECHO} "DEFFLAGS:$(DEFFLAGS)"
	#@${ECHO} "SOURCES:$(SOURCES)"
	#@${ECHO} "CURRDIR:$(MK_CURDIR)"
	${PERL} $(EXRC_PL) ${INCLUDES} ${DEFFLAGS} ${SOURCES} \
		--MK_BUILD_PRJDIR:${MK_BUILD_PRJDIR}

# 2 -- ${MK_BUILD_PRJDIR}/.tags.dep: $(SOURCES.cpp) $(SOURCES.c)
# 2 -- 	@${ECHO} "# build $(notdir $@)"
# 2 -- 	${CXX} ${CXXFLAGS.mkdep} $(CXXFLAGS) $(DEFFLAGS) $(INCLUDES) $(SOURCES.cpp) | \
# 2 -- 		sed ${TAG_DEP_SCR} > $@
# 2 -- 	${CC} ${CFLAGS.mkdep} $(CCFLAGS) $(DEFFLAGS) $(INCLUDES) $(SOURCES.cc) | \
# 2 -- 		sed ${TAG_DEP_SCR} >> $@

.tags:  $(SOURCES.cpp) $(SOURCES.c)
	@$(ECHO) "#   build $@"
	${CXX}  > $@.tmp \
		${CXXFLAGS.mkdep} $(CXXFLAGS) $(DEFFLAGS) $(INCLUDES) $(SOURCES.cpp)
	${CC}  >> $@.tmp \
		${CFLAGS.mkdep} $(CCFLAGS) $(DEFFLAGS) $(INCLUDES) $(SOURCES.cc)
	$(CAT) $@.tmp | \
		$(SED) -e "s/[\ ]/\n/g" | \
		$(SED) -e "/^$$/d" -e "/\.o:[ \t]*$$/d"| \
		$(SED) -e "s/:$$//" | \
		sort -u | \
		ctags -L - --c++-kinds=+p --fields=+iaS --extra=+q -f$@
	$(RM) $@.tmp
	@$(ECHO) "#   tags generated."

# - 1 - define tags-rule
# - 1 - $(1).tags: $(1)
# - 1 - 	echo "# build $@ from: $^"
# - 1 - tags: $(1)
# - 1 - endef
# - 1 - 
# - 1 - S := $$$$
# - 1 - 
# - 1 - define tags_dep-rule
# - 1 - $(1).tagsdep: $(1).srcdep
# - 1 - 	@${ECHO} "#  tags dep $(notdir $(basename $1))"
# - 1 - 	sed $$< >$$@  -n \
# - 1 - 		-e ':loop /\\${S}/{N; b loop;}' \
# - 1 - 	   	-e 's/$(notdir $(1)): /$(notdir $(1)).tags: /p;'
# - 1 - include $(1).tagsdep
# - 1 - endef
# - 1 - $(foreach d,$(basename ${DEPENDENCY_FILES}), \
# - 1 - 	$(eval $(call tags_dep-rule,${d})) \
# - 1 - )
# - 1 - 
# - 1 - $(foreach s,$(filter $(addprefix %.,cpp cxx c S s C), $(SOURCES)), \
# - 1 - 	$(eval $(call tags-rule,${s}))\
# - 1 - )
# - 1 - .PHONY: rm-tags-dependency-files
# - 1 - rm-tags-dependency-files:
# - 1 - 	$(RM) $(DEPENDENCY_FILES:%.srcdep=%.tagsdep)


