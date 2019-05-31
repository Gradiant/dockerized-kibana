FROM alpine:3.7 as builder
COPY kibana /kibana
RUN apk add --no-cache zip
RUN zip -r /gradiant_style.zip kibana

FROM docker.elastic.co/kibana/kibana:7.0.1
MAINTAINER cgiraldo@gradiant.org

# custom favicons
COPY favicons/* /usr/share/kibana/src/legacy/ui/public/assets/favicons/
COPY logo_grad_kibana.svg /usr/share/kibana/node_modules/@elastic/eui/src/components/icon/assets/logo_kibana.svg
COPY logo_grad_kibana.svg /usr/share/kibana/node_modules/@elastic/eui/lib/components/icon/assets/logo_kibana.svg

# custom throbber
RUN sed -i 's/Loading Kibana/Loading Gradiant/g' /usr/share/kibana/src/legacy/ui/ui_render/views/ui_app.pug
RUN sed -i 's/image\/svg+xml.*");/image\/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+DQo8c3ZnDQogICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iDQogICB4bWxuczpjYz0iaHR0cDovL2NyZWF0aXZlY29tbW9ucy5vcmcvbnMjIg0KICAgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIg0KICAgeG1sbnM6c3ZnPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyINCiAgIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyINCiAgIHZlcnNpb249IjEuMSINCiAgIGlkPSJzdmcyIg0KICAgdmlld0JveD0iMCAwIDE1NC4wMyAyMDAuMTEiPg0KICA8bWV0YWRhdGENCiAgICAgaWQ9Im1ldGFkYXRhMzAiPg0KICAgIDxyZGY6UkRGPg0KICAgICAgPGNjOldvcmsNCiAgICAgICAgIHJkZjphYm91dD0iIj4NCiAgICAgICAgPGRjOmZvcm1hdD5pbWFnZS9zdmcreG1sPC9kYzpmb3JtYXQ+DQogICAgICAgIDxkYzp0eXBlDQogICAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+DQogICAgICAgIDxkYzp0aXRsZT5Mb2dvLUtpYmFuYUljb248L2RjOnRpdGxlPg0KICAgICAgPC9jYzpXb3JrPg0KICAgIDwvcmRmOlJERj4NCiAgPC9tZXRhZGF0YT4NCiAgPGRlZnMNCiAgICAgaWQ9ImRlZnMyOCIgLz4NCiAgPHRpdGxlDQogICAgIGlkPSJ0aXRsZTQiPkxvZ28tS2liYW5hSWNvbjwvdGl0bGU+DQogIDxwYXRoDQogICAgIHN0eWxlPSJmaWxsOiNlYjIwMjY7ZmlsbC1vcGFjaXR5OjE7b3BhY2l0eTowLjUiDQogICAgIGlkPSJwYXRoOSINCiAgICAgZD0iTSAxNTMuNDM2MjYsMTIyLjYwNzA4IEMgMTMwLjY0NjgsMTA3Ljc1Mjk2IDkwLjQwNTEzMSwxMzYuOTUyODcgNzcuMDE5NDgxLDE0NS41NjU5OSA1NC41OTcxMTgsMTU5Ljk5NjQ5IDE4LjYxOTcwMiwxNzAuNTI5OTMgMC4wMzc5MzMxMiwxNDcuOTA5OTIgMzAuNDgwMzc4LDE1MC4yNTM4IDMwLjgxOTI2MSwxMTMuMTc1MDEgMzAuMjI2MjE1LDkyLjYxNjQ3MyBjIC0wLjczNDIzMywtMjUuNDE1NzY0IDIuODI0LC00OC4xNzcwMSAyMy40MTA3NiwtNjQuNjY5MDM2IC0xLjU1MzE4OCwxMC42NDYzNjkgLTMuNjQyOTE2LDIwLjg0MDkyMSA2LjI5NzQ3NCwzMi41MzIxOTUgOC40NzE5MjIsOS44ODM5MjIgMjEuNzE2MzgzLDE1LjI3NzcyIDM0LjAyODg3NywxOC4zMjc1OSAyNC41Njg2MDQsNi4wNDMzMTIgNTEuMTk4NzA0LDE2LjY4OTY3NyA1OS40NzI5MzQsNDMuNzk5ODU4Ig0KICAgICBjbGFzcz0iY2xzLTEiIC8+DQo8L3N2Zz4=");/g' /usr/share/kibana/src/legacy/ui/ui_render/views/ui_app.pug /usr/share/kibana/src/legacy/ui/ui_render/views/chrome.pug

# custom HTML title information
RUN sed -i 's/title Kibana/title Gradiant/g' /usr/share/kibana/src/legacy/ui/ui_render/views/chrome.pug

# custom plugin css
COPY --from=builder /gradiant_style.zip /
RUN sed -i 's/reverse()/reverse(),`${regularBundlePath}\/gradiant_style.style.css`/g' /usr/share/kibana/src/legacy/ui/ui_render/ui_render_mixin.js

# Modify logoKibana in vendorsDynamicDLL to be empty. Custom icon will be set as background-image in gradiant_style plugin css
RUN sed -i 's@var logoKibana=function.*logoKibana.defaultProps=@var logoKibana=function logoKibana(props){return _react.default.createElement("svg",props,_react.default.createElement("g",{fill:"none",fillRule:"evenodd"}))};logoKibana.defaultProps=@g' /usr/share/kibana/built_assets/dlls/vendors.bundle.dll.js

RUN bin/kibana-plugin install file:///gradiant_style.zip
RUN bin/kibana --env.name=production --logging.json=false --optimize


