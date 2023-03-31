IPS = $(filter-out run,$(patsubst %.tcl,%,$(wildcard *.tcl)))


.PHONY: clean

all: $(IPS)

$(IPS):
	mkdir -p $@ && cd $@ && exec vivado -mode batch -source ../run.tcl -tclargs $@

clean:
	rm -rf $(IPS)
