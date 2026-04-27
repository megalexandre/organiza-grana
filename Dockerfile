FROM nginx:alpine AS runtime

COPY build/web /usr/share/nginx/html
COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENV API_BASE_URL=https://app.project-deploy.shop/api

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
