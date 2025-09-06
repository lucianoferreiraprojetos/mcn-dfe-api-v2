FROM desenvolmcn/ubuntu-delphi:22.04

ENV MCN_DFE_API_APP_PORT=8080

RUN mkdir -p /apps/mcn-sistemas/mcn-dfe-api/bin
RUN mkdir -p /apps/mcn-sistemas/mcn-dfe-api/schemas
RUN mkdir -p /apps/mcn-sistemas/mcn-dfe-api/logs
RUN mkdir -p /apps/mcn-sistemas/mcn-dfe-api/dbscripts
RUN mkdir -p /apps/mcn-sistemas/mcn-dfe-api/conf
RUN mkdir -p /apps/mcn-sistemas/mcn-dfe-api/download_xml

WORKDIR /apps/mcn-sistemas/mcn-dfe-api/

COPY ./schemas/ ./schemas/
COPY ./dbscripts/ ./dbscripts/

COPY ./bin/mcndfeapi ./bin/

CMD [ "./bin/mcndfeapi" ]