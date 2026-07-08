FROM quay.io/astronomer/astro-runtime:11.3.0

USER root
# O libpq-dev é quem fornece o pg_config que estava faltando!
RUN apt-get update && apt-get install -y libpq-dev gcc python3-dev

USER astro