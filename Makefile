

.PHONY: dist


dist:
	deb-pm

clean:
	git checkout HEAD -- dist
	git clean -fd dist


test:
	$(MAKE) -C lab build
	-$(MAKE) -C lab stop
	sleep 1
	$(MAKE) -C lab start
	$(MAKE) -C lab install-loi
	$(MAKE) -C lab check-loi
	$(MAKE) -C lab hack-sources
	$(MAKE) -C lab install-groom
	$(MAKE) -C lab check-groom
	$(MAKE) -C lab purge-groom
	$(MAKE) -C lab check-purge
	
	$(MAKE) -C lab stop