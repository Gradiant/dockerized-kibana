ARG base_image="docker.elastic.co/kibana/kibana"
ARG version="7.5.0"

FROM alpine:3.7 as builder
ARG version="7.5.0"
COPY kibana /kibana
RUN sed -i "7s/.*/    \"version\": \"${version}\"/" /kibana/gradiant_style/package.json
RUN apk add --no-cache zip
RUN zip -r /gradiant_style.zip kibana

FROM $base_image:$version
MAINTAINER cgiraldo@gradiant.org

# custom favicons
COPY favicons/* /usr/share/kibana/src/legacy/ui/public/assets/favicons/
COPY logo_grad_kibana.svg /usr/share/kibana/node_modules/@elastic/eui/src/components/icon/assets/logo_kibana.svg
COPY logo_grad_kibana.svg /usr/share/kibana/node_modules/@elastic/eui/lib/components/icon/assets/logo_kibana.svg

# custom throbber
RUN sed -i 's/Loading Kibana/Loading Gradiant/g' /usr/share/kibana/src/core/server/rendering/views/template.js
# To customize throbber logo open main.less and edit .kibanaWelcomeLogo { background-image: url(xxx); }

# custom HTML title information
RUN sed -i 's/title Kibana/title Gradiant/g' /usr/share/kibana/src/legacy/server/views/index.pug


# custom plugin css
COPY --from=builder /gradiant_style.zip /
RUN sed -i 's/reverse()/reverse(),`${regularBundlePath}\/gradiant_style.style.css`/g' /usr/share/kibana/src/legacy/ui/ui_render/ui_render_mixin.js

# Modify logoKibana in vendorsDynamicDLL to be empty. Custom icon will be set as background-image in gradiant_style plugin css

RUN sed -i 's@evenodd"}.*)))},@evenodd"}))},@g' /usr/share/kibana/node_modules/@kbn/ui-shared-deps/target/icon.logo_kibana-js.js


RUN bin/kibana-plugin install file:///gradiant_style.zip
RUN bin/kibana --env.name=production --logging.json=false --optimize


