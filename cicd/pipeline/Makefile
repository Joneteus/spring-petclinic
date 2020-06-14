region=eu-north-1
stack_name=joneteus-spring-petclinic-cicd

deploy:
		@aws cloudformation deploy \
			--region $(region) \
			--stack-name $(stack_name) \
			--template-file cf_pipeline.yaml \
			--capabilities CAPABILITY_NAMED_IAM