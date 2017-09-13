env    = PATH=./env/bin:${PATH}
image  = biobox_testing/unicycler

ssh: env
	#@$(env) biobox login short_read_assembler $(image)
	docker run \
		-v $(abspath biobox_verify)/input:/bbx/input:ro \
		-v $(abspath biobox_verify)/output:/bbx/output:rw \
		-it \
		--entrypoint=/bin/bash \
		$(image)

test: .image env
	@$(env) biobox verify short_read_assembler $(image) --verbose
	@$(env) biobox verify short_read_assembler $(image) --verbose --task=conservative
	@$(env) biobox verify short_read_assembler $(image) --verbose --task=bold

build: .image

.image: $(shell find image -type f) Dockerfile
	@docker build --tag $(image) .
	@touch $@

env:
	@virtualenv -p python3 $@
	@$@/bin/pip install biobox_cli
