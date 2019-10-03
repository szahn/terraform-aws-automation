FROM hashicorp/terraform:0.12.7

ARG AWS_PROVIDER_VERSION

VOLUME ["/temp", "/plan"]

COPY ./scripts/terraform-init.sh ./terraform-init.sh

ENTRYPOINT ["./terraform-init.sh"]