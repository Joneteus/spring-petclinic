region=eu-north-1
app-name=joneteus-spring-petclinic

deploy-infra-pipeline:
		@aws cloudformation deploy \
			--region $(region) \
			--stack-name $(app-name)-infra-pipeline \
			--template-file cf_infra_pipeline.yaml \
			--capabilities CAPABILITY_NAMED_IAM

deploy-app-pipeline:
		@aws cloudformation deploy \
			--region $(region) \
			--stack-name $(app-name)-app-pipeline \
			--template-file cf_app_pipeline.yaml \
			--capabilities CAPABILITY_NAMED_IAM
